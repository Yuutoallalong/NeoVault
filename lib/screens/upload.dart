import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/components/back_leading_button.dart';
import 'package:my_app/components/file_settings.dart';
import 'package:my_app/components/session_dialog.dart';
import 'package:my_app/models/user.dart';
import 'package:my_app/provider/file_picker_provider.dart';
import 'package:my_app/provider/user_provider.dart';

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
    final user = ref.watch(userProvider);

    ref.listen<MyUser?>(userProvider, (previous, next) {
      if (previous != null && next == null) {
        if (context.mounted) {
          sessionDialog(context: context);
        }
      }
    });
    if (user == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        leading: backLeadingButton(context: context),
        title: Text(
          user.username,
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
                SizedBox(
                  height: MediaQuery.of(context).size.width / 8,
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
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Center(
                                      child: Text(
                                        'Selected file: ${file.name}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 18,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    ref.read(fileProvider.notifier).clearFile();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 0),
                                    backgroundColor: Colors.red,
                                    minimumSize: const Size(140, 40),
                                  ),
                                  child: const Text(
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
                    dayLeft: dayLeft,
                    passwordHintText: "Enter your password"),
                ElevatedButton(
                  onPressed: () async {
                    final pickedFile = ref.watch(fileProvider);
                    if (pickedFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('No file selected')),
                      );
                      return;
                    }

                    final file = File(pickedFile.path!);
                    final fileSize = await file.length();
                    const maxSizeInBytes = 500 * 1024 * 1024; //500MB

                    if (fileSize > maxSizeInBytes) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('File too large (limit is 500MB)')),
                      );
                      return;
                    }

                    final unsafeExtensions = [
                      '.exe',
                      '.sh',
                      '.bat',
                      '.js',
                      '.jar',
                      '.py',
                      '.php',
                      '.pl',
                      '.rb',
                      '.dll',
                      '.msi',
                    ];

                    final fileName = pickedFile.name.toLowerCase();
                    final isDangerous =
                        unsafeExtensions.any((ext) => fileName.endsWith(ext));

                    if (isDangerous) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('File type not allowed')),
                      );
                      return;
                    }

                    final userEmail = user.email;

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return Dialog(
                          backgroundColor: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(width: 16),
                                Text("Uploading..."),
                              ],
                            ),
                          ),
                        );
                      },
                    );

                    try {
                      await ref.read(fileProvider.notifier).uploadFile(
                            pickedFile,
                            messageController.text,
                            passwordController.text,
                            switchStatus,
                            dayLeft,
                            user.id,
                          );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Uploaded')),
                      );

                      await ref
                          .read(userProvider.notifier)
                          .setUser(email: userEmail);

                      Navigator.pop(context, true);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Upload failed: $e')),
                      );
                    } finally {
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                  },
                  child: Text('Upload'),
                ),
                SizedBox(height: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
