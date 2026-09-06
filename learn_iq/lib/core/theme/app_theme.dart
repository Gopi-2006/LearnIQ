import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Deep space & OLED dark background
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color card = Color(0xFF1C222E);
  static const Color cardElevated = Color(0xFF242C3D);
  static const Color border = Color(0xFF2D3748);

  // iQOO & Cyber Accent Palette
  static const Color iqooCyan = Color(0xFF00F0FF);
  static const Color iqooOrange = Color(0xFFFF6B00);
  static const Color duolingoGreen = Color(0xFF00E676);
  static const Color greenLight = Color(0xFF69F0AE);
  static const Color xpAmber = Color(0xFFFFB300);
  static const Color gemBlue = Color(0xFF2979FF);
  static const Color energyOrange = Color(0xFFFF9100);
  static const Color streakFlame = Color(0xFFFF3D00);
  static const Color misconceptionRed = Color(0xFFFF3D71);
  static const Color purpleAccent = Color(0xFFB388FF);

  // Text colors
  static const Color textPrimary = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF586069);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.iqooCyan,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.iqooCyan,
        secondary: AppColors.duolingoGreen,
        surface: AppColors.surface,
        error: AppColors.misconceptionRed,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
    );
  }
}
