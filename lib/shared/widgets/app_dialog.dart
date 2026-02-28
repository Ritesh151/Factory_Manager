import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import 'primary_button.dart';
import 'secondary_button.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    this.content,
    this.actions,
    this.confirmLabel = 'OK',
    this.cancelLabel = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.showCancel = true,
  });
  final String title;
  final Widget? content;
  final List<Widget>? actions;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool showCancel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: content,
      actions: actions ??
          [
            if (showCancel)
              SecondaryButton(
                label: cancelLabel,
                onPressed: () {
                  onCancel?.call();
                  Navigator.of(context).pop();
                },
              ),
            PrimaryButton(
              label: confirmLabel,
              onPressed: () {
                onConfirm?.call();
                Navigator.of(context).pop();
              },
            ),
          ],
    );
  }
}
