import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/modern_theme.dart';

/// Premium off-white sidebar — no blue gradient.
class ModernSidebar extends ConsumerWidget {
  final String currentRoute;

  const ModernSidebar({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: ModernTheme.sidebarBg,
        boxShadow: ModernTheme.sidebarShadow,
        border: Border(
          right: BorderSide(color: ModernTheme.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // ── Brand Header ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ModernTheme.lg,
              vertical: ModernTheme.lg,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: ModernTheme.primary,
                    borderRadius: BorderRadius.circular(ModernTheme.radiusSmall),
                  ),
                  child: const Icon(
                    Icons.grid_view_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: ModernTheme.sm + 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SmartERP',
                        style: ModernTheme.headingSmall.copyWith(
                          color: ModernTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Enterprise Platform',
                        style: ModernTheme.bodySmall.copyWith(
                          color: ModernTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(color: ModernTheme.divider, height: 1, thickness: 1),

          // ── Navigation ───────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: ModernTheme.sm,
                vertical: ModernTheme.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('MAIN', [
                    _buildItem(context, 'Dashboard', '/dashboard', Icons.grid_view_rounded),
                  ]),
                  _buildSection('OPERATIONS', [
                    _buildItem(context, 'Products', '/products', Icons.inventory_2_outlined),
                    _buildItem(context, 'Sales', '/sales', Icons.trending_up_rounded),
                    _buildItem(context, 'Purchases', '/purchases', Icons.shopping_cart_outlined),
                  ]),
                  _buildSection('FINANCIAL', [
                    _buildItem(context, 'Transactions', '/transactions', Icons.swap_horiz_rounded),
                    _buildItem(context, 'Bills & GST', '/bills', Icons.receipt_long_outlined),
                    _buildItem(context, 'Expenses', '/expenses', Icons.payments_outlined),
                    _buildItem(context, 'Payroll', '/payroll', Icons.people_outline_rounded),
                  ]),
                  _buildSection('INSIGHTS', [
                    _buildItem(context, 'Reports', '/reports', Icons.bar_chart_rounded),
                    _buildItem(context, 'Settings', '/settings', Icons.settings_outlined),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String label, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            ModernTheme.sm,
            ModernTheme.md,
            ModernTheme.sm,
            ModernTheme.xs,
          ),
          child: Text(
            label,
            style: ModernTheme.bodySmall.copyWith(
              color: ModernTheme.textMuted,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 1.0,
            ),
          ),
        ),
        ...items,
        const SizedBox(height: ModernTheme.xs),
      ],
    );
  }

  Widget _buildItem(
    BuildContext context,
    String label,
    String route,
    IconData icon,
  ) {
    final isActive = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: InkWell(
        onTap: () => GoRouter.of(context).go(route),
        borderRadius: BorderRadius.circular(ModernTheme.radiusMedium),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: ModernTheme.md,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isActive ? ModernTheme.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(ModernTheme.radiusMedium),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive ? ModernTheme.textPrimary : ModernTheme.textSecondary,
              ),
              const SizedBox(width: ModernTheme.sm + 2),
              Expanded(
                child: Text(
                  label,
                  style: ModernTheme.bodyMedium.copyWith(
                    color: isActive ? ModernTheme.textPrimary : ModernTheme.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ),
              if (isActive)
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: ModernTheme.textPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
