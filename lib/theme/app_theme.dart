import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get parchmentTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF8A4F2B),
      scaffoldBackgroundColor: const Color(0xFFF3E7D6),
      cardColor: const Color(0xFF2E241A),
      canvasColor: const Color(0xFFFAF0E6),
      dividerColor: const Color(0xFFDAC6A7),
      highlightColor: const Color(0xFFD79C55),
      splashColor: const Color(0x33D79C55),
      shadowColor: Colors.black26,
      fontFamily: 'Georgia',
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF3E7D6),
        foregroundColor: Color(0xFF2E241A),
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2E241A),
          letterSpacing: 0.5,
          fontFamily: 'Georgia',
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2E241A),
          fontFamily: 'Georgia',
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF3C2E24),
          fontFamily: 'Georgia',
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: Color(0xFF3C2E24),
          fontFamily: 'Georgia',
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          color: Color(0xFF5A4A3F),
          fontFamily: 'Georgia',
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8A4F2B),
          fontFamily: 'Georgia',
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF8A4F2B),
        secondary: Color(0xFFD79C55),
        surface: Color(0xFFF7E8D2),
        onPrimary: Colors.white,
        onSecondary: Color(0xFF2E241A),
        onSurface: Color(0xFF2E241A),
      ),
    );
  }
}
