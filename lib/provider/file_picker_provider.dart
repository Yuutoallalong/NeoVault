import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

class FileNotifier extends StateNotifier<PlatformFile?> {
  FileNotifier() : super(null);

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      state = result.files.single;
    }
    return;
  }

  Future<void> uploadFile(PlatformFile pickedFile) async {
    if (pickedFile == null) {
      return;
    }

    final path = 'files/${pickedFile.name}';
    final file = File(pickedFile.path!);

    final ref = FirebaseStorage.instance.ref().child(path);

    await ref.putFile(file);

    // await FirebaseFirestore.instance.collection('users').doc(userId).set({
    //   'fileName': pickedFile.name,
    //   'fileUrl': downloadUrl,
    //   'uploadedAt': Timestamp.now(),
    // }, SetOptions(merge: true));

    state = null;
  }

  void clearFile() {
    state = null;
  }
}

final fileProvider =
    StateNotifierProvider<FileNotifier, PlatformFile?>((ref) => FileNotifier());
