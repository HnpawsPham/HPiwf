import 'package:flutter/painting.dart';
import 'package:flutter/material.dart';

// only and unchangable GID
final String GID = const String.fromEnvironment("GID");

// THEME CONFIG
ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

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
      tertiaryContainer: colorLightBlue
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
      tertiaryContainer: colorBlack
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF0F1B26)),
      bodyMedium: TextStyle(color: Color(0xFF0F1B26)),
      titleLarge: TextStyle(color: Color(0xFF0F1B26)),
    ),
  );
}
