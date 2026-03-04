import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/modern_theme.dart';
import '../../../../core/widgets/empty_state_widget.dart';

class ModernTransactionsPage extends ConsumerStatefulWidget {
  const ModernTransactionsPage({super.key});

  @override
  ConsumerState<ModernTransactionsPage> createState() =>
      _ModernTransactionsPageState();
}

class _ModernTransactionsPageState
    extends ConsumerState<ModernTransactionsPage> {
  String _searchQuery = '';
  String _selectedType = 'All';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Filter Bar ─────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(ModernTheme.lg),
          child: Row(
            children: [
              // Search field
              Expanded(
                child: Container(
                  height: 44,
                  padding:
                      const EdgeInsets.symmetric(horizontal: ModernTheme.md),
                  decoration: BoxDecoration(
                    color: ModernTheme.surface,
                    borderRadius:
                        BorderRadius.circular(ModernTheme.radiusMedium),
                    border: Border.all(color: ModernTheme.border),
                    boxShadow: ModernTheme.cardShadow,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded,
                          size: 18, color: ModernTheme.textMuted),
                      const SizedBox(width: ModernTheme.sm),
                      Expanded(
                        child: TextField(
                          onChanged: (v) =>
                              setState(() => _searchQuery = v),
                          decoration: const InputDecoration(
                            hintText: 'Search transactions...',
                            hintStyle: TextStyle(
                                color: ModernTheme.textMuted, fontSize: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: ModernTheme.md),

              // Type filter
              Container(
                height: 44,
                padding:
                    const EdgeInsets.symmetric(horizontal: ModernTheme.md),
                decoration: BoxDecoration(
                  color: ModernTheme.surface,
                  borderRadius:
                      BorderRadius.circular(ModernTheme.radiusMedium),
                  border: Border.all(color: ModernTheme.border),
                  boxShadow: ModernTheme.cardShadow,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedType,
                    style: ModernTheme.bodyMedium,
                    onChanged: (v) =>
                        setState(() => _selectedType = v!),
                    items: ['All', 'Sale', 'Purchase', 'Expense']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Content ────────────────────────────────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              ModernTheme.lg,
              0,
              ModernTheme.lg,
              ModernTheme.lg,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: ModernTheme.surface,
                borderRadius:
                    BorderRadius.circular(ModernTheme.radiusLarge),
                border: Border.all(color: ModernTheme.border),
                boxShadow: ModernTheme.cardShadow,
              ),
              child: const EmptyStateWidget(
                icon: Icons.swap_horiz_rounded,
                title: 'No Transactions Yet',
                subtitle:
                    'Sales, purchases and expenses will appear here automatically.',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
