import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_app/models/fileInfo.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class FileNotifier extends StateNotifier<PlatformFile?> {
  FileNotifier() : super(null);

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

    final path = 'files/${pickedFile.name}';
    final file = File(pickedFile.path!);

    final ref = FirebaseStorage.instance.ref().child(path);

    await ref.putFile(file);

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

    state = null;
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
