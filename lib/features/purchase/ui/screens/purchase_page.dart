import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/modern_theme.dart';
import '../../providers/purchase_providers.dart';
import '../../models/purchase_model.dart';

class ModernPurchasePage extends ConsumerStatefulWidget {
  const ModernPurchasePage({super.key});

  @override
  ConsumerState<ModernPurchasePage> createState() => _ModernPurchasePageState();
}

class _ModernPurchasePageState extends ConsumerState<ModernPurchasePage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final purchasesAsync = ref.watch(purchasesStreamProvider);
    
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
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, size: 18, color: ModernTheme.textMuted),
                      const SizedBox(width: ModernTheme.sm),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search purchases...',
                            hintStyle: TextStyle(color: ModernTheme.textMuted, fontSize: 14),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.toLowerCase();
                            });
                          },
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
                  onPressed: () => _showAddPurchaseDialog(),
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
            child: purchasesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading purchases',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              data: (purchases) {
                final filteredPurchases = purchases.where((purchase) {
                  return purchase.supplierName.toLowerCase().contains(_searchQuery) ||
                         purchase.id.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredPurchases.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 64, color: ModernTheme.textMuted),
                        SizedBox(height: 16),
                        Text(
                          'No Purchases Yet',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: ModernTheme.textMuted),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Record vendor bills and purchase orders here.',
                          style: TextStyle(color: ModernTheme.textMuted),
                        ),
                      ],
                    ),
                  );
                }

                return _buildPurchasesList(filteredPurchases);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchasesList(List<PurchaseModel> purchases) {
    return Container(
      decoration: BoxDecoration(
        color: ModernTheme.surface,
        borderRadius: BorderRadius.circular(ModernTheme.radiusLarge),
        border: Border.all(color: ModernTheme.border),
        boxShadow: ModernTheme.cardShadow,
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(ModernTheme.md),
        itemCount: purchases.length,
        itemBuilder: (context, index) {
          final purchase = purchases[index];
          return _buildPurchaseCard(purchase);
        },
      ),
    );
  }

  Widget _buildPurchaseCard(PurchaseModel purchase) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final dateFormat = DateFormat('dd MMM yyyy');
    
    return Container(
      margin: const EdgeInsets.only(bottom: ModernTheme.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ModernTheme.radiusMedium),
        border: Border.all(color: ModernTheme.border),
        boxShadow: ModernTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(ModernTheme.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        purchase.id,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ModernTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        purchase.supplierName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor('pending'),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'PENDING',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Details Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currencyFormat.format(purchase.totalAmount),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ModernTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(purchase.purchaseDate),
                        style: const TextStyle(
                          fontSize: 12,
                          color: ModernTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Items: ${purchase.items.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: ModernTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: ${currencyFormat.format(purchase.totalAmount)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: ModernTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Actions Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _viewPurchaseDetails(purchase),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _editPurchase(purchase),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _deletePurchase(purchase),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showAddPurchaseDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Purchase dialog coming soon!')),
    );
  }

  void _viewPurchaseDetails(PurchaseModel purchase) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing purchase: ${purchase.id}')),
    );
  }

  void _editPurchase(PurchaseModel purchase) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing purchase: ${purchase.id}')),
    );
  }

  void _deletePurchase(PurchaseModel purchase) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Purchase'),
        content: Text('Are you sure you want to delete purchase ${purchase.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(purchaseServiceProvider).deletePurchase(purchase.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Purchase deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting purchase: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
