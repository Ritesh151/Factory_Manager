import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class SmartErpApp extends ConsumerWidget {
  const SmartErpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = createAppRouter();
    return MaterialApp.router(
      title: 'SmartERP',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
