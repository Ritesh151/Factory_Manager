import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// Shown when Firebase has not been configured (e.g. before running flutterfire configure).
class FirebaseNotConfiguredScreen extends StatelessWidget {
  const FirebaseNotConfiguredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Firebase not configured',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '1. Install Firebase CLI first:\n'
                '   npm install -g firebase-tools\n\n'
                '2. Add Dart global bin to PATH (e.g. in ~/.bashrc):\n'
                '   export PATH="\$PATH:\$HOME/.pub-cache/bin"\n\n'
                '3. Then run from project dir:\n'
                '   dart pub global activate flutterfire_cli\n'
                '   flutterfire configure',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Then restart the app.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
