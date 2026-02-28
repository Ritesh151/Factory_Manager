import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class DangerButton extends StatelessWidget {
  const DangerButton({
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
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: const BorderSide(color: AppColors.error),
      ),
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon!,
                const SizedBox(width: 8),
                Text(label),
              ],
            )
          : Text(label),
    );
  }
}
