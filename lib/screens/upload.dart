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
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 36,
                      ),
                      Text(
                        "Upload here",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          print("tapped");
                          var FileNotifier =
                              await ref.read(fileProvider.notifier).pickFile();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          backgroundColor: Color(0xff5992b7),
                          minimumSize: Size(140, 40),
                        ),
                        child: Text(
                          "Select file",
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                fileSettings(
                    context: context,
                    messageController: messageController,
                    switchStatus: switchStatus,
                    switchOnChanged: (bool value) {
                      setState(() {
                        switchStatus = value;
                      });
                    },
                    formKey: formKey,
                    hintText: "Add a message (optional)",
                    dayLeft: 7),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Uploaded')));
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
