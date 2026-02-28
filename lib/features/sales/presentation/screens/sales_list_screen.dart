import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/section_header.dart';

class SalesListScreen extends StatelessWidget {
  const SalesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Sales / Invoices',
            action: PrimaryButton(
              label: 'Create Invoice',
              onPressed: () => context.push('/sales/create'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(
              'Sales history and invoices.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
