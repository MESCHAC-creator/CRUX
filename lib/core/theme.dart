import 'package:flutter/material.dart';

class CruxColors {
  CruxColors._();

  static const primary = Color(0xFF6C63FF);
  static const primaryDark = Color(0xFF4F46E5);
  static const primaryLight = Color(0xFF8B85FF);
  static const accent = Color(0xFF00D4AA);
  static const gradientStart = Color(0xFF6C63FF);
  static const gradientEnd = Color(0xFF00D4AA);
  static const backgroundLight = Color(0xFFF8F9FC);
  static const cardLight = Color(0xFFFFFFFF);
  static const borderLight = Color(0xFFE8EAF0);
  static const textPrimaryLight = Color(0xFF0F1117);
  static const textSecondaryLight = Color(0xFF6B7280);
  static const backgroundDark = Color(0xFF0C0E14);
  static const cardDark = Color(0xFF161920);
  static const borderDark = Color(0xFF252830);
  static const textPrimaryDark = Color(0xFFF1F2F6);
  static const textSecondaryDark = Color(0xFF9CA3AF);
}

class CruxTheme {
  CruxTheme._();

  static ThemeData light() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: CruxColors.primary,
      secondary: CruxColors.accent,
      surface: CruxColors.cardLight,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: CruxColors.textPrimaryLight,
    ),
    scaffoldBackgroundColor: CruxColors.backgroundLight,
    cardColor: CruxColors.cardLight,
    dividerColor: CruxColors.borderLight,
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: CruxColors.textPrimaryLight),
      titleTextStyle: TextStyle(
        color: CruxColors.textPrimaryLight,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 52,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -1.5,
        color: CruxColors.textPrimaryLight,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: CruxColors.textPrimaryLight,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: CruxColors.textPrimaryLight,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.6,
        color: CruxColors.textSecondaryLight,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.5,
        color: CruxColors.textSecondaryLight,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: CruxColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: CruxColors.textPrimaryLight,
        side: const BorderSide(color: CruxColors.borderLight),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: CruxColors.primaryLight,
      secondary: CruxColors.accent,
      surface: CruxColors.cardDark,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: CruxColors.textPrimaryDark,
    ),
    scaffoldBackgroundColor: CruxColors.backgroundDark,
    cardColor: CruxColors.cardDark,
    dividerColor: CruxColors.borderDark,
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: CruxColors.textPrimaryDark),
      titleTextStyle: TextStyle(
        color: CruxColors.textPrimaryDark,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 52,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -1.5,
        color: CruxColors.textPrimaryDark,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: CruxColors.textPrimaryDark,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: CruxColors.textPrimaryDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.6,
        color: CruxColors.textSecondaryDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.5,
        color: CruxColors.textSecondaryDark,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: CruxColors.primaryLight,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: CruxColors.textPrimaryDark,
        side: const BorderSide(color: CruxColors.borderDark),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}