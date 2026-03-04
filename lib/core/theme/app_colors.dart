import 'package:flutter/material.dart';

/// Design system color palette - Off-White Glassmorphism Theme
/// Material 3 compatible with modern SaaS aesthetic
class AppColors {
  AppColors._();

  // ==================== GRADIENT & BACKGROUNDS ====================
  // Soft off-white/cream gradient background
  static const Color backgroundLight = Color(0xFFF8F6F3);
  static const Color backgroundCream = Color(0xFFFAF9F7);
  static const Color backgroundWarm = Color(0xFFFDFCF9);
  
  // Gradient stops for off-white gradient
  static const Color gradientStart = Color(0xFFFFFFFF);
  static const Color gradientEnd = Color(0xFFF5F3F1);

  // ==================== GLASSMORPHISM SURFACES ====================
  // Glass effect surfaces with transparency
  static const Color glassWhite = Color(0xFFFAFAFA);
  static const Color glassSemiTransparent = Color(0xFFFFFFFF); // Use with opacity
  static const Color glassLight = Color(0xFFF5F5F5);
  
  // Glass surface colors (used with blend modes and blur)
  static const Color surfaceGlass = Color(0xFFFFFBFF);
  static const Color surfaceGlassSecondary = Color(0xFFFAF8F6);

  // ==================== PRIMARY & BRAND ====================
  // Modern, refined primary color
  static const Color primary = Color(0xFF5D5BDB);
  static const Color onPrimary = Color(0xFFFFFFFF);
  
  // Primary variants for depth
  static const Color primaryLight = Color(0xFFB8B6E8);
  static const Color primaryDark = Color(0xFF4A4893);

  // ==================== SECONDARY ====================
  static const Color secondary = Color(0xFF9B8DD8);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryLight = Color(0xFFDAD3F0);
  static const Color secondaryDark = Color(0xFF6B5FA0);

  // ==================== ACCENT & HIGHLIGHT ====================
  // Subtle, elegant accent
  static const Color accentGlow = Color(0xFF06B6D4);
  static const Color accentWarm = Color(0xFFE8A05A);
  static const Color accentTeal = Color(0xFF14B8A6);

  // ==================== TEXT COLORS ====================
  // Text on light backgrounds
  static const Color textDark = Color(0xFF2D2C3E);
  static const Color textMedium = Color(0xFF6B6B6B);
  static const Color textLight = Color(0xFF9B9B9B);
  static const Color textPlaceholder = Color(0xFFC8C8C8);

  // ==================== SEMANTIC COLORS ====================
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF0284C7);
  static const Color infoLight = Color(0xFFE0F2FE);

  // ==================== BORDERS & DIVIDERS ====================
  static Color get border => const Color(0xFF000000).withValues(alpha: 0.08);
  static Color get borderLight => const Color(0xFF000000).withValues(alpha: 0.05);
  static Color get divider => const Color(0xFF000000).withValues(alpha: 0.06);

  // ==================== SHADOWS & DEPTH ====================
  static Color get shadowSoft => const Color(0xFF000000).withValues(alpha: 0.08);
  static Color get shadowMedium => const Color(0xFF000000).withValues(alpha: 0.12);
  static Color get shadowHard => const Color(0xFF000000).withValues(alpha: 0.16);

  // ==================== LEGACY (for compatibility) ====================
  static const Color primaryContainer = Color(0xFFB8B6E8);
  static const Color onPrimaryContainer = Color(0xFF2D2C3E);
  static const Color secondaryContainer = Color(0xFFDAD3F0);
  static const Color onSecondaryContainer = Color(0xFF3F3849);
  static const Color surface = Color(0xFFFAFAFA);
  static const Color surfaceDim = Color(0xFFF0F0F0);
  static const Color surfaceContainer = Color(0xFFF5F5F5);
  static const Color onSurface = Color(0xFF2D2C3E);
  static const Color onSurfaceVariant = Color(0xFF9B9B9B);
  static const Color outline = Color(0xFFBFBFBF);

  // ==================== DARK THEME ====================
  static const Color primaryDarkTheme = Color(0xFF8B89E8);
  static const Color surfaceDarkTheme = Color(0xFF1A1A2E);
  static const Color onSurfaceDarkTheme = Color(0xFFE8E8E8);
}
