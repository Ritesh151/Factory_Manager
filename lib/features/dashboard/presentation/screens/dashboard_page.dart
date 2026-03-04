import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/company_info.dart';
import '../../widgets/dashboard_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to ${CompanyInfo.name}',
              style: AppTypography.textTheme.displayLarge?.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your business efficiently',
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 32),
            
            // ERP Modules Grid
            Text(
              'Business Modules',
              style: AppTypography.textTheme.headlineSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                // Products
                DashboardCard(
                  title: 'Products',
                  value: 'Manage',
                  icon: Icons.inventory_2,
                  color: AppColors.primary,
                  onTap: () => context.go('/products'),
                ),
                // Sales
                DashboardCard(
                  title: 'Sales',
                  value: 'Track',
                  icon: Icons.trending_up,
                  color: AppColors.success,
                  onTap: () => context.go('/sales'),
                ),
                // Purchase
                DashboardCard(
                  title: 'Purchase',
                  value: 'Orders',
                  icon: Icons.shopping_cart,
                  color: AppColors.warning,
                  onTap: () => context.go('/purchases'),
                ),
                // Payroll
                DashboardCard(
                  title: 'Payroll',
                  value: 'Manage',
                  icon: Icons.people,
                  color: AppColors.info,
                  onTap: () => context.go('/payroll'),
                ),
                // Transactions
                DashboardCard(
                  title: 'Transactions',
                  value: 'View All',
                  icon: Icons.swap_horiz,
                  color: AppColors.accentTeal,
                  onTap: () => context.go('/transactions'),
                ),
                // Expense
                DashboardCard(
                  title: 'Expense',
                  value: 'Track',
                  icon: Icons.money_off,
                  color: AppColors.error,
                  onTap: () => context.go('/expenses'),
                ),
                // Reports
                DashboardCard(
                  title: 'Reports',
                  value: 'Generate',
                  icon: Icons.assessment,
                  color: AppColors.primary,
                  onTap: () => context.go('/reports'),
                ),
                // Invoices
                DashboardCard(
                  title: 'Invoices',
                  value: 'Manage',
                  icon: Icons.receipt_long,
                  color: AppColors.success,
                  onTap: () => context.go('/invoices'),
                ),
                // Settings
                DashboardCard(
                  title: 'Settings',
                  value: 'Configure',
                  icon: Icons.settings,
                  color: AppColors.textSecondary,
                  onTap: () => context.go('/settings'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Recent Activity
            Text(
              'Recent Activity',
              style: AppTypography.textTheme.headlineSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.glassWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowSoft,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No recent activity',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPlaceholder,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your recent invoices, payments, and other activities will appear here.',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
