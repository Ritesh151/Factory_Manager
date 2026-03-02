import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firebase_service.dart';
import '../services/reports_service.dart';

/// Reports screen with business analytics
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
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
          SnackBar(content: Text('Error loading reports: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1300,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: constraints.maxWidth > 1200 ? 24.0 : 
                                      constraints.maxWidth > 800 ? 20.0 : 16.0,
                        vertical: 24.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(theme),
                          const SizedBox(height: 24),
                          
                          // Scrollable content
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Summary cards
                                  _buildSummaryGrid(theme, constraints),
                                  const SizedBox(height: 24),
                                  
                                  // Net Profit card
                                  _buildProfitCard(theme),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reports & Analytics",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Business performance insights",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        FilledButton.icon(
          onPressed: _loadData,
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryGrid(ThemeData theme, BoxConstraints constraints) {
    final summary = _summary ?? DashboardSummary.zero();
    
    // Responsive grid configuration
    int crossAxisCount;
    double childAspectRatio;
    
    if (constraints.maxWidth > 1200) {
      crossAxisCount = 3;
      childAspectRatio = 1.6;
    } else if (constraints.maxWidth > 800) {
      crossAxisCount = 2;
      childAspectRatio = 1.8;
    } else {
      crossAxisCount = 1;
      childAspectRatio = 2.2;
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: childAspectRatio,
      children: [
        _buildMetricCard(
          'Total Sales',
          '₹${summary.totalSales.toStringAsFixed(2)}',
          Icons.trending_up,
          Colors.green,
          theme,
        ),
        _buildMetricCard(
          'Total Purchases',
          '₹${summary.totalPurchases.toStringAsFixed(2)}',
          Icons.shopping_cart,
          Colors.orange,
          theme,
        ),
        _buildMetricCard(
          'Total Expenses',
          '₹${summary.totalExpenses.toStringAsFixed(2)}',
          Icons.receipt,
          Colors.red,
          theme,
        ),
        _buildMetricCard(
          'Payroll',
          '₹${summary.totalPayroll.toStringAsFixed(2)}',
          Icons.people,
          Colors.blue,
          theme,
        ),
        _buildMetricCard(
          'GST Collected',
          '₹${summary.gstCollected.toStringAsFixed(2)}',
          Icons.account_balance,
          Colors.purple,
          theme,
        ),
        _buildMetricCard(
          'Net Profit',
          '₹${summary.netProfit.toStringAsFixed(2)}',
          Icons.attach_money,
          summary.netProfit >= 0 ? Colors.green : Colors.red,
          theme,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitCard(ThemeData theme) {
    final summary = _summary ?? DashboardSummary.zero();
    final isProfitable = summary.netProfit >= 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: isProfitable ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              // Mobile layout - Column
              return Column(
                children: [
                  Text(
                    'Net Profit Summary',
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
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isProfitable ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                    ),
                    child: Center(
                      child: Icon(
                        isProfitable ? Icons.check_circle : Icons.warning,
                        size: 40,
                        color: isProfitable ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '₹${summary.netProfit.abs().toStringAsFixed(2)}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isProfitable ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isProfitable ? Icons.trending_up : Icons.trending_down,
                        color: isProfitable ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isProfitable ? 'Profitable Month' : 'Loss Month',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isProfitable ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              );
            } else {
              // Desktop layout - Row
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Net Profit Summary',
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
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              '₹${summary.netProfit.abs().toStringAsFixed(2)}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isProfitable ? Colors.green : Colors.red,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isProfitable ? Icons.trending_up : Icons.trending_down,
                              color: isProfitable ? Colors.green : Colors.red,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isProfitable ? 'Profitable Month' : 'Loss Month',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isProfitable ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isProfitable ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                    ),
                    child: Center(
                      child: Icon(
                        isProfitable ? Icons.check_circle : Icons.warning,
                        size: 48,
                        color: isProfitable ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
