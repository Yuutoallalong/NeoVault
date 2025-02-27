import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/components/back_leading_button.dart';
import 'package:my_app/components/footer_authen.dart';
import 'package:my_app/components/input.dart';
import 'package:my_app/components/show_snackbar.dart';
import 'package:my_app/provider/user_provider.dart';

class Register extends ConsumerStatefulWidget {
  const Register({super.key});

  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends ConsumerState<Register> {
  final formkey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backLeadingButton(context: context),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: ListView(
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Hello! Register to get\nstarted",
                      style: GoogleFonts.urbanist(
                          fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                Form(
                    key: formkey,
                    child: Column(
                      children: [
                        input(
                          context: context,
                          controller: usernameController,
                          hintText: "Username",
                          obscureText: false,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        input(
                            context: context,
                            controller: emailController,
                            hintText: "Email",
                            textInputType: TextInputType.emailAddress,
                            obscureText: false),
                        const SizedBox(
                          height: 15,
                        ),
                        input(
                            context: context,
                            controller: passwordController,
                            hintText: "Password",
                            obscureText: true),
                        const SizedBox(
                          height: 15,
                        ),
                        input(
                            context: context,
                            controller: confirmPasswordController,
                            hintText: "Confirm Password",
                            obscureText: true),
                        const SizedBox(
                          height: 30,
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              if (formkey.currentState?.validate() == true) {
                                if (passwordController.text ==
                                    confirmPasswordController.text) {
                                  String err = await ref
                                      .read(userProvider.notifier)
                                      .createUser(
                                        username: usernameController.text,
                                        email: emailController.text,
                                        password: passwordController.text,
                                      );
                                  if (err == 'success') {
                                    if (context.mounted) {
                                      Navigator.pushNamed(context, '/login');
                                    }
                                  } else {
                                    if (context.mounted) {
                                      showSnackBar(context, err);
                                    }
                                    if (err != 'weak-password') {
                                      usernameController.clear();
                                      emailController.clear();
                                    }

                                    passwordController.clear();
                                    confirmPasswordController.clear();
                                  }
                                } else {
                                  showSnackBar(
                                      context, "Password does not match");
                                  passwordController.clear();
                                  confirmPasswordController.clear();
                                }
                              }
                            },
                            child: Text("Register")),
                      ],
                    )),
                const SizedBox(
                  height: 40,
                ),
                footerAuthen(
                    context: context,
                    dividertext: "Or Register With",
                    footerText: "Already have an account? ",
                    footerLinkText: "Login Now",
                    to: "/login")
              ],
            )
          ],
        ),
      ),
    );
  }
}
