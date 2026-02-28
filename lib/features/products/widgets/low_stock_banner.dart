import 'package:flutter/material.dart';

/// Banner showing low stock warning
class LowStockBanner extends StatelessWidget {
  final int count;

  const LowStockBanner({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Low Stock Alert',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$count products have low stock (less than 10 items)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
