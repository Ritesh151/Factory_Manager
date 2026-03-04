import 'package:flutter/material.dart';

/// Design system color palette - Pure Off-White Premium Theme
/// Modern SaaS dashboard aesthetic for 2026
class AppColors {
  AppColors._();

  // ==================== BACKGROUNDS ====================
  // Pure off-white/cream background
  static const Color backgroundLight = Color(0xFFFAF9F6);
  static const Color backgroundCream = Color(0xFFF5F3EF); // Sidebar bg
  
  // ==================== SURFACES ====================
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1C1C1E);
  static const Color accent = Color(0xFFEFEBE5); // Selection highlight

  // ==================== PRIMARY & BRAND ====================
  // Warm Charcoal / Premium Noir
  static const Color primary = Color(0xFF2D2D2D);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryLight = Color(0xFF4D4D4D);
  static const Color primaryDark = Color(0xFF1A1A1A);

  // ==================== SECONDARY ====================
  static const Color secondary = Color(0xFF6B7280);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // ==================== TEXT COLORS ====================
  static const Color textDark = Color(0xFF1C1C1E);
  static const Color textMedium = Color(0xFF4B5563);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textPlaceholder = Color(0xFFD1D5DB);

  // ==================== SEMANTIC COLORS ====================
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFE0F2FE);

  // ==================== BORDERS & DIVIDERS ====================
  static const Color border = Color(0xFFE8E4DE);
  static const Color borderLight = Color(0xFFF0EDE8);
  static const Color divider = Color(0xFFF3F4F6);

  // ==================== SHADOWS ====================
  static Color get shadowSoft => const Color(0xFF000000).withValues(alpha: 0.05);
  static Color get shadowMedium => const Color(0xFF000000).withValues(alpha: 0.1);
}
