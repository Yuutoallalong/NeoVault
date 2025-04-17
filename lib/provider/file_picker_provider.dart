import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_app/models/fileInfo.dart';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:async';
import 'dart:convert';
import 'package:my_app/provider/AESHelper.dart';

class FileNotifier extends StateNotifier<PlatformFile?> {
  FileNotifier() : super(null) {
    // Initialize periodic cleanup when the notifier is created
    _startExpirationCleanupTimer();
  }

  Timer? _cleanupTimer;

  // Add this method to start periodic cleanup
  void _startExpirationCleanupTimer() {
    // Check once every hour
    _cleanupTimer = Timer.periodic(Duration(hours: 1), (timer) async {
      await cleanupExpiredFiles();
    });

    // Also run once at startup
    cleanupExpiredFiles();
  }

  // Improved cleanupExpiredFiles method with more debugging
  Future<void> cleanupExpiredFiles() async {
    try {
      // Get current time
      final now = DateTime.now();
      print('Running cleanup at: $now');

      // Create a query for files that have expired
      final querySnapshot = await FirebaseFirestore.instance
          .collection('files')
          .where('expiredIn', isLessThan: now)
          .get();

      print('Found ${querySnapshot.docs.length} expired files');

      // Process each expired file
      for (var doc in querySnapshot.docs) {
        try {
          final fileInfo = FileInfo.fromFirestore(doc);
          print(
              'Attempting to delete expired file: ${fileInfo.name}, ID: ${fileInfo.id}, expired on: ${fileInfo.expiredIn}');

          bool success = await deleteFile(fileInfo.id);
          print(
              'Delete result for ${fileInfo.id}: ${success ? "Success" : "Failed"}');
        } catch (e) {
          print('Error processing document ${doc.id}: $e');
        }
      }

      print('Expired files cleanup completed');
    } catch (e) {
      print('Error cleaning up expired files: $e');
    }
  }

  // Don't forget to add this to clean up the timer when the notifier is disposed
  @override
  void dispose() {
    _cleanupTimer?.cancel();
    super.dispose();
  }

  // Add this method to manually trigger cleanup (for testing)
  Future<void> forceCleanupExpiredFiles(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Starting manual cleanup...')),
      );

