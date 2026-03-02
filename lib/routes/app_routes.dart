import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../pages/dashboard_page.dart';
import '../pages/expenses_page.dart';
import '../pages/payroll_page.dart';
import '../pages/products_page.dart';
import '../pages/purchases_page.dart';
import '../pages/reports_page.dart';
import '../pages/sales_page.dart';
import '../pages/settings_page.dart';
import '../core/router/shell_scaffold.dart';

final GlobalKey<NavigatorState> _rootKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter() => GoRouter(
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
              pageBuilder: (_, state) => NoTransitionPage(child: const DashboardPage()),
            ),
            GoRoute(
              path: RouteNames.products,
              pageBuilder: (_, state) => NoTransitionPage(child: const ProductsPage()),
            ),
            GoRoute(
              path: RouteNames.sales,
              pageBuilder: (_, state) => NoTransitionPage(child: const SalesPage()),
            ),
            GoRoute(
              path: RouteNames.purchases,
              pageBuilder: (_, state) => NoTransitionPage(child: const PurchasesPage()),
            ),
            GoRoute(
              path: RouteNames.expenses,
              pageBuilder: (_, state) => NoTransitionPage(child: const ExpensesPage()),
            ),
            GoRoute(
              path: RouteNames.payroll,
              pageBuilder: (_, state) => NoTransitionPage(child: const PayrollPage()),
            ),
            GoRoute(
              path: RouteNames.reports,
              pageBuilder: (_, state) => NoTransitionPage(child: const ReportsPage()),
            ),
            GoRoute(
              path: RouteNames.settings,
              pageBuilder: (_, state) => NoTransitionPage(child: const SettingsPage()),
            ),
          ],
        ),
      ],
    );

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
