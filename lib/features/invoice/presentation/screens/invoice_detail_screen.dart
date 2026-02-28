import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/section_header.dart';

class InvoiceDetailScreen extends StatelessWidget {
  const InvoiceDetailScreen({super.key, required this.invoiceId});
  final String invoiceId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Invoice #$invoiceId'),
          const SizedBox(height: AppSpacing.lg),
          Text('Invoice detail and PDF option.'),
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
