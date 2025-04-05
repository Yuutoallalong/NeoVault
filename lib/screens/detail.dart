import 'package:flutter/material.dart';
import 'package:my_app/components/back_leading_button.dart';
import 'package:my_app/components/file_settings.dart';

class Detail extends StatefulWidget {
  const Detail({super.key});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
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
            const SizedBox(
              height: 180,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(Icons.file_present, size: 120),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "WongnaiDocs",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "size: 1.1 GB",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff626272)
                                .withAlpha((255 * 0.6).toInt()),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
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
                hintText: "nobody knows",
                dayLeft: 7),
            const SizedBox(
              height: 50,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(
                  0xffff2c21,
                ).withAlpha((255 * 0.72).toInt()),
              ),
              onPressed: () {
                // You can add functionality for the CONFIRM button here
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Deleted')));
              },
              child: Text('Delete'),
            ),
            const SizedBox(height: 10),
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
