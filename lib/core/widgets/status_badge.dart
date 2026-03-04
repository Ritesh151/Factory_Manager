import 'package:flutter/material.dart';
import '../design/design_system.dart';
import '../theme/app_colors.dart';

/// Small status badge with semantic colors.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final bool outline;

  const StatusBadge({super.key, required this.label, this.color, this.outline = false});

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: outline ? Colors.transparent : bg.withOpacity(0.14),
        border: outline ? Border.all(color: bg.withOpacity(0.18)) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }
}
