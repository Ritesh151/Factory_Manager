import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/router/app_router.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({
    Key? key,
    required this.currentPath,
    required this.onNavigate,
  }) : super(key: key);

  final String currentPath;
  final ValueChanged<String> onNavigate;

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _collapsed = false;
  final Duration _animDuration = const Duration(milliseconds: 300);

  static final _items = <_SidebarItem>[
    _SidebarItem('Dashboard', Icons.dashboard_outlined, RouteNames.dashboard),
    _SidebarItem('Products', Icons.inventory_2_outlined, RouteNames.products),
    _SidebarItem('Sales', Icons.receipt_long_outlined, RouteNames.sales),
    _SidebarItem('Purchases', Icons.shopping_cart_outlined, RouteNames.purchases),
    _SidebarItem('Expenses', Icons.payments_outlined, RouteNames.expenses),
    _SidebarItem('Payroll', Icons.badge_outlined, RouteNames.payroll),
    _SidebarItem('Reports', Icons.assessment_outlined, RouteNames.reports),
    _SidebarItem('Settings', Icons.settings_outlined, RouteNames.settings),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isDesktop = constraints.maxWidth >= 900;
      final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 900;

      if (!isDesktop && !isTablet) {
        // mobile -> drawer
        return Drawer(
          child: _buildList(200),
        );
      }

      // desktop/tablet side panel
      return AnimatedContainer(
        duration: _animDuration,
        width: _collapsed ? 64 : 250,
        decoration: BoxDecoration(
          color: AppColors.surfaceGlass.withOpacity(0.3),
          border: Border(right: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          children: [
            IconButton(
              icon: Icon(_collapsed ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                  color: Colors.white),
              onPressed: () => setState(() => _collapsed = !_collapsed),
            ),
            Expanded(child: _buildList(_collapsed ? 64 : 250)),
          ],
        ),
      );
    });
  }

  Widget _buildList(double width) {
    return ListView(
      padding: EdgeInsets.zero,
      children: _items.map((item) {
        final selected = widget.currentPath == item.route ||
            widget.currentPath.startsWith(item.route);
        return MouseRegion(
          onEnter: (_) => setState(() => item.hovering = true),
          onExit: (_) => setState(() => item.hovering = false),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: _animDuration,
                left: 0,
                top: 0,
                bottom: 0,
                width: selected ? 4 : 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.secondary,
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: _animDuration,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  gradient: selected && !item.hovering
                      ? LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.6),
                            AppColors.secondary.withOpacity(0.6),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                ),
                child: ListTile(
                  leading: Icon(
                    selected ? item.selectedIcon : item.icon,
                    color: selected ? AppColors.accentGlow : Colors.white70,
                  ),
                  title: width > 100
                      ? Text(
                          item.label,
                          style: TextStyle(
                            color: selected
                                ? AppColors.accentGlow
                                : Colors.white70,
                          ),
                        )
                      : null,
                  onTap: () => widget.onNavigate(item.route),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SidebarItem {
  _SidebarItem(this.label, this.icon, this.route)
      : selectedIcon = icon;

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
  bool hovering = false;
}
