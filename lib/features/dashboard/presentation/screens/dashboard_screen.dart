import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firebase_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../../reports/services/reports_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late final ReportsService _reportsService;
  DashboardSummary? _summary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final firebaseService = FirebaseService();
    _reportsService = ReportsService();
    _reportsService.initialize(firebaseService);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final summary = await _reportsService.getDashboardSummary();
      if (mounted) {
        setState(() {
          _summary = summary;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dashboard: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = _summary ?? DashboardSummary.zero();

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SectionHeader(title: 'Dashboard'),
                    FilledButton.icon(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                
                // Summary cards
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    StatCard(
                      title: 'Total Sales',
                      value: '₹${summary.totalSales.toStringAsFixed(2)}',
                      icon: Icons.trending_up,
                      color: Colors.green,
                    ),
                    StatCard(
                      title: 'Total Purchases',
                      value: '₹${summary.totalPurchases.toStringAsFixed(2)}',
                      icon: Icons.shopping_cart,
                      color: Colors.orange,
                    ),
                    StatCard(
                      title: 'Total Expenses',
                      value: '₹${summary.totalExpenses.toStringAsFixed(2)}',
                      icon: Icons.payments,
                      color: Colors.red,
                    ),
                    StatCard(
                      title: 'Salary Paid',
                      value: '₹${summary.totalPayroll.toStringAsFixed(2)}',
                      icon: Icons.badge,
                      color: Colors.blue,
                    ),
                    StatCard(
                      title: 'GST Collected',
                      value: '₹${summary.gstCollected.toStringAsFixed(2)}',
                      icon: Icons.account_balance,
                      color: Colors.purple,
                    ),
                    StatCard(
                      title: 'Net Profit',
                      value: '₹${summary.netProfit.toStringAsFixed(2)}',
                      icon: Icons.account_balance,
                      color: summary.netProfit >= 0 ? Colors.green : Colors.red,
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Profit/Loss Summary
                Card(
                  color: summary.netProfit >= 0 
                      ? Colors.green.withOpacity(0.1) 
                      : Colors.red.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Monthly Profit Summary',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sales - Purchases - Expenses - Payroll',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text(
                                    '₹${summary.netProfit.abs().toStringAsFixed(2)}',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: summary.netProfit >= 0 
                                          ? Colors.green 
                                          : Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    summary.netProfit >= 0 
                                        ? Icons.trending_up 
                                        : Icons.trending_down,
                                    color: summary.netProfit >= 0 
                                        ? Colors.green 
                                        : Colors.red,
                                  ),
                                ],
                              ),
                              Text(
                                summary.netProfit >= 0 
                                    ? 'Profitable Month' 
                                    : 'Loss Month',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: summary.netProfit >= 0 
                                      ? Colors.green 
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: summary.netProfit >= 0 
                                ? Colors.green.withOpacity(0.2) 
                                : Colors.red.withOpacity(0.2),
                          ),
                          child: Center(
                            child: Icon(
                              summary.netProfit >= 0 
                                  ? Icons.check_circle 
                                  : Icons.warning,
                              size: 40,
                              color: summary.netProfit >= 0 
                                  ? Colors.green 
                                  : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
