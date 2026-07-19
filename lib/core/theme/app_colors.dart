import 'package:flutter/material.dart';

// ─── Light theme colors (existing, unchanged) ─────────────────────────────────
abstract final class AppColors {
  static const Color primary = Color(0xFF1A2340);
  static const Color accent = Color(0xFFD4A017);
  static const Color accentLight = Color(0xFFE8B84B);
  static const Color background = Color(0xFFF8F9FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F2F8);
  static const Color textPrimary = Color(0xFF1A2340);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFADB5BD);
  static const Color inputBackground = Color(0xFFF0F2F8);
  static const Color inputBorder = Color(0xFFE2E6F0);
  static const Color inputIcon = Color(0xFF9BA8C0);
  static const Color divider = Color(0xFFE8ECF4);
  static const Color error = Color(0xFFE53E3E);
  static const Color white = Color(0xFFFFFFFF);
}

// ─── Dark theme colors (Vika DRX-inspired: near-black + gold) ────────────────
abstract final class DarkColors {
  static const Color primary = Color(0xFF0A0F1E); // deep navy-black
  static const Color accent = Color(0xFFD4A017); // gold (same)
  static const Color accentLight = Color(0xFFE8B84B);
  static const Color background = Color(0xFF060B16); // almost pure black
  static const Color surface = Color(0xFF0F1829); // card bg
  static const Color surfaceVariant = Color(
    0xFF1A2340,
  ); // slightly lighter surface
  static const Color surface2 = Color(0xFF162035); // elevated cards
  static const Color textPrimary = Color(0xFFEDF0FF); // near-white
  static const Color textSecondary = Color(0xFF8A95B0); // muted blue-grey
  static const Color textHint = Color(0xFF4A5568);
  static const Color inputBackground = Color(0xFF0F1829);
  static const Color inputBorder = Color(0xFF1E2D48);
  static const Color inputIcon = Color(0xFF4A5C7A);
  static const Color divider = Color(0xFF1A2B45);
  static const Color error = Color(0xFFE53E3E);
  static const Color white = Color(0xFFFFFFFF);
  // Gold gradient stops
  static const Color goldDark = Color(0xFFB8860B);
  static const Color goldLight = Color(0xFFFFD700);
}

// ─── Theme-aware color accessor ───────────────────────────────────────────────
// Use AppC.xxx anywhere in your app for auto-switching colors
class AppC {
  AppC._();

  static bool get isDark => _isDark;
  static bool _isDark = false;

  static void setDark(bool v) => _isDark = v;

  static Color get primary => _isDark ? DarkColors.primary : AppColors.primary;
  static Color get accent => _isDark ? DarkColors.accent : AppColors.accent;
  static Color get accentLight =>
      _isDark ? DarkColors.accentLight : AppColors.accentLight;
  static Color get background =>
      _isDark ? DarkColors.background : AppColors.background;
  static Color get surface => _isDark ? DarkColors.surface : AppColors.surface;
  static Color get surfaceVariant =>
      _isDark ? DarkColors.surfaceVariant : AppColors.surfaceVariant;
  static Color get textPrimary =>
      _isDark ? DarkColors.textPrimary : AppColors.textPrimary;
  static Color get textSecondary =>
      _isDark ? DarkColors.textSecondary : AppColors.textSecondary;
  static Color get textHint =>
      _isDark ? DarkColors.textHint : AppColors.textHint;
  static Color get inputBackground =>
      _isDark ? DarkColors.inputBackground : AppColors.inputBackground;
  static Color get inputBorder =>
      _isDark ? DarkColors.inputBorder : AppColors.inputBorder;
  static Color get inputIcon =>
      _isDark ? DarkColors.inputIcon : AppColors.inputIcon;
  static Color get divider => _isDark ? DarkColors.divider : AppColors.divider;
  static Color get error => AppColors.error;
  static Color get white => AppColors.white;
  static Color get cardBg => _isDark ? DarkColors.surface : AppColors.white;
  static Color get elevated => _isDark ? DarkColors.surface2 : AppColors.white;
}
