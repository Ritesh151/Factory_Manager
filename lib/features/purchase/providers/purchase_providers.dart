import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/purchase_model.dart';
import '../services/purchase_service.dart';
import '../../../core/providers/firebase_provider.dart';

/// Purchase service provider
final purchaseServiceProvider = Provider((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  final service = PurchaseService();
  service.initialize(firebaseService);
  return service;
});

/// Stream all purchases
final purchasesStreamProvider = StreamProvider((ref) {
  return ref.watch(purchaseServiceProvider).streamPurchases();
});

/// Cached purchases
final purchasesCacheProvider = FutureProvider((ref) async {
  final service = ref.watch(purchaseServiceProvider);
  try {
    final stream = service.streamPurchases();
    return await stream.first;
  } catch (e) {
    throw Exception('Failed to fetch purchases: $e');
  }
});

/// Monthly purchase total
final monthlyPurchasesTotalProvider = FutureProvider.family<double, (int, int)>((ref, params) async {
  final service = ref.watch(purchaseServiceProvider);
  final (year, month) = params;
  try {
    return await service.getMonthlyPurchaseTotal(year, month);
  } catch (e) {
    throw Exception('Failed to fetch monthly purchases: $e');
  }
});
