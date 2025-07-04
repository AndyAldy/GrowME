import 'package:flutter/material.dart';

class AppTheme {
  // --- WARNA INTI ---
  static const Color _primaryLight = Color(0xFF87CEEB); // Sky Blue
  static const Color _accentLight = Color(0xFF62FF7F);  // Bright Green
  static const Color _backgroundLight = Colors.white;
  static const Color _textPrimaryLight = Color(0xFF212121); // Almost Black
  static const Color _textSecondaryLight = Colors.black54;

  static const Color _primaryDark = Color(0xFF65B4D3);   // A deeper Sky Blue
  static const Color _accentDark = Color(0xFF7AFF9C);   // A more vibrant Green
  static const Color _backgroundDark = Color(0xFF121212); // Standard dark background
  static const Color _surfaceDark = Color(0xFF1E1E1E);   // For cards, etc.
  static const Color _textPrimaryDark = Colors.white;
  static const Color _textSecondaryDark = Colors.white70;

  // --- TEMA TERANG ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: _backgroundLight,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryLight,
      brightness: Brightness.light,
      primary: _primaryLight,
      secondary: _accentLight,
      background: _backgroundLight,
      onPrimary: _textPrimaryLight,
      onSecondary: _textPrimaryLight,
      onBackground: _textPrimaryLight,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: _textPrimaryLight),
      bodyMedium: TextStyle(color: _textSecondaryLight),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _backgroundLight,
      elevation: 0,
      foregroundColor: _textPrimaryLight,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryLight,
        foregroundColor: _textPrimaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
      foregroundColor: const Color.fromARGB(255, 0, 0, 0),
    )),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: _textSecondaryLight),
      floatingLabelStyle: TextStyle(color: _accentLight),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: _accentLight, width: 2.0),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _primaryLight,
      selectedItemColor: _accentLight,
      showSelectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
  );

  // --- TEMA GELAP ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _backgroundDark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryDark,
      brightness: Brightness.dark,
      primary: _primaryDark,
      secondary: _accentDark,
      background: _backgroundDark,
      surface: _surfaceDark,
      onPrimary: _textPrimaryDark,
      onSecondary: Colors.black,
      onBackground: _textPrimaryDark,
      onSurface: _textPrimaryDark,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: _textPrimaryDark),
      bodyMedium: TextStyle(color: _textSecondaryDark),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _surfaceDark,
      elevation: 0,
      foregroundColor: _textPrimaryDark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryDark,
        foregroundColor: _textPrimaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
      foregroundColor: _primaryDark,
    )),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: _textSecondaryDark),
      floatingLabelStyle: TextStyle(color: _accentDark),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: _accentDark, width: 2.0),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _surfaceDark,
      selectedItemColor: _accentDark,
      showSelectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
