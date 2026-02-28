import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon!,
                const SizedBox(width: AppSpacing.sm),
                Text(label),
              ],
            )
          : Text(label),
    );
  }
}
