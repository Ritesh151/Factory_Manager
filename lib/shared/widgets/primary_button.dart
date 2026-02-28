import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.minWidth,
  });
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final double? minWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: minWidth ?? 160,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : (icon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      icon!,
                      const SizedBox(width: AppSpacing.sm),
                      Text(label),
                    ],
                  )
                : Text(label)),
      ),
    );
  }
}
