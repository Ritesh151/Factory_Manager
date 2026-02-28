import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/expense/screens/expense_screen.dart';
import '../../features/payroll/screens/payroll_screen.dart';
import '../../features/products/screens/products_screen.dart';
import '../../features/purchase/screens/purchase_screen.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/sales/screens/sales_screen_fixed.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../router/shell_scaffold.dart';

final GlobalKey<NavigatorState> _rootKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: RouteNames.dashboard,
    routes: [
      GoRoute(
        path: RouteNames.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: RouteNames.dashboard,
            pageBuilder: (_, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.products,
            pageBuilder: (_, state) => const NoTransitionPage(
              child: ProductsScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.sales,
            pageBuilder: (_, state) => const NoTransitionPage(
              child: SalesScreenFixed(),
            ),
          ),
          GoRoute(
            path: RouteNames.purchases,
            pageBuilder: (_, state) => const NoTransitionPage(
              child: PurchaseScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.expenses,
            pageBuilder: (_, state) => const NoTransitionPage(
              child: ExpenseScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.payroll,
            pageBuilder: (_, state) => const NoTransitionPage(
              child: PayrollScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.reports,
            pageBuilder: (_, state) => const NoTransitionPage(
              child: ReportsScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.settings,
            pageBuilder: (_, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
}

class RouteNames {
  RouteNames._();
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String products = '/products';
  static const String sales = '/sales';
  static const String purchases = '/purchases';
  static const String expenses = '/expenses';
  static const String payroll = '/payroll';
  static const String reports = '/reports';
  static const String settings = '/settings';
}
