import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/components/back_leading_button.dart';
import 'package:my_app/components/input.dart';
import 'package:my_app/provider/user_provider.dart';
import 'package:my_app/screens/login.dart';

class ForgotPw extends ConsumerStatefulWidget {
  const ForgotPw({super.key});

  @override
  ForgotPwState createState() => ForgotPwState();
}

class ForgotPwState extends ConsumerState<ForgotPw> {
  final emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(leading: backLeadingButton(context: context)),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ListView(children: [
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(
                  height: 40,
                ),
                Text(
                  "Enter your Email",
                  style: GoogleFonts.urbanist(
                      fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 18,
                ),
                input(
                    context: context,
                    controller: emailController,
                    hintText: "Enter your email",
                    textInputType: TextInputType.emailAddress,
                    obscureText: false),
                const SizedBox(
                  height: 18,
                ),
                ElevatedButton(
                    onPressed: () async {
                      final email = emailController.text.trim();
                      if (email.isNotEmpty) {
                        final success = await ref
                            .read(userProvider.notifier)
                            .resetPassword(email);
                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "Password reset email doesn't send, please try again")),
                          );
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Password reset email sent")),
                        );
                        emailController.clear();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please enter your email")),
                        );
                      }
                    },
                    child: Text("Send"))
              ])
            ])));
  }
}
