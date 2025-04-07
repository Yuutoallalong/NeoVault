import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/components/back_leading_button.dart';
import 'package:my_app/components/file_settings.dart';
import 'package:my_app/provider/file_picker_provider.dart';

class Upload extends ConsumerStatefulWidget {
  const Upload({super.key});

  @override
  ConsumerState<Upload> createState() => _UploadState();
}

class _UploadState extends ConsumerState<Upload> {
  bool switchStatus = false;
  final messageController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  bool upload = false;
  int dayLeft = 7;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backLeadingButton(context: context),
        title: Text(
          "Heisenburg",
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: ListView(
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 180,
                ),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFF454545),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(
                      8,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Consumer(
                        builder: (context, ref, _) {
                          final file = ref.watch(fileProvider);
                          if (file == null) {
                            return Column(
                              children: [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 36,
                                ),
                                Text(
                                  "Upload here",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await ref
                                        .read(fileProvider.notifier)
                                        .pickFile();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 0),
                                    backgroundColor: Color(0xff5992b7),
                                    minimumSize: Size(140, 40),
                                  ),
                                  child: Text(
                                    "Select file",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Text(
                                    'Selected file : ${file.name}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 18),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    ref.read(fileProvider.notifier).clearFile();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 0),
                                    backgroundColor: Colors.red,
                                    minimumSize: Size(140, 40),
                                  ),
                                  child: Text(
                                    "Cancel",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                fileSettings(
                    context: context,
                    messageController: messageController,
                    passwordController: passwordController,
                    switchStatus: switchStatus,
                    switchOnChanged: (bool value) {
                      setState(() {
                        switchStatus = value;
                      });
                    },
                    daysLeftOnChanged: (int value) {
                      setState(() {
                        dayLeft = value;
                      });
                    },
                    formKey: formKey,
                    hintText: "Add a message (optional)",
                    dayLeft: dayLeft),
                ElevatedButton(
                  onPressed: () async {
                    final pickedFile = ref.read(fileProvider);
                    if (pickedFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No file selected')));
                      return;
                    }
                    await ref.read(fileProvider.notifier).uploadFile(
                        pickedFile,
                        messageController.text,
                        passwordController.text,
                        switchStatus,
                        dayLeft);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Uploaded')));
                    Navigator.pop(context);
                  },
                  child: Text('Upload'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
