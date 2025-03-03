import 'package:flutter/material.dart';
import 'package:my_app/components/back_leading_button.dart';

class Detail extends StatefulWidget {
  const Detail({super.key});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: backLeadingButton(context: context)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: ListView(
          children: [
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
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "size: 1.1 GB",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff626272),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 25),
            TextField(
              decoration: InputDecoration(
                hintText: 'nobody knows',
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
