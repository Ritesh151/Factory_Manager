import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../design/design_system.dart';

/// KPI card designed for enterprise dashboard.
class KpiCard extends StatelessWidget {
  final String title;
  final num value;
  final num? changePercent; // positive => up, negative => down
  final IconData? icon;
  final Color? color;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    this.changePercent,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.compactSimpleCurrency();
    final formatted = formatter.format(value);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(DesignSystem.baseRadius),
        boxShadow: DesignSystem.subtleShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.textTheme.titleSmall?.copyWith(color: Colors.white70)),
              const SizedBox(height: 8),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: value.toDouble()),
                duration: const Duration(milliseconds: 900),
                builder: (context, val, _) => Text(
                  formatter.format(val),
                  style: AppTypography.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
              if (changePercent != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Transform.rotate(
                      angle: changePercent! >= 0 ? 0 : 3.14,
                      child: Icon(
                        Icons.trending_up,
                        color: changePercent! >= 0 ? DesignSystem.success : DesignSystem.error,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${changePercent!.abs().toStringAsFixed(1)}%',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: changePercent! >= 0 ? DesignSystem.success : DesignSystem.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              ]
            ],
          ),
          if (icon != null)
            CircleAvatar(
              backgroundColor: color ?? AppColors.primary,
              child: Icon(icon, color: Colors.white, size: 18),
            )
        ],
      ),
    );
  }
}
