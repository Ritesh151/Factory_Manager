import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.title,
    this.actions,
  });
  final String title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Spacer(),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
