import 'package:flutter/material.dart';

Ink socialMediaLogin(
    {required BuildContext context,
    String? asset,
    // required IconData icon,
    Color? color,
    required GestureTapCallback onTap,
    double? size}) {
  return Ink(
    width: 110,
    height: 60,
    decoration: BoxDecoration(
      border:
          Border.all(color: Theme.of(context).colorScheme.secondary, width: 2),
      borderRadius: BorderRadius.circular(10),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: asset != null
          ? Image.asset(
              asset,
              width: size != null ? size * 0.6 : 20,
              height: size != null ? size * 0.6 : 20,
            )
          : const SizedBox(),
    ),
  );
}
