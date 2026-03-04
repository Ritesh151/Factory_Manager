import 'package:flutter/material.dart';

/// Premium off-white theme for SmartERP — 2026 SaaS style
class ModernTheme {
  // ─── Core Palette ────────────────────────────────────────────────────────────
  /// Warm charcoal — primary text / logo / active icons
  static const Color primary = Color(0xFF2D2D2D);
  static const Color primaryDark = Color(0xFF1A1A1A);
  /// Soft slate — secondary elements
  static const Color secondary = Color(0xFF6B7280);
  /// Semantic colours
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ─── Surface / Background ────────────────────────────────────────────────────
  /// Pure off-white page background
  static const Color background = Color(0xFFFAF9F6);
  /// Sidebar background — slightly warmer off-white
  static const Color sidebarBg = Color(0xFFF5F3EF);
  /// Card / widget surface — clean white
  static const Color surface = Color(0xFFFFFFFF);
  /// Active sidebar item highlight — warm beige
  static const Color accent = Color(0xFFEFEBE5);

  // ─── Text ────────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // ─── Border ──────────────────────────────────────────────────────────────────
  static const Color border = Color(0xFFE8E4DE);
  static const Color divider = Color(0xFFF0EDE8);

  // ─── Spacing ─────────────────────────────────────────────────────────────────
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // ─── Border Radius ───────────────────────────────────────────────────────────
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXL = 20.0;

  // ─── Typography ──────────────────────────────────────────────────────────────
  static const TextStyle headingLarge = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.3,
    height: 1.2,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.2,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.4,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    letterSpacing: 0.5,
    height: 1.4,
  );

  static ButtonStyle get outlinedButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: primary,
    side: const BorderSide(color: border),
    padding: const EdgeInsets.symmetric(horizontal: md, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMedium)),
    textStyle: labelMedium,
  );

  static ButtonStyle get elevatedButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: md, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMedium)),
    textStyle: labelMedium.copyWith(color: Colors.white),
    elevation: 0,
  );

  static InputDecoration inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: labelSmall,
    floatingLabelStyle: labelSmall.copyWith(color: primary),
    contentPadding: const EdgeInsets.symmetric(horizontal: md, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusSmall),
      borderSide: const BorderSide(color: border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusSmall),
      borderSide: const BorderSide(color: border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusSmall),
      borderSide: const BorderSide(color: primary, width: 1.5),
    ),
    filled: true,
    fillColor: surface,
  );

  // ─── Shadows ─────────────────────────────────────────────────────────────────
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 12,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 4,
      spreadRadius: 0,
      offset: Offset(0, 1),
    ),
  ];

  static List<BoxShadow> cardShadowLg = [
    BoxShadow(
      color: Color(0x10000000),
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 6),
    ),
  ];

  static List<BoxShadow> sidebarShadow = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(2, 0),
    ),
  ];
}
