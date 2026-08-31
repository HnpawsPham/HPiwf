import 'package:flutter/material.dart';
import "../database/authentication.dart";
import "../config.dart";
import "../controllers/notification-manager.dart";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FBAuth.authStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());

        if (snapshot.hasData) {
          return Center(child: Text("logged in"));
        }

        // if not signed in
        return Column(
          children: [
            SizedBox(height: 30),

            Text("You are not signed in!", style: TextStyle(fontSize: 30, color: colorWhite)),

            SizedBox(height: 50),

            // google sign in method
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorDarkBlue,
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                ),
                onPressed: () => FBAuth.signInWithGoogle(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(color: colorWhite, fontSize: 24, fontFamily: "oldstyle"),

                        children: [
                          const TextSpan(text: "Sign in with "),
                          const TextSpan(
                            text: "Google",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Image.asset("assets/google-icon.webp", height: 25),
                  ],
                ),
              ),
            ),

            SizedBox(height: 15),

            // email password sign in method
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorDarkBlue,
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                ),
                onPressed: () => _showInputPopup(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(color: colorWhite, fontSize: 24, fontFamily: "oldstyle"),

                        children: [
                          const TextSpan(text: "Sign in with "),
                          const TextSpan(
                            text: "Email",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 15),
                    Image.asset("assets/email-icon.png", height: 20),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

void _showInputPopup(BuildContext context) {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: colorDarkBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Sign in with email & password",
          style: TextStyle(color: colorWhite, fontFamily: "cubano"),
        ),

        content: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            TextField(
              controller: _emailController,
              style: const TextStyle(color: colorWhite),
              decoration: InputDecoration(
                hintText: "Email",
                hintStyle: TextStyle(color: colorWhite, fontSize: 18),
                filled: true,
                fillColor: colorBlack,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 10),

            TextField(
              controller: _passController,
              style: const TextStyle(color: colorWhite),
              decoration: InputDecoration(
                hintText: "Password",
                hintStyle: TextStyle(color: colorWhite, fontSize: 18),
                filled: true,
                fillColor: colorBlack,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),

        actions: [
          // Cancel btn
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.red, fontFamily: "cubano"),
            ),
          ),

          // Submit btn
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colorWhite),
            onPressed: () {
              String emailInp = _emailController.text.trim();
              String passInp = _passController.text.trim();
              bool ok = true;

              if (emailInp.isEmpty) {
                print("Email is empty!");
                notify(context, "Email is empty!", 4, 404);
                ok = false;
              }
              if (passInp.isEmpty) {
                print("pass is empty");
                notify(context, "Password is empty!", 4, 404);
                ok = false;
              }

              if (ok) {
                FBAuth.signInWithEmailPass(emailInp, passInp);
                Navigator.pop(context);
              }
            },
            child: const Text(
              "OK",
              style: TextStyle(color: colorBlack, fontFamily: "cubano", fontSize: 15),
            ),
          ),
        ],
      );
    },
  );
}
