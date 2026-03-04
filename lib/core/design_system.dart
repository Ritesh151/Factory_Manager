import 'package:flutter/material.dart';
import 'theme/app_colors.dart';

/// Centralized design tokens for the application.
/// - 8px spacing system
/// - border radii
/// - elevation / shadows
/// - semantic colors
class DesignSystem {
  DesignSystem._();

  // Spacing (8px base)
  static const double base = 8.0;
  static const double xs = base * 0.5; // 4
  static const double sm = base; // 8
  static const double md = base * 2; // 16
  static const double lg = base * 3; // 24
  static const double xl = base * 4; // 32

  // Standard radii
  static const BorderRadiusGeometry radiusSmall = BorderRadius.all(Radius.circular(8));
  static const BorderRadiusGeometry radius = BorderRadius.all(Radius.circular(16));
  static const BorderRadiusGeometry radiusLarge = BorderRadius.all(Radius.circular(24));

  // Elevation shadows tuned for desktop
  static List<BoxShadow> cardShadow({Color? color}) {
    final shadowColor = color ?? Colors.black.withOpacity(0.45);
    return [
      BoxShadow(
        color: shadowColor.withOpacity(0.18),
        offset: const Offset(0, 6),
        blurRadius: 24,
      ),
      BoxShadow(
        color: shadowColor.withOpacity(0.08),
        offset: const Offset(0, 2),
        blurRadius: 6,
      ),
    ];
  }

  // Semantic colors mapped to design tokens
  static Color success(BuildContext context) => AppColors.success;
  static Color warning(BuildContext context) => AppColors.warning;
  static Color error(BuildContext context) => AppColors.error;
  static Color info(BuildContext context) => AppColors.accentGlow;
}
