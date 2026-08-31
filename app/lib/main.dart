import "package:firebase_auth/firebase_auth.dart";
import 'package:flutter/material.dart';
import "UI/homepage.dart";
import "controllers/ml-controller.dart";
import "controllers/mqtt-manager.dart";
import "package:firebase_core/firebase_core.dart";
import "package:hpiwf/firebase_options.dart";
import "./database/authentication.dart";

late final FirebaseApp app;
late final FirebaseAuth auth;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MLController.init();
  await startMQTT();

  // initialize firebase
  app = await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  auth = FirebaseAuth.instanceFor(app: app);
  await FBAuth.initGoogleSignIn();

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        fontFamily: "oldstyle",
        fontFamilyFallback: ["cubano"],
        brightness: Brightness.dark,
      ),
    );
  }
}
