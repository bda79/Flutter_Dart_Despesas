import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._(); // Impede instanciação
  static const primary = Color(0xFF667EEA);
  static const secondary = Color(0xFF764BA2);

  static const success = Color(0xFF48BB78);
  static const danger = Color(0xFFF56565);

  static const background = Color(0xFFF7FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const text = Color(0xFF1A202C);
  static const muted = Color(0xFF718096);
}

class AppTheme {
  AppTheme._();

  static final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.surface,
    error: AppColors.danger,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.text,
    onError: Colors.white,
  );

  static final ThemeData lightTheme = ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    fontFamily: GoogleFonts.poppins().fontFamily,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      surfaceTintColor: AppColors.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primary.withAlpha(77)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primary.withAlpha(77)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      labelStyle: const TextStyle(color: AppColors.secondary),
      prefixIconColor: AppColors.secondary,
      suffixIconColor: AppColors.secondary,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      const TextTheme(
        titleLarge: TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: AppColors.text),
        bodyMedium: TextStyle(color: AppColors.text),
      ),
    ),
  );
}
