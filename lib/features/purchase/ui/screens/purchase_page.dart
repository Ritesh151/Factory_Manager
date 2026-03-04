import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/modern_theme.dart';
import '../../../../core/widgets/empty_state_widget.dart';

class ModernPurchasePage extends ConsumerWidget {
  const ModernPurchasePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(ModernTheme.lg),
      child: Column(
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: ModernTheme.md),
                  decoration: BoxDecoration(
                    color: ModernTheme.surface,
                    borderRadius: BorderRadius.circular(ModernTheme.radiusMedium),
                    border: Border.all(color: ModernTheme.border),
                    boxShadow: ModernTheme.cardShadow,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search_rounded, size: 18, color: ModernTheme.textMuted),
                      SizedBox(width: ModernTheme.sm),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search purchases...',
                            hintStyle: TextStyle(color: ModernTheme.textMuted, fontSize: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: ModernTheme.md),
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Purchase'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ModernTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: ModernTheme.lg),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ModernTheme.radiusMedium),
                    ),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: ModernTheme.lg),

          // ── Content Area ─────────────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ModernTheme.surface,
                borderRadius: BorderRadius.circular(ModernTheme.radiusLarge),
                border: Border.all(color: ModernTheme.border),
                boxShadow: ModernTheme.cardShadow,
              ),
              child: const EmptyStateWidget(
                icon: Icons.shopping_cart_outlined,
                title: 'No Purchases Yet',
                subtitle: 'Record vendor bills and purchase orders here.',
                buttonLabel: 'Add Purchase',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
