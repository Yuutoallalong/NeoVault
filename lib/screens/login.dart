import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/components/back_button.dart';
import 'package:my_app/components/input.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app/components/social_media_login.dart';

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends ConsumerState<Login> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(leading: backLeadingButton(context: context)),
        body: Padding(
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
                                        ..onTap = () => () {}))
                            ],
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          ElevatedButton(onPressed: () {}, child: Text("Login"))
                        ],
                      )),
                  const SizedBox(
                    height: 60,
                  ),
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
                        child: Text("Or Login with"),
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
                          icon: Icons.facebook_outlined,
                          color: Color(0xFF4092FF),
                          onTap: () {}),
                      socialMediaLogin(
                          context: context,
                          icon: FontAwesomeIcons.google,
                          onTap: () {},
                          size: 28),
                      socialMediaLogin(
                          context: context,
                          icon: Icons.apple_outlined,
                          onTap: () {}),
                    ],
                  ),
                  const SizedBox(
                    height: 60,
                  ),
                  RichText(
                      text: TextSpan(
                          text: "Don’t have an account? ",
                          style: GoogleFonts.urbanist(color: Colors.black),
                          children: [
                        TextSpan(
                            text: "Register Now",
                            style: GoogleFonts.urbanist(
                                color: Color(0xFF35C2C1),
                                fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => () {
                                    Navigator.pushNamed(context, '/register');
                                  })
                      ]))
                ],
              )
            ],
          ),
        ));
  }
}
