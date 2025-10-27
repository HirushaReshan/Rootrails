import 'package:flutter/material.dart';

// Animal theme uses earth tones and accent colors
class CustomThemes {
  static final ThemeData animalTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF6D4C41), // brown
    scaffoldBackgroundColor: const Color(0xFFF9F5EE),
    appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF6D4C41)),
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6D4C41)),
  );
}
