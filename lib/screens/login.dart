import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/components/back_leading_button.dart';
import 'package:my_app/components/footer_authen.dart';
import 'package:my_app/components/input.dart';
import 'package:my_app/components/show_snackbar.dart';
import 'package:my_app/provider/user_provider.dart';
import 'package:my_app/screens/forgot_pw.dart';

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends ConsumerState<Login> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  int loginFailCount = 0;
  @override
  Widget build(BuildContext context) {
    // final user = ref.watch(userProvider);
    return Scaffold(
        appBar: AppBar(leading: backLeadingButton(context: context)),
        body: loginFailCount == 4
            ? Container()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ListView(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "NeoVault",
                          style: GoogleFonts.rammettoOne(
                              fontSize: 58,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor),
                        ),
                        const SizedBox(
                          height: 130,
                        ),
                        Form(
                            key: formKey,
                            child: Column(
                              children: [
                                input(
                                    context: context,
                                    controller: emailController,
                                    hintText: "Enter your email",
                                    textInputType: TextInputType.emailAddress,
                                    obscureText: false),
                                const SizedBox(
                                  height: 18,
                                ),
                                input(
                                    context: context,
                                    controller: passwordController,
                                    hintText: "Enter your password",
                                    obscureText: true),
                                const SizedBox(
                                  height: 24,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    RichText(
                                        text: TextSpan(
                                            text: "Forgot Password?",
                                            style: GoogleFonts.urbanist(
                                                color: Colors.black),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ForgotPw(),
                                                    ));
                                              }))
                                  ],
                                ),
                                const SizedBox(
                                  height: 24,
                                ),
                                ElevatedButton(
                                    onPressed: () async {
                                      if (formKey.currentState?.validate() ==
                                          true) {
                                        String err = await ref
                                            .read(userProvider.notifier)
                                            .login(
                                                email: emailController.text,
                                                password:
                                                    passwordController.text,
                                                context: context);

                                        if (err == 'success') {
                                          if (context.mounted) {
                                            Navigator.pushReplacementNamed(
                                                context, '/filelist');
                                          }
                                        } else {
                                          setState(() {
                                            loginFailCount++;
                                          });
                                          if (context.mounted) {
                                            showSnackBar(context, err);
                                          }
                                        }
                                      }
                                    },
                                    child: Text("Login"))
                              ],
                            )),
                        const SizedBox(
                          height: 60,
                        ),
                        footerAuthen(
                          context: context,
                          dividertext: "Or Login With",
                          footerText: "Don’t have an account? ",
                          footerLinkText: "Register Now",
                          to: "/register",
                          ref: ref,
                        )
                      ],
                    )
                  ],
                ),
              ));
  }
}
