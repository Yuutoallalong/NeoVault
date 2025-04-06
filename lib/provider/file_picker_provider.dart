import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

class FileNotifier extends StateNotifier<PlatformFile?> {
  FileNotifier() : super(null);

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      state = result.files.single;
      print('Picked file: ${state!.name}');
    } else {
      print('No file selected');
    }
  }

  void clearFile() {
    state = null;
  }
}

final fileProvider =
    StateNotifierProvider<FileNotifier, PlatformFile?>((ref) => FileNotifier());
