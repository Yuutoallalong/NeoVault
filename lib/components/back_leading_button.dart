import 'package:flutter/material.dart';

Widget backLeadingButton({required BuildContext context}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: SizedBox(
      width: 36,
      height: 36,
      child: Ink(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).pop(),
          child: Icon(Icons.arrow_back_ios_new_outlined, size: 18),
        ),
      ),
    ),
  );
}
