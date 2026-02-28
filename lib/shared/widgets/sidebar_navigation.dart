import 'package:flutter/material.dart';

import '../../core/router/app_router.dart';

class SidebarNavigation extends StatelessWidget {
  const SidebarNavigation({
    super.key,
    required this.currentPath,
    required this.onNavigate,
  });
  final String currentPath;
  final void Function(String path) onNavigate;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      extended: true,
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) => onNavigate(_paths[index]),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2),
          label: Text('Products'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: Text('Sales'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.shopping_cart_outlined),
          selectedIcon: Icon(Icons.shopping_cart),
          label: Text('Purchases'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.payments_outlined),
          selectedIcon: Icon(Icons.payments),
          label: Text('Expenses'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.badge_outlined),
          selectedIcon: Icon(Icons.badge),
          label: Text('Payroll'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.assessment_outlined),
          selectedIcon: Icon(Icons.assessment),
          label: Text('Reports'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
      ],
    );
  }

  static const _paths = [
    RouteNames.dashboard,
    RouteNames.products,
    RouteNames.sales,
    RouteNames.purchases,
    RouteNames.expenses,
    RouteNames.payroll,
    RouteNames.reports,
    RouteNames.settings,
  ];

  int get _selectedIndex {
    final i = _paths.indexOf(currentPath);
    if (i >= 0) return i;
    if (currentPath.startsWith(RouteNames.sales)) return 2;
    return 0;
  }
}
