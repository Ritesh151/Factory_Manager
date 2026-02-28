import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

class AppFormField extends StatelessWidget {
  const AppFormField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.readOnly = false,
    this.suffixIcon,
    this.onChanged,
  });
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;
  final bool readOnly;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines,
        readOnly: readOnly,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
