import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/provider/file_picker_provider.dart';
import 'package:my_app/provider/user_provider.dart';

class GridFile extends ConsumerWidget {
  final String userId;
  const GridFile({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider);
    final userId = user!.id;
    final filesAsyncValue = ref.watch(filesStreamProvider(userId));
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 32, left: 20, right: 20),
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
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1.05,
              crossAxisCount: 2,
            ),
            itemBuilder: (context, index) {
              final file = files[index];
              return Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () async {
                    await ref
                        .read(fileProvider.notifier)
                        .previewFile(context, file);
                    await ref
                        .read(userProvider.notifier)
                        .setUser(email: user.email);
                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5, right: 5),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: InkWell(
                            onTap: () async {
                              final fileNotifier =
                                  ref.read(fileProvider.notifier);
                              fileNotifier.navigateToFileDetail(context, file);
                            },
                            child: SvgPicture.asset("assets/svg/edit.svg"),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: SvgPicture.asset(
                          "assets/svg/file.svg",
                          width: 40,
                          height: 40,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          file.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          file.description.isEmpty
                              ? "No description"
                              : file.description,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Colors.black38,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
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
