import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF111111),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFF2B2B2B),
      onSecondary: Color(0xFFFFFFFF),
      error: Color(0xFFB3261E),
      onError: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF121212),
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF7F7F7),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF111111),
        elevation: 0,
      ),
    );
  }

  static ThemeData dark() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFFFFFFF),
      onPrimary: Color(0xFF101010),
      secondary: Color(0xFFD9D9D9),
      onSecondary: Color(0xFF151515),
      error: Color(0xFFF2B8B5),
      onError: Color(0xFF601410),
      surface: Color(0xFF101010),
      onSurface: Color(0xFFF4F4F4),
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF0C0C0C),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF101010),
        foregroundColor: Color(0xFFFFFFFF),
        elevation: 0,
      ),
    );
  }
}
