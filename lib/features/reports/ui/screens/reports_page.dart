import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/modern_theme.dart';
import '../../../../core/widgets/empty_state_widget.dart';

class ModernReportsPage extends ConsumerWidget {
  const ModernReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(ModernTheme.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reports', style: ModernTheme.headingMedium),
          const SizedBox(height: ModernTheme.xs),
          Text(
            'Generate and export business insights.',
            style: ModernTheme.bodyLarge,
          ),
          const SizedBox(height: ModernTheme.xl),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ModernTheme.surface,
                borderRadius: BorderRadius.circular(ModernTheme.radiusLarge),
                border: Border.all(color: ModernTheme.border),
                boxShadow: ModernTheme.cardShadow,
              ),
              child: const EmptyStateWidget(
                icon: Icons.bar_chart_rounded,
                title: 'No Reports Yet',
                subtitle:
                    'Reports will be generated once you have recorded sales, expenses or payroll.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
