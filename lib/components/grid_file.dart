import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/models/fileInfo.dart';
import 'package:my_app/models/user.dart';
import 'package:my_app/provider/file_picker_provider.dart';
import 'package:my_app/provider/user_provider.dart';

class GridFile extends ConsumerWidget {
  final String userId;
  const GridFile({super.key, required this.userId});

  void showFileMismatchDialog(
      BuildContext context, WidgetRef ref, FileInfo file) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("File Hash Mismatch"),
          content: Text(
            "This could indicate that the file has been modified, which could make it unsafe to open. Do you want to proceed?",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await ref
                    .read(fileProvider.notifier)
                    .previewFile(context, file, stillProceed: true);
                Navigator.of(context).pop();
              },
              child: Text("Open File"),
            ),
            TextButton(
              onPressed: () async {
                await ref
                    .read(fileProvider.notifier)
                    .deleteFile(file.id, userId);
                Navigator.of(context).pop();
              },
              child: Text("Delete File", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider);
    final userId = user!.id;
    final filesAsyncValue = ref.watch(filesStreamProvider(userId));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: filesAsyncValue.when(
        data: (files) {
          if (files.isEmpty) {
            return Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                Text('No files found.'),
              ],
            );
          }
          return GridView.builder(
            itemCount: files.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1.2,
              crossAxisCount: 2,
            ),
            itemBuilder: (context, index) {
              final file = files[index];
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () async {
                    final result = await ref
                        .read(fileProvider.notifier)
                        .previewFile(context, file);
                    if (result == ViewFileResponse.unmatch) {
                      showFileMismatchDialog(context, ref, file);
                    }
                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 5, left: 125),
                        child: InkWell(
                          onTap: () async {
                            // Get the FileNotifier instance
                            final fileNotifier =
                                await ref.read(fileProvider.notifier);
                            // Call the navigateToFileDetail method
                            fileNotifier.navigateToFileDetail(context, file);
                          },
                          child: SvgPicture.asset("assets/svg/edit.svg"),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: SvgPicture.asset(
                          "assets/svg/file.svg",
                          width: 40,
                          height: 40,
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Text(
                          file.name,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      Text(
                        file.description.isEmpty
                            ? "No description"
                            : file.description,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: Colors.black38,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
