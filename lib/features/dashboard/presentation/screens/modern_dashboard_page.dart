import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/modern_theme.dart';
import '../../../../core/providers/finance_provider.dart';
import '../../../../core/utils/gst_utils.dart';
import '../../../../core/constants/company_info.dart';

/// Dynamic dashboard showing real-time financial KPIs.
class ModernDashboardPage extends ConsumerWidget {
  const ModernDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(ModernTheme.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Welcome ────────────────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Financial Overview', style: ModernTheme.headingLarge),
              const SizedBox(height: 4),
              Text(
                'Real-time business performance metrics.',
                style: ModernTheme.bodyLarge.copyWith(color: ModernTheme.textMuted),
              ),
            ],
          ),
          const SizedBox(height: ModernTheme.xl),

          // ── Primary Financial Grid ─────────────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: constraints.maxWidth > 900 ? 5 : (constraints.maxWidth > 600 ? 3 : 2),
                crossAxisSpacing: ModernTheme.md,
                mainAxisSpacing: ModernTheme.md,
                childAspectRatio: 1.4,
                children: [
                  _kpiCard('Total Sales', finance.totalSales, Icons.trending_up_rounded, ModernTheme.success),
                  _kpiCard('Total Profit', finance.totalProfit, Icons.account_balance_wallet_outlined, Colors.purple),
                  _kpiCard('Total Expenses', finance.totalExpenses, Icons.receipt_long_outlined, ModernTheme.error),
                  _kpiCard('Total Salary', finance.totalSalaryPaid, Icons.people_outline_rounded, ModernTheme.info),
                  _kpiCard('Total Purchase', finance.totalPurchases, Icons.shopping_cart_outlined, ModernTheme.warning),
                ],
              );
            },
          ),
          const SizedBox(height: ModernTheme.xl + 10),

          // ── Quick Access ───────────────────────────────────────────────
          Text('Quick Management', style: ModernTheme.headingMedium),
          const SizedBox(height: ModernTheme.md),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: ModernTheme.md,
            mainAxisSpacing: ModernTheme.md,
            childAspectRatio: 2.8,
            children: [
              _quickLink(context, 'Create Invoice', Icons.add_rounded, '/create-invoice', isPrimary: true),
              _quickLink(context, 'View All Bills', Icons.receipt_long_rounded, '/bills'),
              _quickLink(context, 'Manage Products', Icons.inventory_2_outlined, '/products'),
              _quickLink(context, 'Add Purchase', Icons.shopping_bag_outlined, '/purchases'),
              _quickLink(context, 'Expenses', Icons.payments_outlined, '/expenses'),
              _quickLink(context, 'Payroll', Icons.badge_outlined, '/payroll'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kpiCard(String label, double value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(ModernTheme.lg),
      decoration: BoxDecoration(
        color: ModernTheme.surface,
        borderRadius: BorderRadius.circular(ModernTheme.radiusLarge),
        border: Border.all(color: ModernTheme.border),
        boxShadow: ModernTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ModernTheme.radiusSmall),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: ModernTheme.bodySmall.copyWith(color: ModernTheme.textMuted)),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  GSTUtils.formatCurrency(value),
                  style: ModernTheme.headingSmall.copyWith(
                    color: ModernTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickLink(BuildContext context, String label, IconData icon, String route, {bool isPrimary = false}) {
    return InkWell(
      onTap: () => context.go(route),
      borderRadius: BorderRadius.circular(ModernTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: ModernTheme.md),
        decoration: BoxDecoration(
          color: isPrimary ? ModernTheme.primary.withValues(alpha: 0.05) : ModernTheme.surface,
          borderRadius: BorderRadius.circular(ModernTheme.radiusMedium),
          border: Border.all(color: isPrimary ? ModernTheme.primary.withValues(alpha: 0.2) : ModernTheme.border),
          boxShadow: ModernTheme.cardShadow,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isPrimary ? ModernTheme.primary : ModernTheme.textSecondary),
            const SizedBox(width: ModernTheme.sm + 2),
            Text(label, style: ModernTheme.labelMedium.copyWith(color: isPrimary ? ModernTheme.primary : ModernTheme.textPrimary, fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
