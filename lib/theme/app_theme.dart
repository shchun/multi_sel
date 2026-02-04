import 'package:flutter/material.dart';

class AppTheme {
  // Colors from Stitches design
  static const Color primary = Color(0xFF256af4);
  static const Color backgroundLight = Color(0xFFf5f6f8);
  static const Color backgroundDark = Color(0xFF101622);
  static const Color textSecondary = Color(0xFF90a4cb);
  static const Color borderColor = Color(0xFF314368);
  
  // Material Colors
  static const Color cyan = Color(0xFF06b6d4);
  static const Color pink = Color(0xFFec4899);
  static const Color lime = Color(0xFF84cc16);
  static const Color gold = Color(0xFFFFD700);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: primary,
        background: backgroundDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      fontFamily: 'Spline Sans',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Spline Sans',
          fontWeight: FontWeight.w800,
          letterSpacing: -0.02,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Spline Sans',
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Spline Sans',
          color: textSecondary,
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        background: backgroundLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      fontFamily: 'Spline Sans',
    );
  }
}
