import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import "../controllers/notification-manager.dart";

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
      final acc = await GoogleSignIn.instance.authenticate();
      final ggAuth = await acc.authentication;

      if (ggAuth != null) {
        final credential = GoogleAuthProvider.credential(idToken: ggAuth.idToken);

        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<void> signOutWithGoogle() async {
    await GoogleSignIn.instance.disconnect();
    await FirebaseAuth.instance.signOut();
  }

  // check user authentication state
  static Stream<User?> get authStateChange =>
      FirebaseAuth.instance.idTokenChanges().asyncMap((user) async {
        if (user == null) return null;

        try {
          await user.reload();
          return user;
        } on FirebaseAuthException catch (e) {
          if (e.code == "user-not-found") {
            await FirebaseAuth.instance.signOut();
            return null;
          }
        }
        return user;
      });
}
