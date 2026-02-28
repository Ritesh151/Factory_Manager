import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Design system theme. Material 3, Windows desktop optimized.
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          primaryContainer: AppColors.primaryContainer,
          onPrimaryContainer: AppColors.onPrimaryContainer,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          secondaryContainer: AppColors.secondaryContainer,
          onSecondaryContainer: AppColors.onSecondaryContainer,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          surfaceContainerHighest: AppColors.surfaceContainer,
          onSurfaceVariant: AppColors.onSurfaceVariant,
          error: AppColors.error,
          onError: AppColors.onError,
          outline: AppColors.outline,
        ),
        textTheme: AppTypography.textTheme,
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(AppSpacing.sm),
          clipBehavior: Clip.antiAlias,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        dataTableTheme: DataTableThemeData(
          headingRowColor: WidgetStateProperty.all(
            AppColors.surfaceContainer.withValues(alpha: 0.5),
          ),
          dataRowMinHeight: 40,
          dataRowMaxHeight: 48,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primaryDark,
          surface: AppColors.surfaceDark,
          onSurface: AppColors.onSurfaceDark,
        ),
        textTheme: AppTypography.textTheme,
      );
}
