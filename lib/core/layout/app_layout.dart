import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Global application layout with premium glassmorphism sidebar and topbar.
/// Modern 2026 SaaS aesthetic
class AppLayout extends ConsumerWidget {
  final Widget child;
  final String title;

  const AppLayout({super.key, required this.child, this.title = 'Dashboard'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Row(
        children: [
          // Premium Glassmorphism Sidebar
          Container(
            width: 280,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surfaceGlass,
                  AppColors.surfaceGlassSecondary,
                ],
              ),
              border: Border(
                right: BorderSide(
                  color: AppColors.borderLight,
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowSoft,
                  blurRadius: 20,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company Logo & Info with glass effect
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.1),
                          AppColors.secondary.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.borderLight,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.business_center,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SmartERP',
                                style: AppTypography
                                    .textTheme.titleMedium
                                    ?.copyWith(
                                      color: AppColors.textDark,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              Text(
                                'Enterprise Platform',
                                style: AppTypography
                                    .textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.textLight,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Navigation Items
                  Text(
                    'MAIN',
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: AppColors.textLight,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _PremiumSidebarItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    selected: title == 'Dashboard',
                    onTap: () => context.go('/dashboard'),
                  ),
                  const SizedBox(height: 8),

                  const SizedBox(height: 20),
                  Text(
                    'OPERATIONS',
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: AppColors.textLight,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _PremiumSidebarItem(
                    icon: Icons.inventory_2_rounded,
                    label: 'Products',
                    selected: title == 'Products',
                    onTap: () => context.go('/products'),
                  ),
                  const SizedBox(height: 8),
                  _PremiumSidebarItem(
                    icon: Icons.shopping_cart_rounded,
                    label: 'Sales',
                    selected: title == 'Sales',
                    onTap: () => context.go('/sales'),
                  ),
                  const SizedBox(height: 8),
                  _PremiumSidebarItem(
                    icon: Icons.local_shipping_rounded,
                    label: 'Purchases',
                    selected: title == 'Purchases',
                    onTap: () => context.go('/purchases'),
                  ),
                  const SizedBox(height: 8),
                  _PremiumSidebarItem(
                    icon: Icons.receipt_long_rounded,
                    label: 'Transactions',
                    selected: title == 'Transactions',
                    onTap: () => context.go('/transactions'),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    'FINANCIAL',
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: AppColors.textLight,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _PremiumSidebarItem(
                    icon: Icons.attach_money_rounded,
                    label: 'Expenses',
                    selected: title == 'Expenses',
                    onTap: () => context.go('/expenses'),
                  ),
                  const SizedBox(height: 8),
                  _PremiumSidebarItem(
                    icon: Icons.groups_rounded,
                    label: 'Payroll',
                    selected: title == 'Payroll',
                    onTap: () => context.go('/payroll'),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    'INSIGHTS',
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: AppColors.textLight,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _PremiumSidebarItem(
                    icon: Icons.bar_chart_rounded,
                    label: 'Reports',
                    selected: title == 'Reports',
                    onTap: () => context.go('/reports'),
                  ),

                  // Removed Spacer() - can't use Spacer inside SingleChildScrollView
                  const SizedBox(height: 20), // Add some spacing instead

                  // Status Badge with glass effect
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accentTeal.withValues(alpha: 0.1),
                          AppColors.accentGlow.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.accentTeal.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.accentTeal,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentTeal.withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Connected',
                                style: AppTypography
                                    .textTheme.labelMedium
                                    ?.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              Text(
                                'Cloud Sync Active',
                                style: AppTypography
                                    .textTheme.labelSmall
                                    ?.copyWith(
                                      color: AppColors.textLight,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Settings Link
                  const SizedBox(height: 8),
                  _PremiumSidebarItem(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    selected: title == 'Settings',
                    onTap: () => context.go('/settings'),
                  ),
                  const SizedBox(height: 20), // Add bottom padding
                ],
              ),
            ),
          ),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Premium Top Bar with glass effect
                Container(
                  height: 76,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.surfaceGlass.withValues(alpha: 0.8),
                        AppColors.surfaceGlassSecondary.withValues(alpha: 0.7),
                      ],
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.borderLight,
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowSoft,
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.textTheme.displaySmall?.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          _TopBarIconButton(
                            icon: Icons.search_rounded,
                            onTap: () {},
                          ),
                          const SizedBox(width: 8),
                          _TopBarIconButton(
                            icon: Icons.notifications_rounded,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Content Area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Premium Sidebar Navigation Item with glass effect and hover animation
class _PremiumSidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PremiumSidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_PremiumSidebarItem> createState() => _PremiumSidebarItemState();
}

class _PremiumSidebarItemState extends State<_PremiumSidebarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selected) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            gradient: widget.selected
                ? LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.secondary.withValues(alpha: 0.1),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.selected
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(12),
              highlightColor: AppColors.primary.withValues(alpha: 0.1),
              hoverColor: AppColors.primary.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      widget.icon,
                      color: widget.selected
                          ? AppColors.primary
                          : AppColors.textLight,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: AppTypography.textTheme.titleSmall?.copyWith(
                          color: widget.selected
                              ? AppColors.primary
                              : AppColors.textMedium,
                          fontWeight:
                              widget.selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (widget.selected)
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Top Bar Icon Button with hover effect
class _TopBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopBarIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          highlightColor: AppColors.primary.withValues(alpha: 0.1),
          hoverColor: AppColors.primary.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: AppColors.textMedium,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}