import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/section_header.dart';

class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Employees / Payroll'),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(
              'Employee list and salary marking.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
