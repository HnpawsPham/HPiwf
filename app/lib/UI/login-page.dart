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
  TextEditingController _retypePassController = TextEditingController();

  bool signInForm = true;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 10),
          constraints: const BoxConstraints(minWidth: 350, maxWidth: 500),

          backgroundColor: colorDarkBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            signInForm ? "SIGN IN" : "SIGN UP",
            style: TextStyle(color: colorWhite, fontFamily: "cubano"),
            textAlign: TextAlign.center,
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

              // sign up retype password
              if (!signInForm) ...[
                SizedBox(height: 10),

                TextField(
                  controller: _retypePassController,
                  style: const TextStyle(color: colorWhite),
                  decoration: InputDecoration(
                    hintText: "Retype password",
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
            ],
          ),

          actions: [
            Row(
              children: [
                // sign up/ sign in swtich
                TextButton(
                  onPressed: () => setState(() => signInForm = !signInForm),
                  child: Text(
                    signInForm ? "Create account" : "Sign in",
                    style: TextStyle(
                      color: colorWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                Spacer(),

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
                  onPressed: () async {
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

                    // handle sign in
                    if (signInForm) {
                      if (!ok) return;
                      String? res = await FBAuth.signInWithEmailPass(emailInp, passInp);

                      if (res == null) {
                        notify(context, "Welcome back!", 3, 200);
                        Navigator.pop(context);
                      } else
                        notify(context, res, 4, 500);
                    }
                    // handle sign up
                    else {
                      String retypePassInp = _retypePassController.text.trim();
                      if (retypePassInp.isEmpty) {
                        print("pass is empty");
                        notify(context, "Please retype your password", 4, 404);
                        ok = false;
                      } else if (retypePassInp != passInp) {
                        print("pass and retype pass not match");
                        notify(context, "Passwords don't match", 4, 500);
                        ok = false;
                      }

                      if (!ok) return;
                      String? res = await FBAuth.createAccountWithEmailPass(emailInp, passInp);

                      if (res == null) {
                        notify(context, "Welcome! Your account is created.", 5, 200);
                        Navigator.pop(context);
                      } else
                        notify(context, res, 7, 500);
                    }
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(color: colorBlack, fontFamily: "cubano", fontSize: 15),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
