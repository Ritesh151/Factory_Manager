import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class DesignSystem {
  DesignSystem._();

  // ==================== BORDER RADIUS ====================
  static const double baseRadius = 16.0;
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 20.0;
  
  static const Radius baseRadiusGeometry = Radius.circular(baseRadius);
  static const Radius smallRadiusGeometry = Radius.circular(smallRadius);
  static const Radius mediumRadiusGeometry = Radius.circular(mediumRadius);
  static const Radius largeRadiusGeometry = Radius.circular(largeRadius);

  // ==================== ELEVATIONS ====================
  static const double elevationLow = 4.0;
  static const double elevationMedium = 8.0;
  static const double elevationHigh = 16.0;

  // ==================== SHADOWS ====================
  static List<BoxShadow> get subtleShadow => [
        BoxShadow(
          color: AppColors.shadowSoft,
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get mediumShadow => [
        BoxShadow(
          color: AppColors.shadowMedium,
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get strongShadow => [
        BoxShadow(
          color: AppColors.shadowHard,
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  // ==================== GLASSMORPHISM ====================
  /// Glass container with blur and transparency
  static BoxDecoration glassDecoration({
    Color borderColor = const Color(0x00000000),
    double borderWidth = 1.5,
    double blurRadius = 10.0,
  }) =>
      BoxDecoration(
        color: AppColors.surfaceGlass.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: subtleShadow,
      );

  static Widget glassContainer({
    required Widget child,
    Color borderColor = const Color(0x12000000),
    double blurRadius = 10.0,
    double borderRadius = 16.0,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.glassSemiTransparent.withValues(alpha: 0.7),
                AppColors.glassLight.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }

  // ==================== SEMANTIC COLORS ====================
  static Color get success => AppColors.success;
  static Color get warning => AppColors.warning;
  static Color get error => AppColors.error;
  static Color get info => AppColors.accentGlow;

  // ==================== SPACING HELPERS ====================
  static double spacingSm = AppSpacing.sm;
  static double spacingMd = AppSpacing.md;
  static double spacingLg = AppSpacing.lg;

  // ==================== GRADIENTS ====================
  static LinearGradient get primaryGradient => LinearGradient(
        colors: [AppColors.primary, AppColors.secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get backgroundGradient => LinearGradient(
        colors: [AppColors.gradientStart, AppColors.gradientEnd],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  static LinearGradient get accentGradient => LinearGradient(
        colors: [AppColors.accentTeal, AppColors.accentGlow],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // ==================== TRANSITIONS ====================
  static const Duration transitionFast = Duration(milliseconds: 200);
  static const Duration transitionNormal = Duration(milliseconds: 300);
  static const Duration transitionSlow = Duration(milliseconds: 500);
  static const Curve transitionCurve = Curves.easeInOut;
}

