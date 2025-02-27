import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/provider/user_provider.dart';

class Mock extends ConsumerWidget {
  const Mock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text("Login Successfully")),
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              ref.read(userProvider.notifier).logout(context);
            },
            child: Text("Logout")),
      ),
    );
  }
}
