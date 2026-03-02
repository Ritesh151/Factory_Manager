import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Design system theme. Material 3, Windows desktop optimized.
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surfaceGlass,
          background: AppColors.backgroundDark,
          error: AppColors.error,
          outline: AppColors.border,
        ),
        textTheme: AppTypography.textTheme,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // default corner radius 20
        // cardTheme removed to avoid SDK type mismatch across Flutter versions
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surfaceGlass,
          background: AppColors.backgroundDark,
          error: AppColors.error,
          outline: AppColors.border,
        ),
        textTheme: AppTypography.textTheme,
      );
}
