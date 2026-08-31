import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import "../controllers/notification-manager.dart";

class FBAuth {
  static final FBAuth _instance = FBAuth._internal();
  factory FBAuth() => _instance;
  FBAuth._internal();

  static Stream<User?> get authStateChange => FirebaseAuth.instance.authStateChanges();

  static Future<void> createAccountWithEmailPass(String email, String pass) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<void> signInWithEmailPass(String email, String pass) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        print('Invalid email or password.');
      } else if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  static Future<void> initGoogleSignIn() async {
    await GoogleSignIn.instance.initialize();
  }

  static Future<void> signInWithGoogle() async {
    try {
      final acc = await GoogleSignIn.instance.authenticate();
      final ggAuth = await acc.authentication;

      if (ggAuth != null) {
        final credential = GoogleAuthProvider.credential(idToken: ggAuth.idToken);

        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } catch (err) {
      print("sign in with gg error: $err");
    }
  }

  static Future<void> signOutWithGoogle() async {
    await GoogleSignIn.instance.disconnect();
    await FirebaseAuth.instance.signOut();
  }
}
