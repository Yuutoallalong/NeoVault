import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_app/models/fileInfo.dart';

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
      String filePassword, bool locked) async {
    if (pickedFile == null) {
      return;
    }

    final path = 'files/${pickedFile.name}';
    final file = File(pickedFile.path!);

    final ref = FirebaseStorage.instance.ref().child(path);

    await ref.putFile(file);

    final downloadUrl = await ref.getDownloadURL();
    final fileInfo = FileInfo(
      id: FirebaseFirestore.instance.collection('files').doc().id,
      name: pickedFile.name,
      url: downloadUrl,
      createAt: DateTime.now(),
      daysLeft: 30,
      expiredIn: DateTime.now().add(Duration(days: 30)),
      locked: locked,
      filePassword: filePassword,
      description: description,
      size: pickedFile.size.toDouble(),
    );

    await saveFileToFirestore(fileInfo);

    state = null;
  }

  Future<void> saveFileToFirestore(FileInfo fileInfo) async {
    try {
      final fileCollection = FirebaseFirestore.instance.collection('files');
      await fileCollection.doc(fileInfo.id).set(fileInfo.toMap());
      print('File uploaded and metadata saved to Firestore');
    } catch (e) {
      print('Error uploading file metadata to Firestore: $e');
    }
  }

  void clearFile() {
    state = null;
  }
}

final fileProvider =
    StateNotifierProvider<FileNotifier, PlatformFile?>((ref) => FileNotifier());
