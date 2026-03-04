import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../layout/app_layout.dart';
import '../constants/app_constants.dart';

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Determine page title from current route
    final currentPath = GoRouterState.of(context).matchedLocation;
    final title = _getTitleFromPath(currentPath);

    return AppLayout(
      title: title,
      child: child,
    );
  }

  String _getTitleFromPath(String path) {
    if (path.startsWith('/dashboard')) return 'Dashboard';
    if (path.startsWith('/products')) return 'Products';
    if (path.startsWith('/sales')) return 'Sales';
    if (path.startsWith('/purchases')) return 'Purchases';
    if (path.startsWith('/transactions')) return 'Transactions';
    if (path.startsWith('/expenses')) return 'Expenses';
    if (path.startsWith('/payroll')) return 'Payroll';
    if (path.startsWith('/reports')) return 'Reports';
    if (path.startsWith('/settings')) return 'Settings';
    return AppConstants.appName;
  }
}