      await cleanupExpiredFiles();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Manual cleanup completed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cleanup error: ${e.toString()}')),
      );
    }
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      state = result.files.single;
    }
    return;
  }

  Future<void> uploadFile(PlatformFile pickedFile, String description,
      String filePassword, bool locked, int daysLeft) async {
    if (pickedFile == null) {
      return;
    }

    try {
      final originalFile = File(pickedFile.path!);
      final fileBytes = await originalFile.readAsBytes();

      final encryptionPassword =
          filePassword.isNotEmpty ? filePassword : 'default_secure_password';

      print("Encrypting with password: $encryptionPassword"); // Debug log

      // Encrypt the file
      final encryptedBytes =
          AESHelper.encryptFile(fileBytes, encryptionPassword);

      // Create a temporary encrypted file
      final tempDir = await getTemporaryDirectory();
      final encryptedPath = '${tempDir.path}/${pickedFile.name}.enc';
      final encryptedFile = File(encryptedPath);
      await encryptedFile.writeAsBytes(encryptedBytes);

      final path = 'files/${pickedFile.name}';
      final ref = FirebaseStorage.instance.ref().child(path);

      await ref.putFile(encryptedFile);
      final downloadUrl = await ref.getDownloadURL();

      final fileRef = FirebaseFirestore.instance.collection('files').doc();
      final fileInfo = FileInfo(
        id: fileRef.id,
        name: pickedFile.name,
        url: downloadUrl,
        createAt: DateTime.now(),
        daysLeft: daysLeft,
        expiredIn: DateTime.now().add(Duration(days: daysLeft)),
        locked: locked,
        filePassword: hashPassword(filePassword),
        description: description,
        size: pickedFile.size.toDouble(),
      );

      await saveFileToFirestore(fileInfo);

      await encryptedFile.delete();
      state = null;
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  Future<void> saveFileToFirestore(FileInfo fileInfo) async {
    final fileRef = FirebaseFirestore.instance.collection('files').doc();

    final fileData = fileInfo.toMap();
    fileData['id'] = fileRef.id;

    await fileRef.set(fileData);
  }

  void clearFile() {
    state = null;
  }

  String hashPassword(String filePassword) {
    final bytes = utf8.encode(filePassword);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<List<FileInfo>> fetchFiles() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('files').get();
    List<FileInfo> files = [];

    files = querySnapshot.docs.map((doc) {
      return FileInfo.fromFirestore(doc);
    }).toList();

    return files;
  }

  Future<FileInfo?> fetchFileById(String id) async {
    final doc =
        await FirebaseFirestore.instance.collection('files').doc(id).get();

    if (doc.exists) {
      return FileInfo.fromFirestore(doc);
    } else {
      return null;
    }
  }

  Future<bool> updateFileSettings({
    required String fileId,
    String? description,
    int? daysLeft,
    bool? locked,
    String? password,
  }) async {
    try {
      // First fetch the current file data
      FileInfo? currentFile = await fetchFileById(fileId);
      if (currentFile == null) {
        return false;
      }

      // Calculate new expiration date if daysLeft changed
      DateTime expiredIn = currentFile.expiredIn;
      if (daysLeft != null && daysLeft != currentFile.daysLeft) {
        expiredIn = DateTime.now().add(Duration(days: daysLeft));
      }

      // Hash password if provided
      String filePassword = currentFile.filePassword;
      if (locked == true && password != null && password.isNotEmpty) {
        filePassword = hashPassword(password);
      }

      // Build update data
      final Map<String, dynamic> updateData = {
        'daysLeft': daysLeft ?? currentFile.daysLeft,
        'expiredIn': expiredIn,
      };

      // Only update optional fields if they are provided
      if (description != null) {
        updateData['description'] = description;
      }

      if (locked != null) {
        updateData['locked'] = locked;
        // If locked status is false, clear password
        if (!locked) {
          updateData['filePassword'] = '';
        } else if (password != null && password.isNotEmpty) {
          updateData['filePassword'] = filePassword;
        }
      }

      // Update document in Firestore
      await FirebaseFirestore.instance
          .collection('files')
          .doc(fileId)
          .update(updateData);

      return true;
    } catch (e) {
      print('Error updating file: $e');
      return false;
    }
  }

  Future<bool> deleteFile(String fileId) async {
    try {
      // First fetch the file to get the storage URL
      FileInfo? file = await fetchFileById(fileId);
      if (file == null) {
        return false;
      }

      // Delete from Firebase Storage
      if (file.url.isNotEmpty) {
        try {
          // Extract storage reference from URL
          final ref = FirebaseStorage.instance.refFromURL(file.url);
          await ref.delete();
        } catch (e) {
          print('Error deleting from storage: $e');
          // Continue with Firestore deletion even if Storage deletion fails
        }
      }

      // Delete from Firestore
      await FirebaseFirestore.instance.collection('files').doc(fileId).delete();

      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  Future<void> previewFile(BuildContext context, FileInfo fileInfo) async {
    try {
      String? password;

      // Get password if needed
      if (fileInfo.locked && fileInfo.filePassword.isNotEmpty) {
        password = await _showPasswordDialog(context);

        if (password == null || password.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password required to preview this file')),
          );
          return;
        }

        // Verify password - compare HASHED passwords
        String hashedEnteredPassword = hashPassword(password);
        if (hashedEnteredPassword != fileInfo.filePassword) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Incorrect password')),
          );
          return;
        }

        // IMPORTANT: Use the raw password for decryption, not the hashed version
        // This is the key change: use the raw password that was used for encryption
        print("Decrypting with password: $password"); // Debug log
      } else {
        password = 'default_secure_password'; // Must match the upload password
      }

      // Download the encrypted file
      final tempDir = await getTemporaryDirectory();
      final encryptedPath = '${tempDir.path}/${fileInfo.name}.enc';
      final encryptedFile = File(encryptedPath);

      if (!await encryptedFile.exists()) {
        final task = FirebaseStorage.instance
            .refFromURL(fileInfo.url)
            .writeToFile(encryptedFile);

        await task.whenComplete(() {});

        // Verify download completed successfully
        if (task.snapshot.state != TaskState.success) {
          throw Exception('Download failed');
        }
      }

      // Add debug logging
      final fileSize = await encryptedFile.length();
      print("Downloaded encrypted file size: $fileSize bytes");

      // Read encrypted data
      final encryptedBytes = await encryptedFile.readAsBytes();
      if (encryptedBytes.length < 33) {
        // Salt (16) + IV (16) + at least some data
        throw Exception('Invalid encrypted file: file too small');
      }

      // Decrypt the file with the RAW password, not hashed
      Uint8List decryptedBytes;
      try {
        decryptedBytes = AESHelper.decryptFile(encryptedBytes, password);
      } catch (e) {
        print('Detailed decryption error: ${e.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Decryption failed: ${e.toString()}')),
        );
        return;
      }

      // Save the decrypted file to a temporary location
      final decryptedPath = '${tempDir.path}/decrypted_${fileInfo.name}';
      final decryptedFile = File(decryptedPath);
      await decryptedFile.writeAsBytes(decryptedBytes);

      // Open the decrypted file with the native viewer
      final result = await OpenFile.open(decryptedPath);
      if (result.type != ResultType.done) {
        throw Exception(result.message);
      }

      // Optional: Clean up temporary files after a delay
      Future.delayed(Duration(minutes: 5), () {
        try {
          encryptedFile.delete();
          decryptedFile.delete();
        } catch (_) {}
      });
    } catch (e) {
      print('Preview error: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot preview file: ${e.toString()}')),
      );
    }
  }

// Add this method to show a password dialog
  Future<String?> _showPasswordDialog(BuildContext context) async {
    TextEditingController passwordController = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Password Required'),
          content: TextField(
            controller: passwordController,
            decoration: InputDecoration(
              hintText: 'Enter file password',
            ),
            obscureText: true,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop(passwordController.text);
              },
            ),
          ],
        );
      },
    );
  }

  // Add this method to your FileNotifier class
  Future<void> navigateToFileDetail(
      BuildContext context, FileInfo fileInfo) async {
    try {
      // Check if file is password protected
      if (fileInfo.locked && fileInfo.filePassword.isNotEmpty) {
        // Show password dialog
        String? enteredPassword = await _showPasswordDialog(context);

        // If user cancels the dialog or enters no password
        if (enteredPassword == null || enteredPassword.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password required to edit this file')),
          );
          return;
        }

        // Verify password
        String hashedEnteredPassword = hashPassword(enteredPassword);
        if (hashedEnteredPassword != fileInfo.filePassword) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Incorrect password')),
          );
          return;
        }
        // Password verified, proceed to file detail page
      }

      // Navigate to file detail page
      Navigator.pushNamed(context, '/filedetail', arguments: fileInfo.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}

final fileProvider =
    StateNotifierProvider<FileNotifier, PlatformFile?>((ref) => FileNotifier());

final filesStreamProvider = StreamProvider<List<FileInfo>>((ref) {
  return FirebaseFirestore.instance
      .collection('files')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return FileInfo.fromFirestore(doc);
    }).toList();
  });
});
