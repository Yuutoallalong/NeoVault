import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/components/social_media_login.dart';
import 'package:my_app/provider/user_provider.dart';

final firestore = FirebaseFirestore.instance;
Widget footerAuthen({
  required BuildContext context,
  required String dividertext,
  required String footerText,
  required String footerLinkText,
  required String to,
  required var ref,
}) {
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          socialMediaLogin(
            context: context,
            asset: "assets/icons/facebook.png",
            onTap: () async {
              try {
                await ref.read(userProvider.notifier).signInWithFacebook();

                Navigator.pushReplacementNamed(context, '/filelist');
              } catch (e) {
                print("Facebook login failed: $e");
              }
            },
          ),
          socialMediaLogin(
            context: context,
            asset: "assets/icons/google.png",
            onTap: () async {
              try {
                await ref.read(userProvider.notifier).signInWithGoogle();
                Navigator.pushReplacementNamed(context, '/filelist');
              } catch (e) {
                print(e);
              }
            },
          ),
          // socialMediaLogin(
          //     context: context,
          //     asset: "assets/icons/microsoft.png",
          //     onTap: () {}),
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
