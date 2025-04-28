import 'dart:async';
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
  Timer? _logoutTimer;
  static const Duration sessionTimeout = Duration(seconds: 5);

  // ====== Timer Handling ======
  void _startAutoLogoutTimer({required BuildContext context}) {
    _cancelAutoLogoutTimer();
    _logoutTimer = Timer(sessionTimeout, () async {
      await logout();
    });
  }

  void _cancelAutoLogoutTimer() {
    _logoutTimer?.cancel();
    _logoutTimer = null;
  }

  // ====== Main Functions ======
  Future<void> setUser({required String email}) async {
    final userSnapshot = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    final userDocs = userSnapshot.docs;
    if (userDocs.isNotEmpty) {
      final userData = userDocs[0].data();
      final userId = userDocs[0].id;
      MyUser currentUser = MyUser.fromJson({...userData, 'id': userId});
      state = currentUser;
    }
  }

  Future<String> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await setUser(email: email);
      _startAutoLogoutTimer(context: context); // เริ่มนับเวลา auto logout
    } on FirebaseAuthException catch (e) {
      return e.code;
    }

    return 'success';
  }

  Future<String> register({
    required String username,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) return 'user-creation-failed';

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': username,
        'email': email,
        'fileCount': 0,
        'expiredFileCount': 0,
      });

      await setUser(email: email);
      _startAutoLogoutTimer(context: context); // เริ่มนับเวลา auto logout
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
    return 'success';
  }

  Future<void> signInWithGoogle({required BuildContext context}) async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    var userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    await saveUserToFirestore(userCredential: userCredential);
    _startAutoLogoutTimer(context: context);
  }

  Future<void> signInWithFacebook({required BuildContext context}) async {
    final LoginResult loginResult = await FacebookAuth.instance.login();
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

    var userCredential = await FirebaseAuth.instance
        .signInWithCredential(facebookAuthCredential);

    await saveUserToFirestore(userCredential: userCredential);
    _startAutoLogoutTimer(context: context);
  }

  Future<void> logout() async {
    _cancelAutoLogoutTimer();
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    await FacebookAuth.instance.logOut();
    await clearAuthData();
    state = null;
  }

  Future<void> saveUserToFirestore(
      {required UserCredential userCredential}) async {
    try {
      final user = userCredential.user;
      if (user == null) {
        throw Exception('No user found');
      }

      final email = user.email;
      if (email == null) {
        throw Exception('No email found');
      }

      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        await setUser(email: email);
        return;
      }

      final uid = user.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'username': email.split('@')[0],
        'fileCount': 0,
        'expiredFileCount': 0,
      });

      await setUser(email: email);
    } catch (e) {
      throw Exception('Error saving user to Firestore: $e');
    }
  }

  Future<bool> resetPassword({required String email}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }
}

final userProvider = StateNotifierProvider<UserNotifier, MyUser?>(
  (ref) => UserNotifier(),
);
