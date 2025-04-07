import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> clearAuthData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

class UserNotifier extends StateNotifier<MyUser?> {
  UserNotifier() : super(null);

  final firestore = FirebaseFirestore.instance;
  void setUser(String email) async {
    final userSnapshot = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    final userDocs = userSnapshot.docs;
    if (userDocs.isNotEmpty) {
      final userData = userDocs[0].data();
      MyUser currentUser = MyUser.fromJson(userData);
      state = currentUser;
    }
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      setUser(email);
    } on FirebaseAuthException catch (e) {
      return e.code;
    }

    return 'success';
  }

  Future<String> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await firestore.collection('users').add({
        'username': username,
        'email': email,
        'fileCount': 0,
        'expiredFileCount': 0,
      });
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
    return 'success';
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

    // Once signed in, return the UserCredential
    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    await FacebookAuth.instance.logOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }
}

final userProvider = StateNotifierProvider<UserNotifier, MyUser?>(
  (ref) => UserNotifier(),
);
