import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/components/back_leading_button.dart';
import 'package:my_app/components/footer_authen.dart';
import 'package:my_app/components/input.dart';

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
                ElevatedButton(onPressed: () {}, child: Text("Register")),
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
