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
  bool _isFirebaseAvailable = true;
  String? _errorMessage;
  DateTime? _lastRefreshTime;
  
  // Cache duration - 5 minutes
  static const Duration _cacheDuration = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final firebaseService = FirebaseService();
      await firebaseService.initialize();
      _reportsService = ReportsService();
      _reportsService.initialize(firebaseService);
      
      _loadData();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isFirebaseAvailable = false;
        _errorMessage = e.toString();
      });
      debugPrint('Dashboard: Firebase initialization failed: $e');
    }
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    // Check if we can use cached data
    if (!forceRefresh && 
        _summary != null && 
        _lastRefreshTime != null && 
        DateTime.now().difference(_lastRefreshTime!) < _cacheDuration) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Use Future.wait to parallelize all Firebase calls
      final summary = await _reportsService.getDashboardSummary();
      
      if (mounted) {
        setState(() {
          _summary = summary;
          _isLoading = false;
          _lastRefreshTime = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
        
        // Show error message only if it's not a network error
        if (!e.toString().contains('network') && !e.toString().contains('connection')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading dashboard: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      debugPrint('Dashboard: Error loading data: $e');
    }
  }

  Future<void> _refreshData() async {
    await _loadData(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = _summary ?? DashboardSummary.zero();

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with refresh button and last update time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionHeader(title: 'Dashboard'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FilledButton.icon(
                      onPressed: _isLoading ? null : _refreshData,
                      icon: _isLoading 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                      label: Text(_isLoading ? 'Loading...' : 'Refresh'),
                    ),
                    if (_lastRefreshTime != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Last updated: ${_formatTime(_lastRefreshTime!)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // Show error message if present
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Connection issue. Showing cached data or offline mode.',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Loading skeleton or actual content
            if (_isLoading)
              _buildLoadingSkeleton(theme)
            else if (!_isFirebaseAvailable)
              _buildOfflinePlaceholder(theme)
            else
              _buildDashboardContent(theme, summary),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(ThemeData theme) {
    return Column(
      children: [
        // Stat cards skeleton
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: List.generate(6, (index) => 
            Container(
              width: 200,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Summary card skeleton
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardContent(ThemeData theme, DashboardSummary summary) {
    return Column(
      children: [
        // Stat cards with staggered animation
        _buildAnimatedStatCards(summary),
        
        const SizedBox(height: AppSpacing.lg),
        
        // Profit summary card with animation
        _buildAnimatedProfitCard(theme, summary),
      ],
    );
  }

  Widget _buildAnimatedStatCards(DashboardSummary summary) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, animation, child) {
        return Opacity(
          opacity: animation,
          child: Wrap(
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
        );
      },
    );
  }

  
  Widget _buildAnimatedProfitCard(ThemeData theme, DashboardSummary summary) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, animation, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animation)),
          child: Opacity(
            opacity: animation,
            child: Card(
              color: summary.netProfit >= 0 
                  ? Colors.green.withValues(alpha: 0.1) 
                  : Colors.red.withValues(alpha: 0.1),
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
                            ? Colors.green.withValues(alpha: 0.2) 
                            : Colors.red.withValues(alpha: 0.2),
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
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildOfflinePlaceholder(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 80, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'Dashboard Offline',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Firebase is not available.\nDashboard features are disabled in offline mode.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _initializeServices,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry Connection'),
          ),
        ],
      ),
    );
  }
}
