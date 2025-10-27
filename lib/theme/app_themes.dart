import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum for theme type
enum AppTheme { light, dark, animal }

// Theme Data for Light Mode
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.green,
  scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Light grey background
  appBarTheme: const AppBarTheme(
    color: Colors.green,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  cardTheme: const CardTheme(
    color: Colors.white,
    elevation: 4,
    // FIX: Using const constructors for BorderRadius
    shape: const RoundedRectangleBorder(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black87),
    bodyMedium: TextStyle(color: Colors.black54),
    titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: Colors.green.shade700,
    unselectedItemColor: Colors.grey.shade600,
    type: BottomNavigationBarType.fixed,
  ),
  colorScheme: ColorScheme.light(
    primary: Colors.green.shade700,
    secondary: Colors.amber.shade600,
    surface: Colors.white,
    onSurface: Colors.black,
  ),
);

// Theme Data for Dark Mode
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.blueGrey,
  scaffoldBackgroundColor: Colors.grey.shade900,
  appBarTheme: AppBarTheme(
    color: Colors.blueGrey.shade900,
    iconTheme: const IconThemeData(color: Colors.white),
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  cardTheme: const CardTheme(
    color: const Color(0xFF424242), // Colors.grey.shade800 equivalent
    elevation: 4,
    // FIX: Using const constructors for BorderRadius
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: const TextStyle(color: Colors.white70),
    bodyMedium: ThemeData().textTheme.bodyMedium?.copyWith(
      color: Colors.grey.shade400,
      fontSize: 14,
    ),
    titleLarge: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: Colors.green.shade400,
    unselectedItemColor: Colors.grey.shade400,
    backgroundColor: Colors.grey.shade800,
    type: BottomNavigationBarType.fixed,
  ),
  colorScheme: ColorScheme.dark(
    primary: Colors.green.shade600,
    secondary: Colors.amber.shade400,
    surface: Colors.grey.shade800,
    onSurface: Colors.white,
  ),
);

// Theme Data for Animal/Custom Mode (e.g., Savannah theme)
final ThemeData animalTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.deepOrange,
  scaffoldBackgroundColor: const Color(0xFFFFF8E1), // Light yellow/sand
  appBarTheme: AppBarTheme(
    color: Colors.brown.shade700,
    iconTheme: const IconThemeData(color: Colors.white),
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  cardTheme: const CardTheme(
    color: const Color(0xFFFFFDE7), // Very light yellow
    elevation: 6,
    // FIX: Using const constructors for BorderRadius
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: const TextStyle(color: Color(0xFF5D4037)), // Deep brown
    bodyMedium: const TextStyle(color: Color(0xFF795548)), // Brown
    titleLarge: TextStyle(
      color: Colors.brown.shade900,
      fontWeight: FontWeight.bold,
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: Colors.orange.shade800,
    unselectedItemColor: Colors.brown.shade400,
    backgroundColor: const Color(0xFFFFFDE7),
    type: BottomNavigationBarType.fixed,
  ),
  colorScheme: ColorScheme.light(
    primary: Colors.orange.shade700,
    secondary: Colors.teal.shade400, // Contrast color
    surface: const Color(0xFFFFECB3),
    onSurface: Colors.brown.shade900,
  ),
);

// Service to manage and persist theme state
class ThemeService with ChangeNotifier {
  AppTheme _currentTheme = AppTheme.light;
  AppTheme get currentTheme => _currentTheme;

  ThemeService() {
    _loadTheme();
  }

  ThemeData get themeData {
    switch (_currentTheme) {
      case AppTheme.dark:
        return darkTheme;
      case AppTheme.animal:
        return animalTheme;
      case AppTheme.light:
      default:
        return lightTheme;
    }
  }

  void switchTheme(AppTheme newTheme) {
    if (_currentTheme != newTheme) {
      _currentTheme = newTheme;
      _saveTheme(newTheme);
      notifyListeners();
    }
  }

  void toggleTheme() {
    final newTheme = _currentTheme == AppTheme.light
        ? AppTheme.dark
        : AppTheme.light;
    switchTheme(newTheme);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('app_theme') ?? 'light';
    _currentTheme = AppTheme.values.firstWhere(
      (e) => e.toString().split('.').last == themeString,
      orElse: () => AppTheme.light,
    );
    notifyListeners();
  }

  Future<void> _saveTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme', theme.toString().split('.').last);
  }
}
