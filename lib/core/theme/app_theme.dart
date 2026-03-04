import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Design system theme. Material 3, Off-White Glassmorphism
/// Modern SaaS dashboard aesthetic
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          primary: AppColors.primary,
          primaryContainer: AppColors.primaryLight,
          secondary: AppColors.secondary,
          secondaryContainer: AppColors.secondaryLight,
          surface: AppColors.surfaceGlass,
          onSurface: AppColors.textDark,
          error: AppColors.error,
          errorContainer: AppColors.errorLight,
          outline: AppColors.border,
        ),
        textTheme: AppTypography.textTheme.apply(
          bodyColor: AppColors.textDark,
          displayColor: AppColors.textDark,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Card theme with glass effect
        cardTheme: CardThemeData(
          color: AppColors.surfaceGlass,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.borderLight),
          ),
        ),
        // Button themes with modern styling
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.border, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        // Input decoration for text fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceGlass,
          hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.textPlaceholder,
          ),
          labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.textMedium,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        // AppBar theme
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surfaceGlass,
          foregroundColor: AppColors.textDark,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        // Bottom navigation bar theme
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceGlass,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textLight,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      );

}
