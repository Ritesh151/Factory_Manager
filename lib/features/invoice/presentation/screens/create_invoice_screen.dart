import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/section_header.dart';

class CreateInvoiceScreen extends StatelessWidget {
  const CreateInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Create Invoice'),
          const SizedBox(height: AppSpacing.lg),
          const Text('Invoice form: customer, line items, GST calculation.'),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: () => context.pop(),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}
