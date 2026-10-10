import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import "../controllers/notification-manager.dart";
import "database.dart";
import 'package:flutter/foundation.dart';

class FBAuth {
  static final FBAuth _instance = FBAuth._internal();
  factory FBAuth() => _instance;
  FBAuth._internal();

  static Future<String?> createAccountWithEmailPass(String email, String pass) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );

      String? uid = credential.user?.uid;
      if (uid != null) FirebaseDB.updateUser(uid, {"login-method": "email", "pass": pass});

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') return "The account already exists for that email.";

      if (e.code == "unknown")
        return "Password is too weak (at least 6 characters + 1 special character)";

      return e.message;
    } catch (e) {
      print(e);
      return "unknow error";
    }
  }

  static Future<String?> signInWithEmailPass(String email, String pass) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') return 'Invalid email or password.';
      if (e.code == 'user-not-found') return 'No user found for that email.';
      if (e.code == 'wrong-password') return 'Wrong password provided.';
      return e.message;
    }
  }

  static Future<void> initGoogleSignIn() async {
    await GoogleSignIn.instance.initialize();
  }

  static Future<void> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        await FirebaseAuth.instance.signInWithPopup(authProvider);
      } else {
        final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();
        final GoogleSignInAuthentication googleAuth = googleUser.authentication;

        final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);

        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } catch (e) {
      print("Google Sign-In error: $e");
    }
  }

  static Future<void> logout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    bool isGGProvided = user.providerData.any((info) => info.providerId == "google.com");

    if (isGGProvided) {
      try {
        await GoogleSignIn.instance.disconnect();
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        print(e);
      }
    }
    await FirebaseAuth.instance.signOut();
  }

  // check user authentication state
  static Stream<User?> get authStateChange => FirebaseAuth.instance.authStateChanges();
}
