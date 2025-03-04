import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/components/grid_file.dart';
import 'package:my_app/provider/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FileList extends StatelessWidget {
  const FileList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 70, left: 20),
                  child: Text(
                    "Heisenburg", //will replace with username
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(top: 70, right: 20),
                  child: Consumer(
                    builder: (context, ref, child) {
                      return InkWell(
                        onTap: () async {
                            await ref.read(userProvider.notifier).logout(context);
                          await clearAuthData();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(context, '/login');
                          }
                        },
                        child: SvgPicture.asset(
                          'assets/svg/logout.svg',
                          width: 35,
                          height: 35,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(top: 20, left: 20),
                child: Text(
                  "8 files, 3 have expiration",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.normal,
                    color: Colors.black38,
                  ),
                ),
              ),
            ),
            GridFile(),
          ],
        ),
      ),
    );
  }
}
