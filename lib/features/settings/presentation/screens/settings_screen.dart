import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/section_header.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Settings'),
          const SizedBox(height: AppSpacing.lg),
          // No authentication - settings available to all users
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Data Storage'),
            subtitle: const Text('Firestore Cloud Database'),
          ),
        ],
      ),
    );
  }
}
