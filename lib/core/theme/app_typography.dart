import 'package:flutter/material.dart';

/// Typography scale for Windows desktop ERP.
class AppTypography {
  AppTypography._();

  static TextTheme get textTheme => TextTheme(
        displayLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        displayMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        displaySmall: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
}
