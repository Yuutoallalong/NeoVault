import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/provider/file_picker_provider.dart';

class GridFile extends ConsumerWidget {
  const GridFile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filesAsyncValue = ref.watch(filesStreamProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: filesAsyncValue.when(
        data: (files) {
          if (files.isEmpty) {
            return const Center(child: Text('No files found.'));
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
                  onTap: () {},
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 5, left: 125),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/filedetail',
                                arguments: file.id);
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
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          file.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
