import 'package:flutter/painting.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hpiwf/database/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

String GIDPrefix(String topic) {
  return "${FirebaseDB.chosenGID.value}/topic";
}

// check user permission to edit
bool checkPermission(Map<String, dynamic>? user) {
  return ((user?["role"] ?? 0) != 0);
}

// THEME CONFIG
ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);
Future<void> loadTheme() async {
  final pref = await SharedPreferences.getInstance();
  final isDark = pref.getBool('isDarkMode') ?? true;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
}

Future<void> toggleTheme() async {
  final pref = await SharedPreferences.getInstance();
  final isDark = themeNotifier.value == ThemeMode.dark;
  themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
  await pref.setBool('isDarkMode', !isDark);
}

const Color colorWhite = Color.fromARGB(255, 210, 240, 255);
const Color colorBlack = Color(0xFF04040c);
const Color colorDarkBlue = Color.fromARGB(255, 16, 55, 84);
const Color colorLightBlue = Color(0xFF81acd9);
const Color colorRed = Color.fromARGB(255, 159, 25, 25);

class AppTheme {
  // Dark Mode
  static final ThemeData darkMode = ThemeData(
    fontFamily: "oldstyle",
    fontFamilyFallback: const ["cubano"],
    scaffoldBackgroundColor: const Color(0xFF04040c),
    colorScheme: const ColorScheme.dark(
      primary: colorLightBlue,
      surface: colorDarkBlue,
      onSurface: colorWhite,
      secondary: colorLightBlue,
      tertiaryContainer: colorLightBlue,
      onTertiaryContainer: colorBlack,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color.fromARGB(255, 210, 240, 255)),
      bodyMedium: TextStyle(color: Color.fromARGB(255, 210, 240, 255)),
      titleLarge: TextStyle(color: Color.fromARGB(255, 210, 240, 255)),
    ),
  );

  // Light Mode
  static final ThemeData lightMode = ThemeData(
    fontFamily: "oldstyle",
    fontFamilyFallback: const ["cubano"],
    scaffoldBackgroundColor: const Color(0xFFF4F8FC),
    colorScheme: const ColorScheme.light(
      primary: colorDarkBlue,
      surface: Color(0xFFE1EFFB),
      onSurface: colorDarkBlue,
      secondary: colorWhite,
      tertiaryContainer: colorBlack,
      onTertiaryContainer: colorWhite,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF0F1B26)),
      bodyMedium: TextStyle(color: Color(0xFF0F1B26)),
      titleLarge: TextStyle(color: Color(0xFF0F1B26)),
    ),
  );
}
