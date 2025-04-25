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
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FileNotifier extends StateNotifier<PlatformFile?> {
  FileNotifier() : super(null) {
    // Initialize periodic cleanup when the notifier is created
    _startExpirationCleanupTimer();
  }

  Timer? _cleanupTimer;

  // Add this method to start periodic cleanup
  void _startExpirationCleanupTimer() {
    // Check once every hour
    _cleanupTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
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

          bool success = await deleteFile(fileInfo.id, fileInfo.userId);

          // Increment the expiredFileCount if the file was successfully deleted
          if (success) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(fileInfo
                    .userId) // userId in fileInfo is the same as id in user model
                .update({
              'expiredFileCount': FieldValue.increment(1),
            });
            print('Incremented expired file count for user ${fileInfo.userId}');
          }

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
      String filePassword, bool locked, int daysLeft, String userId) async {
    String default_password = dotenv.get('DEFAULT_PBKDF2_PASSWORD');
    if (pickedFile == null) {
      return;
    }

    try {
      final originalFile = File(pickedFile.path!);
      final fileBytes = await originalFile.readAsBytes();

      final encryptionPassword =
          filePassword.isNotEmpty ? filePassword : default_password;

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
          userId: userId);

      await saveFileToFirestore(fileInfo);

      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      await userRef.update({
        'fileCount': FieldValue.increment(1),
      });

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
    String? oldPassword,
  }) async {
    // Add detailed logging for debugging

    try {
      // 1. Fetch current file info
      FileInfo? currentFile = await fetchFileById(fileId);
      if (currentFile == null) {
        return false;
      }

      // 2. Handle expiration update
      DateTime expiredIn = currentFile.expiredIn;
      if (daysLeft != null && daysLeft != currentFile.daysLeft) {
        expiredIn = DateTime.now().add(Duration(days: daysLeft));
      }

      final Map<String, dynamic> updateData = {
        'daysLeft': daysLeft ?? currentFile.daysLeft,
        'expiredIn': expiredIn,
      };

      if (description != null) {
        updateData['description'] = description;
      }

      // 3. Initialize encryption logic
      bool needsReEncryption = false;
      String newEncryptionPassword = dotenv.get('DEFAULT_PBKDF2_PASSWORD');
      String currentEncryptionPassword = dotenv.get('DEFAULT_PBKDF2_PASSWORD');
      String updatedHashedPassword = currentFile.filePassword;

      // 4. Handle password status change
      if (locked != null) {
        updateData['locked'] = locked;

        // Case 1: Currently locked, turning off password protection
        if (currentFile.locked && locked == false) {
          // Verify old password before removing
          if (oldPassword == null || oldPassword.isEmpty) {
            return false;
          }

          String hashedOld = hashPassword(oldPassword);
          if (hashedOld != currentFile.filePassword) {
            return false;
          }

          // Password verified, now remove it
          updateData['filePassword'] = '';
          currentEncryptionPassword =
              oldPassword; // Use old password to decrypt
          newEncryptionPassword = dotenv
              .get('DEFAULT_PBKDF2_PASSWORD'); // Use default for new encryption
          needsReEncryption = true;
        }
        // Case 2: Adding password protection (was unlocked, now locking)
        else if (!currentFile.locked && locked == true) {
          // Setting a new password when previously unlocked
          if (password == null || password.isEmpty) {
            return false;
          }

          updatedHashedPassword = hashPassword(password);
          updateData['filePassword'] = updatedHashedPassword;
          currentEncryptionPassword =
              dotenv.get('DEFAULT_PBKDF2_PASSWORD'); // Default for decryption
          newEncryptionPassword = password; // New password for encryption
          needsReEncryption = true;
        }
        // Case 3: Changing existing password (locked and staying locked)
        else if (currentFile.locked &&
            locked == true &&
            password != null &&
            password.isNotEmpty) {
          // Verify old password before changing
          if (oldPassword == null || oldPassword.isEmpty) {
            return false;
          }

          String hashedOld = hashPassword(oldPassword);
          if (hashedOld != currentFile.filePassword) {
            return false;
          }

          // Old password verified, update to new password
          updatedHashedPassword = hashPassword(password);
          updateData['filePassword'] = updatedHashedPassword;
          currentEncryptionPassword =
              oldPassword; // Use old password to decrypt
          newEncryptionPassword = password; // Use new password for encryption
          needsReEncryption = true;
        }
      }

      // 5. Re-encrypt the file if needed
      if (needsReEncryption) {
        try {
          final tempDir = await getTemporaryDirectory();
          final encryptedPath = '${tempDir.path}/${currentFile.name}.enc';
          final encryptedFile = File(encryptedPath);

          await FirebaseStorage.instance
              .refFromURL(currentFile.url)
              .writeToFile(encryptedFile);

          final encryptedBytes = await encryptedFile.readAsBytes();

          final decryptedBytes = AESHelper.decryptFile(
            encryptedBytes,
            currentEncryptionPassword,
          );

          final reEncryptedBytes =
              AESHelper.encryptFile(decryptedBytes, newEncryptionPassword);

          await encryptedFile.writeAsBytes(reEncryptedBytes);

          final storageRef =
              FirebaseStorage.instance.refFromURL(currentFile.url);
          final uploadTask = storageRef.putFile(encryptedFile);
          await uploadTask;

          if (uploadTask.snapshot.state != TaskState.success) {
            return false;
          }

          await encryptedFile.delete();
        } catch (e) {
          return false;
        }
      }

      // 6. Update Firestore

      await FirebaseFirestore.instance
          .collection('files')
          .doc(fileId)
          .update(updateData);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteFile(String fileId, String userId) async {
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
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      await userRef.update({
        'fileCount': FieldValue.increment(-1),
      });

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
      } else {
        password = dotenv
            .get('DEFAULT_PBKDF2_PASSWORD'); // Must match the upload password
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

  // Future<void> updateExpiredFileCount(String userId) async {
  //   try {
  //     // Get current time
  //     final now = DateTime.now();

  //     // Count expired files for this user
  //     final querySnapshot = await FirebaseFirestore.instance
  //         .collection('files')
  //         .where('userId', isEqualTo: userId)
  //         .where('expiredIn', isLessThan: now)
  //         .get();

  //     final expiredCount = querySnapshot.docs.length;

  //     // Update user document with expired file count
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(userId)
  //         .update({'expiredFileCount': expiredCount});
  //   } catch (e) {
  //     print('Error updating expired file count: $e');
  //   }
  // }

  // Add this method to the FileNotifier class
}

final fileProvider =
    StateNotifierProvider<FileNotifier, PlatformFile?>((ref) => FileNotifier());

final filesStreamProvider =
    StreamProvider.family<List<FileInfo>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('files')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return FileInfo.fromFirestore(doc);
    }).toList();
  });
});
