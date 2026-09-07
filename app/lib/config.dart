import 'package:flutter/painting.dart';
import 'package:flutter/material.dart';

ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

const Color colorWhite = Color.fromARGB(255, 210, 240, 255);
const Color colorBlack = Color(0xFF04040c);
const Color colorDarkBlue = Color.fromARGB(255, 16, 55, 84);
const Color colorLightBlue = Color(0xFF81acd9);

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
      primary: Color(0xFF2B6CA3),
      surface: Color(0xFFE1EFFB),
      onSurface: Color(0xFF0F1B26),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF0F1B26)),
      bodyMedium: TextStyle(color: Color(0xFF0F1B26)),
      titleLarge: TextStyle(color: Color(0xFF0F1B26)),
    ),
  );
}
