import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'app_card.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.trend,
    this.color,
  });
  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;
  final String? trend;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color ?? AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (trend != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              trend!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.success,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
