import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/components/social_media_login.dart';
import 'package:my_app/provider/user_provider.dart';

Widget footerAuthen(
    {required BuildContext context,
    required String dividertext,
    required String footerText,
    required String footerLinkText,
    required String to,
    required var ref}) {
  return Column(
    children: [
      Row(
        children: [
          Expanded(
            child: Divider(
              color: Theme.of(context).colorScheme.secondary,
              thickness: 1.5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(dividertext),
          ),
          Expanded(
            child: Divider(
              color: Theme.of(context).colorScheme.secondary,
              thickness: 1.5,
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 20,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          socialMediaLogin(
            context: context,
            asset: "assets/icons/facebook.png",
            onTap: () async {
              try {
                var credentials =
                    await ref.read(userProvider.notifier).signInWithFacebook();
                print("User logged in: $credentials");
              } catch (e) {
                print("Facebook login failed: $e");
              }
            },
          ),
          socialMediaLogin(
            context: context,
            asset: "assets/icons/google.png",
            onTap: () async {
              var credentials =
                  await ref.read(userProvider.notifier).signInWithGoogle();
              print("!!!!!!!!!credentials!!!!!!!!!!! $credentials");
            },
          ),
          socialMediaLogin(
              context: context,
              asset: "assets/icons/microsoft.png",
              onTap: () {}),
        ],
      ),
      const SizedBox(
        height: 60,
      ),
      RichText(
          text: TextSpan(
              text: footerText,
              style: GoogleFonts.urbanist(color: Colors.black),
              children: [
            TextSpan(
                text: footerLinkText,
                style: GoogleFonts.urbanist(
                    color: Color(0xFF35C2C1), fontWeight: FontWeight.bold),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.pushNamed(context, to);
                  })
          ]))
    ],
  );
}
