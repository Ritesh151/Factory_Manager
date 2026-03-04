import 'package:flutter/material.dart';
import '../theme/modern_theme.dart';

/// Premium empty state widget — shown when a module has no data yet.
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: ModernTheme.accent,
                borderRadius: BorderRadius.circular(ModernTheme.radiusXL),
              ),
              child: Icon(
                icon,
                size: 36,
                color: ModernTheme.textSecondary,
              ),
            ),
            const SizedBox(height: ModernTheme.lg),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: ModernTheme.headingMedium.copyWith(
                color: ModernTheme.textPrimary,
              ),
            ),
            const SizedBox(height: ModernTheme.sm),

            // Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: ModernTheme.bodyLarge.copyWith(
                color: ModernTheme.textSecondary,
              ),
            ),

            // Action button (optional)
            if (buttonLabel != null && onAction != null) ...[
              const SizedBox(height: ModernTheme.xl),
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(buttonLabel!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ModernTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: ModernTheme.lg,
                      vertical: ModernTheme.sm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ModernTheme.radiusMedium),
                    ),
                    textStyle: ModernTheme.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
