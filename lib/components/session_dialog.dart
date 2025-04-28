import 'package:flutter/material.dart';

Future sessionDialog({required BuildContext context}) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Session Expired'),
      content: const Text('Your session has expired. Please log in again.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
