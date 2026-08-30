import 'package:flutter/material.dart';
import "UI/homepage.dart";
import "controllers/ml-controller.dart";
import "controllers/mqtt-manager.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MLController.init();
  await startMQTT();

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
