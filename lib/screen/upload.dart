import 'package:flutter/material.dart';
import 'package:my_app/components/back_leading_button.dart';

class Upload extends StatefulWidget {
  const Upload({super.key});

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: backLeadingButton(context: context)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: ListView(
          children: [
            Container(
              width: 200,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black, // กำหนดสีของเส้นขอบ
                  width: 2, // กำหนดความหนาของเส้นขอบ
                ),
                borderRadius: BorderRadius.circular(
                  8,
                ), // เพิ่มความโค้งให้กับมุมของกรอบ
              ),
              child: Column(
                children: [
                  Icon(Icons.upload_file_outlined),
                  Text("Upload here"),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff5992b7),
                      minimumSize: Size(150, 10),
                    ),
                    child: Text("Select file"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            TextField(
              decoration: InputDecoration(
                hintText: 'Add a message (optional)',
                hintStyle: TextStyle(color: Color(0xff626272)),
                filled: true,
                fillColor: Color(0xfff7f6fb),
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, color: Color(0xff626272)),
                        Text("Expiration date"),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "7 days",
                          style: TextStyle(color: Color(0xff626272)),
                        ),
                        Icon(Icons.edit, color: Color(0xff626272)),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lock, color: Color(0xff626272)),
                        Text("Password"),
                      ],
                    ),
                    Switch(value: false, onChanged: (value) {}),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                // You can add functionality for the CONFIRM button here
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Saved')));
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
