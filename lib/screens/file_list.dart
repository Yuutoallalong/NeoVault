import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/components/grid_file.dart';
import 'package:my_app/components/session_dialog.dart';
import 'package:my_app/models/user.dart';
import 'package:my_app/provider/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FileList extends ConsumerWidget {
  const FileList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/upload');
          if (result == true) {
            final currentEmail = user.email;
            await ref.read(userProvider.notifier).setUser(email: currentEmail);
          }
        },
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
                    user.username,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(top: 70, right: 20),
                  child: Consumer(
                    builder: (context, ref, child) {
                      return InkWell(
                        onTap: () async {
                          await ref.read(userProvider.notifier).logout();
                          await clearAuthData();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(context, '/');
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
                  "${user.fileCount} files, ${user.expiredFileCount} have expiration",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.normal,
                    color: Colors.black38,
                  ),
                ),
              ),
            ),
            GridFile(
              userId: user.id,
            ),
          ],
        ),
      ),
    );
  }
}
