import "package:firebase_auth/firebase_auth.dart";
import 'package:flutter/material.dart';
import "package:hpiwf/config.dart";
import "package:hpiwf/database/database.dart";
import "UI/homepage.dart";
import "controllers/ml-controller.dart";
import "controllers/mqtt-manager.dart";
import "package:firebase_core/firebase_core.dart";
import "package:hpiwf/firebase_options.dart";
import "./database/authentication.dart";
import "controllers/notification-manager.dart";
import 'package:hpiwf/controllers/data-controller.dart';

late final FirebaseApp app;
late final FirebaseAuth auth;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await startMQTT();
  await LocalNoticeService.init();
  await DataController.instance.loadSettings();

  // initialize firebase
  app = await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  auth = FirebaseAuth.instanceFor(app: app);
  await FBAuth.initGoogleSignIn();

  // get current GID
  FirebaseDB.initGIDListener(auth);

  await MLController.init();
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
    return ValueListenableBuilder(
      valueListenable: themeNotifier,
      builder: (context, curTheme, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const HomePage(),
          theme: AppTheme.lightMode,
          darkTheme: AppTheme.darkMode,
          themeMode: curTheme,
        );
      },
    );
  }
}
