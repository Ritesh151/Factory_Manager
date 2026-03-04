import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/modern_theme.dart';
import '../widgets/modern_app_bar.dart';
import '../widgets/modern_sidebar.dart';

/// Production-ready main layout wrapper
/// Provides consistent sidebar, app bar, and content area for all pages
class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current route dynamically using GoRouter
    String currentRoute = '/dashboard'; // Default
    
    // Use GoRouterState.of(context) to get current location
    try {
      final state = GoRouterState.of(context);
      currentRoute = state.uri.path;
    } catch (e) {
      // Fallback to default if state is not available
      currentRoute = '/dashboard';
    }
    
    return Scaffold(
      backgroundColor: ModernTheme.background,
      body: Row(
        children: [
          // Sidebar with dynamic current route
          ModernSidebar(currentRoute: currentRoute),
          
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // AppBar
                ModernAppBar(
                  title: _getPageTitle(currentRoute),
                  onRefresh: () {
                    // Refresh functionality can be implemented per page
                  },
                ),
                
                // Page Content
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Get page title based on current route
  String _getPageTitle(String route) {
    switch (route) {
      case '/dashboard':
        return 'Dashboard';
      case '/products':
        return 'Products';
      case '/sales':
        return 'Sales';
      case '/purchases':
        return 'Purchases';
      case '/transactions':
        return 'Transactions';
      case '/expenses':
        return 'Expenses';
      case '/payroll':
        return 'Payroll';
      case '/reports':
        return 'Reports';
      case '/settings':
        return 'Settings';
      case '/invoices':
        return 'Invoices';
      default:
        return 'SmartERP';
    }
  }
}
