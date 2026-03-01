import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sales_model.dart';
import '../repositories/sales_repository.dart';
import '../../../core/providers/firebase_provider.dart';

/// Sales repository provider
final salesRepositoryProvider = Provider((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  final repo = SalesRepository();
  repo.initialize(firebaseService);
  return repo;
});

/// Stream all sales with real-time updates
final salesStreamProvider = StreamProvider((ref) {
  return ref.watch(salesRepositoryProvider).streamAllSales();
});

/// Cached sales future - fetches once and caches for 5 minutes
final salesCacheProvider = FutureProvider((ref) async {
  final repo = ref.watch(salesRepositoryProvider);
  try {
    final stream = repo.streamAllSales();
    return await stream.first;
  } catch (e) {
    throw Exception('Failed to fetch sales: $e');
  }
});

/// Monthly sales total provider
final monthlySalesTotalProvider = FutureProvider.family<double, (int, int)>((ref, params) async {
  final repo = ref.watch(salesRepositoryProvider);
  final (year, month) = params;
  try {
    return await repo.getMonthlySalesTotal(year, month);
  } catch (e) {
    throw Exception('Failed to fetch monthly sales total: $e');
  }
});

/// Sale by ID provider
final saleByIdProvider = FutureProvider.family<SalesModel?, String>((ref, saleId) async {
  final sales = await ref.watch(salesCacheProvider.future);
  try {
    return sales.firstWhere((s) => s.id == saleId);
  } catch (e) {
    return null;
  }
});
