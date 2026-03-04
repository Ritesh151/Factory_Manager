import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/screens/modern_dashboard_page.dart';
import '../../features/products/ui/screens/products_page.dart';
import '../../features/sales/ui/screens/sales_page.dart';
import '../../features/purchase/ui/screens/purchase_page.dart';
import '../../features/transactions/ui/screens/modern_transactions_page.dart';
import '../../features/expense/ui/screens/expense_page.dart';
import '../../features/payroll/ui/screens/payroll_page.dart';
import '../../features/reports/ui/screens/reports_page.dart';
import '../../features/settings/ui/screens/settings_page.dart';
import '../../features/invoice/ui/screens/create_invoice_page.dart';
import '../../features/invoice/ui/screens/bills_page.dart';
import '../layout/main_layout.dart';
import '../theme/modern_theme.dart';

/// Production-ready router configuration for SmartERP
class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/dashboard',
    routes: [
      // Shell route for main layout (sidebar + app bar + content)
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          // Dashboard
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const ModernDashboardPage(),
          ),
          
          // Products
          GoRoute(
            path: '/products',
            name: 'products',
            builder: (context, state) => const ModernProductsPage(),
          ),
          
          // Sales
          GoRoute(
            path: '/sales',
            name: 'sales',
            builder: (context, state) => const ModernSalesPage(),
          ),
          
          // Purchases
          GoRoute(
            path: '/purchases',
            name: 'purchases',
            builder: (context, state) => const ModernPurchasePage(),
          ),
          
          // Transactions
          GoRoute(
            path: '/transactions',
            name: 'transactions',
            builder: (context, state) => const ModernTransactionsPage(),
          ),
          
          // Expenses
          GoRoute(
            path: '/expenses',
            name: 'expenses',
            builder: (context, state) => const ModernExpensePage(),
          ),
          
          // Payroll
          GoRoute(
            path: '/payroll',
            name: 'payroll',
            builder: (context, state) => const ModernPayrollPage(),
          ),
          
          // Reports
          GoRoute(
            path: '/reports',
            name: 'reports',
            builder: (context, state) => const ModernReportsPage(),
          ),
          
          // Settings
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const ModernSettingsPage(),
          ),
          
          // Bills Tracking
          GoRoute(
            path: '/bills',
            name: 'bills',
            builder: (context, state) => const BillsPage(),
          ),
          
          // Create Invoice (Inside shell for consistency or outside if preferred)
          GoRoute(
            path: '/create-invoice',
            name: 'create-invoice',
            builder: (context, state) => const CreateInvoicePage(),
          ),
        ],
      ),
      
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: ModernTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: ModernTheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: ModernTheme.headingMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The requested page could not be found.',
              style: ModernTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernTheme.primary.withValues(alpha: 0.8),
              ),
              child: Text(
                'Go to Dashboard',
                style: ModernTheme.headingSmall,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
