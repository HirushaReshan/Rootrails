import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum for theme type
enum AppTheme { light, dark, animal }

// --- 🌲 Light Theme: Forest Green & White ---
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.green,
  scaffoldBackgroundColor: const Color(0xFFF0F4F7), // Very Light Blue-Grey
  appBarTheme: const AppBarTheme(
    color: Color(0xFF4C7D4D), // Deep Forest Green (Primary Color)
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  cardTheme: const CardThemeData(
    // Changed to CardTheme to match base ThemeData
    color: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF2E4053)), // Dark Slate Text
    bodyMedium: TextStyle(color: Color(0xFF566573)), // Medium Grey Text
    titleLarge: TextStyle(
      color: Color(0xFF2C3E50),
      fontWeight: FontWeight.bold,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Color(0xFF4C7D4D), // Deep Forest Green
    unselectedItemColor: Color(0xFF90A4AE), // Light Greyish Blue
    type: BottomNavigationBarType.fixed,
  ),
  colorScheme: ColorScheme.light(
    primary: const Color(0xFF4C7D4D), // Deep Forest Green
    onPrimary: Colors.white,
    secondary: const Color(0xFFE5A823), // Amber/Gold Accent
    surface: Colors.white,
    onSurface: const Color(0xFF2C3E50), // Main text color
    background: const Color(0xFFF0F4F7),
  ),
);

// --- 🌑 Dark Theme: Deep Slate & Olive Green ---
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.blueGrey,
  scaffoldBackgroundColor: const Color(0xFF1C2833), // Deep Slate Grey
  appBarTheme: const AppBarTheme(
    color: Color(0xFF263238), // Dark AppBar Background
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  cardTheme: const CardThemeData(
    // Changed to CardTheme
    color: Color(0xFF2C3E50), // Dark Card Background
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(
      color: Color(0xFFD5DBDB),
      fontSize: 14,
    ), // Lighter Grey Text
    titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF263238),
    selectedItemColor: Color(0xFF7CB342), // Olive Green Accent
    unselectedItemColor: Color(0xFF5D6D7E), // Medium Grey
    type: BottomNavigationBarType.fixed,
  ),
  colorScheme: ColorScheme.dark(
    primary: const Color(0xFF7CB342), // Olive Green Accent
    onPrimary: Colors.black,
    secondary: const Color(0xFFF4D03F), // Yellow/Gold Accent
    surface: const Color(0xFF2C3E50),
    onSurface: Colors.white,
    background: const Color(0xFF1C2833),
  ),
);

// --- 🦁 Animal Theme: Savannah Sunset (Earthy Browns & Orange) ---
final ThemeData animalTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.deepOrange,
  scaffoldBackgroundColor: const Color(0xFFFFF8E1), // Light Sand/Savannah
  appBarTheme: const AppBarTheme(
    color: Color(0xFF795548), // Deep Brown/Earth (Primary Color)
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  cardTheme: const CardThemeData(
    // Changed to CardTheme
    color: Color(0xFFFBEBCF), // Lighter Sand Card
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF5D4037)), // Deep Brown Text
    bodyMedium: TextStyle(color: Color(0xFF8D6E63)), // Medium Brown Text
    titleLarge: TextStyle(
      color: Color(0xFF5D4037),
      fontWeight: FontWeight.bold,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFFFFECB3), // Light Tan
    selectedItemColor: Color(0xFFE65100), // Deep Orange (Sunset)
    unselectedItemColor: Color(0xFF8D6E63), // Medium Brown
    type: BottomNavigationBarType.fixed,
  ),
  colorScheme: ColorScheme.light(
    primary: const Color(0xFF795548), // Deep Brown/Earth
    onPrimary: Colors.white,
    secondary: const Color(0xFFE65100), // Deep Orange (Sunset)
    surface: const Color(0xFFFFECB3),
    onSurface: const Color(0xFF5D4037), // Main text color
    background: const Color(0xFFFFF8E1),
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
    // Toggles between Light and Dark
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
