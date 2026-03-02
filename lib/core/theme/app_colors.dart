import 'package:flutter/material.dart';

/// Design system color palette. Material 3 compatible.
class AppColors {
  AppColors._();

  // Primary / brand
  static const Color primary = Color(0xFF6366F1);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Secondary
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // Accent glow
  static const Color accentGlow = Color(0xFF22D3EE);

  // Dark background / glass surfaces
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceGlass = Color(0xFF1E293B);

  // Borders (not const due to opacity, use getter)
  static Color get border => Colors.white.withOpacity(0.08);

  // Legacy values (kept for compatibility, but not used)
  static const Color primaryContainer = Color(0xFFBBDEFB);
  static const Color onPrimaryContainer = Color(0xFF0D47A1);
  static const Color secondaryContainer = Color(0xFFCFD8DC);
  static const Color onSecondaryContainer = Color(0xFF263238);
  static const Color surface = Color(0xFFFAFAFA);
  static const Color surfaceDim = Color(0xFFEEEEEE);
  static const Color surfaceContainer = Color(0xFFF5F5F5);
  static const Color onSurface = Color(0xFF212121);
  static const Color onSurfaceVariant = Color(0xFF616161);
  static const Color outline = Color(0xFF9E9E9E);

  // Error / Success / Warning
  static const Color error = Color(0xFFB71C1C);
  static const Color errorContainer = Color(0xFFFFCDD2);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57C00);

  // Dark theme
  static const Color primaryDark = Color(0xFF42A5F5);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color onSurfaceDark = Color(0xFFE0E0E0);
}
