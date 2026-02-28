import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      child: child,
    );
    if (onTap != null) {
      return Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: content,
        ),
      );
    }
    return Card(child: content);
  }
}
