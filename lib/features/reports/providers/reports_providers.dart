import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/reports_service.dart';
import '../../../core/providers/firebase_provider.dart';

/// Reports service provider
final reportsServiceProvider = Provider((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  final service = ReportsService();
  service.initialize(firebaseService);
  return service;
});

/// Dashboard summary provider with 5-minute caching
final dashboardSummaryProvider = FutureProvider((ref) async {
  final service = ref.watch(reportsServiceProvider);
  try {
    return await service.getDashboardSummary();
  } catch (e) {
    throw Exception('Failed to fetch dashboard summary: $e');
  }
});

/// Yearly sales data provider
final yearlySalesDataProvider = FutureProvider.family<Map<int, double>, int>((ref, year) async {
  final service = ref.watch(reportsServiceProvider);
  try {
    final data = <int, double>{};
    // Fetch all 12 months in parallel
    final futures = List.generate(12, (i) => i + 1)
        .map((month) => service.getMonthlySalesTotal(year, month)
            .then((total) => (month, total)))
        .toList();

    final results = await Future.wait(futures);
    for (final (month, total) in results) {
      data[month] = total;
    }
    return data;
  } catch (e) {
    throw Exception('Failed to fetch yearly sales data: $e');
  }
});

/// Yearly purchases data provider
final yearlyPurchasesDataProvider = FutureProvider.family<Map<int, double>, int>((ref, year) async {
  final service = ref.watch(reportsServiceProvider);
  try {
    final data = <int, double>{};
    final futures = List.generate(12, (i) => i + 1)
        .map((month) => service.getMonthlyPurchaseTotal(year, month)
            .then((total) => (month, total)))
        .toList();

    final results = await Future.wait(futures);
    for (final (month, total) in results) {
      data[month] = total;
    }
    return data;
  } catch (e) {
    throw Exception('Failed to fetch yearly purchases data: $e');
  }
});

/// Yearly expenses data provider
final yearlyExpensesDataProvider = FutureProvider.family<Map<int, double>, int>((ref, year) async {
  final service = ref.watch(reportsServiceProvider);
  try {
    final data = <int, double>{};
    final futures = List.generate(12, (i) => i + 1)
        .map((month) => service.getMonthlyExpensesTotal(year, month)
            .then((total) => (month, total)))
        .toList();

    final results = await Future.wait(futures);
    for (final (month, total) in results) {
      data[month] = total;
    }
    return data;
  } catch (e) {
    throw Exception('Failed to fetch yearly expenses data: $e');
  }
});
