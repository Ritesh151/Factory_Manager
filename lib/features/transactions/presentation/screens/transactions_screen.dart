import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/transaction_provider.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(filteredTransactionsProvider);
    final stats = ref.watch(transactionStatsProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards Row
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _StatCard(
                title: 'Total Sales',
                value: '₹${stats.totalSales.toStringAsFixed(2)}',
                icon: Icons.trending_up_rounded,
                color: AppColors.success,
              ),
              _StatCard(
                title: 'Total Purchases',
                value: '₹${stats.totalPurchases.toStringAsFixed(2)}',
                icon: Icons.shopping_cart_rounded,
                color: AppColors.info,
              ),
              _StatCard(
                title: 'Net Profit',
                value: '₹${stats.netProfit.toStringAsFixed(2)}',
                icon: Icons.account_balance_wallet_rounded,
                color: AppColors.primary,
              ),
              _StatCard(
                title: 'Transactions',
                value: '${stats.transactionCount}',
                icon: Icons.receipt_long_rounded,
                color: AppColors.accentTeal,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Filters Section
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _SearchField(ref: ref),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FilterDropdown(
                  label: 'Type',
                  value: ref.watch(transactionTypeFilterProvider),
                  items: const ['All', 'Sale', 'Purchase'],
                  onChanged: (value) {
                    ref.read(transactionTypeFilterProvider.notifier).state =
                        value == 'All' ? null : value?.toLowerCase();
                  },
                  ref: ref,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateFilterButton(
                  label: 'From Date',
                  onTap: () => _showDatePicker(
                    context,
                    (date) {
                      ref.read(transactionDateFromProvider.notifier).state =
                          date;
                    },
                  ),
                  ref: ref,
                  provider: transactionDateFromProvider,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateFilterButton(
                  label: 'To Date',
                  onTap: () => _showDatePicker(
                    context,
                    (date) {
                      ref.read(transactionDateToProvider.notifier).state = date;
                    },
                  ),
                  ref: ref,
                  provider: transactionDateToProvider,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(transactionSearchProvider.notifier).state = '';
                  ref.read(transactionTypeFilterProvider.notifier).state =
                      null;
                  ref.read(transactionDateFromProvider.notifier).state = null;
                  ref.read(transactionDateToProvider.notifier).state = null;
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reset'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Transactions Table
          _TransactionsTable(transactions: transactions),
        ],
      ),
    );
  }

  Future<void> _showDatePicker(
    BuildContext context,
    Function(DateTime) onSelected,
  ) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selected != null) {
      onSelected(selected);
    }
  }
}

/// Summary Stat Card Widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.textTheme.bodySmall?.copyWith(
                  color: AppColors.textMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Search Field Widget
class _SearchField extends ConsumerWidget {
  final WidgetRef ref;

  const _SearchField({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      onChanged: (value) {
        ref.read(transactionSearchProvider.notifier).state = value;
      },
      decoration: InputDecoration(
        hintText: 'Search by name, bill no, product...',
        prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMedium),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surfaceGlass,
      ),
    );
  }
}

/// Filter Dropdown Widget
class _FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;
  final WidgetRef ref;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value == null ? 'All' : value!.capitalize(),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surfaceGlass,
      ),
    );
  }
}

/// Date Filter Button Widget
class _DateFilterButton extends ConsumerWidget {
  final String label;
  final VoidCallback onTap;
  final WidgetRef ref;
  final StateProvider<DateTime?> provider;

  const _DateFilterButton({
    required this.label,
    required this.onTap,
    required this.ref,
    required this.provider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(provider);
    final dateStr = date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Select';

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Transactions Table Widget
class _TransactionsTable extends StatelessWidget {
  final List transactions;

  const _TransactionsTable({required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 48),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderLight),
          borderRadius: BorderRadius.circular(16),
          color: AppColors.surfaceGlass,
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.inbox_rounded,
                size: 48,
                color: AppColors.textLight,
              ),
              const SizedBox(height: 12),
              Text(
                'No transactions found',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(16),
        color: AppColors.surfaceGlass,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Bill No')),
            DataColumn(label: Text('Customer/Vendor')),
            DataColumn(label: Text('Product')),
            DataColumn(label: Text('Qty')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Payment')),
            DataColumn(label: Text('Type')),
          ],
          rows: transactions.map((txn) {
            return DataRow(
              cells: [
                DataCell(Text(DateFormat('dd/MM/yyyy').format(txn.date))),
                DataCell(Text(txn.billNo)),
                DataCell(Text(txn.customerVendorName)),
                DataCell(Text(txn.productName)),
                DataCell(Text(txn.quantity.toStringAsFixed(0))),
                DataCell(Text('₹${txn.grandTotal.toStringAsFixed(2)}')),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: txn.paymentStatus == 'completed'
                          ? AppColors.successLight
                          : AppColors.warningLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      txn.paymentStatus,
                      style: TextStyle(
                        color: txn.paymentStatus == 'completed'
                            ? AppColors.success
                            : AppColors.warning,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: txn.type == 'sale'
                          ? AppColors.successLight
                          : AppColors.infoLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      txn.type,
                      style: TextStyle(
                        color: txn.type == 'sale'
                            ? AppColors.success
                            : AppColors.info,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
