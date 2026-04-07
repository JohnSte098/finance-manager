// ─────────────────────────────────────────────────────────────────────────────
// lib/core/theme/app_theme.dart
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

class AppColors {
  // Background levels
  static const bg0 = Color(0xFF0A0E1A); // deepest bg
  static const bg1 = Color(0xFF111827); // card bg
  static const bg2 = Color(0xFF1C2535); // elevated card
  static const bg3 = Color(0xFF243044); // input / subtle

  // Accent palette – electric violet / cyan
  static const accent = Color(0xFF7C3AED);        // primary violet
  static const accentLight = Color(0xFF9F67FF);   // lighter violet
  static const accentGlow = Color(0x337C3AED);    // glow overlay

  static const cyan = Color(0xFF06B6D4);
  static const cyanGlow = Color(0x3306B6D4);

  // Semantic
  static const income  = Color(0xFF10B981); // green
  static const expense = Color(0xFFEF4444); // red
  static const warning = Color(0xFFF59E0B); // amber

  // Text
  static const textPrimary   = Color(0xFFF1F5F9);
  static const textSecondary = Color(0xFF94A3B8);
  static const textMuted     = Color(0xFF475569);

  // Category chip palette
  static const List<Color> categoryPalette = [
    Color(0xFF7C3AED), Color(0xFF06B6D4), Color(0xFF10B981),
    Color(0xFFF59E0B), Color(0xFFEF4444), Color(0xFFEC4899),
    Color(0xFF8B5CF6), Color(0xFF14B8A6), Color(0xFFF97316),
    Color(0xFF6366F1), Color(0xFF84CC16), Color(0xFF0EA5E9),
  ];
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg0,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      secondary: AppColors.cyan,
      surface: AppColors.bg1,
      error: AppColors.expense,
    ),
    cardTheme: CardThemeData(
      color: AppColors.bg1,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg0,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bg3,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF243044), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Outfit'),
      hintStyle: const TextStyle(color: AppColors.textMuted, fontFamily: 'Outfit'),
    ),
    textTheme: const TextTheme(
      displayLarge:  TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      displayMedium: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      headlineLarge: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      headlineMedium:TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      headlineSmall: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleLarge:    TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleMedium:   TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w500, color: AppColors.textPrimary),
      titleSmall:    TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w500, color: AppColors.textSecondary),
      bodyLarge:     TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary),
      bodyMedium:    TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary),
      bodySmall:     TextStyle(fontFamily: 'Outfit', color: AppColors.textMuted),
      labelLarge:    TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.bg1,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: CircleBorder(),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.bg3,
      selectedColor: AppColors.accentGlow,
      labelStyle: const TextStyle(fontFamily: 'Outfit', fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide.none,
    ),
  );
}
