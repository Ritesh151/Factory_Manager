import 'package:flutter/material.dart';
import '../theme/modern_theme.dart';

/// Clean off-white app bar — no blue badge, subtle shadow.
class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final VoidCallback? onRefresh;

  const ModernAppBar({
    super.key,
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ModernTheme.surface,
        border: Border(
          bottom: BorderSide(color: ModernTheme.divider, width: 1),
        ),
      ),
      child: AppBar(
        title: Text(
          title,
          style: ModernTheme.headingSmall.copyWith(
            color: ModernTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        actions: [
          if (onRefresh != null)
            _iconBtn(Icons.refresh_rounded, onRefresh!),
          _iconBtn(Icons.search_rounded, () {}),
          _iconBtn(Icons.notifications_none_rounded, () {}),
          if (actions != null) ...actions!,
          const SizedBox(width: ModernTheme.sm),
          // User avatar
          Container(
            margin: const EdgeInsets.symmetric(
              vertical: ModernTheme.sm,
              horizontal: ModernTheme.sm,
            ),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: ModernTheme.accent,
              borderRadius: BorderRadius.circular(ModernTheme.radiusMedium),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 18,
              color: ModernTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, size: 20, color: ModernTheme.textSecondary),
      onPressed: onPressed,
      splashRadius: 20,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
