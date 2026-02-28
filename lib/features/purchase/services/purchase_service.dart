import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../core/services/firebase_service.dart';
import '../../products/services/product_service.dart';
import '../models/purchase_model.dart';

/// Service for managing purchases and supplier transactions
class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  FirebaseFirestore? _firestore;
  final ProductService _productService = ProductService();

  /// Initialize with FirebaseService
  void initialize(FirebaseService firebaseService) {
    _firestore = firebaseService.firestore;
    _productService.initialize(firebaseService);
  }

  /// Get purchases collection reference
  CollectionReference<Map<String, dynamic>> get _purchasesCollection {
    if (_firestore == null) {
      throw StateError('PurchaseService not initialized');
    }
    return _firestore!.collection('purchases');
  }

  /// Stream of all purchases ordered by date
  Stream<List<PurchaseModel>> streamPurchases() {
    try {
      return _purchasesCollection
          .orderBy('purchaseDate', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return PurchaseModel.fromMap(doc.data(), doc.id);
        }).toList();
      });
    } catch (e) {
      debugPrint('PurchaseService: Error streaming purchases: $e');
      return Stream.error(e);
    }
  }

  /// Create a new purchase and update stock
  Future<PurchaseModel> createPurchase({
    required String supplierName,
    String? supplierContact,
    required List<PurchaseItem> items,
    required DateTime purchaseDate,
    String? notes,
  }) async {
    try {
      if (supplierName.trim().isEmpty) {
        throw ArgumentError('Supplier name is required');
      }
      if (items.isEmpty) {
        throw ArgumentError('At least one item is required');
      }

      final totalAmount = items.fold(0.0, (sum, item) => sum + item.total);

      final purchase = PurchaseModel(
        id: '',
        supplierName: supplierName.trim(),
        supplierContact: supplierContact?.trim(),
        items: items,
        totalAmount: totalAmount,
        purchaseDate: purchaseDate,
        notes: notes?.trim(),
        createdAt: DateTime.now(),
      );

      // Use batched write for atomic operation
      final batch = _firestore!.batch();

      // Add purchase document
      final purchaseDocRef = _purchasesCollection.doc();
      batch.set(purchaseDocRef, purchase.toMap());

      // Commit purchase first
      await batch.commit();

      // Then update stock for each item (separate operation)
      for (final item in items) {
        await _productService.updateStock(item.productId, item.quantity);
      }

      debugPrint('PurchaseService: Created purchase from ${purchase.supplierName}');
      
      return purchase.copyWith(id: purchaseDocRef.id);
    } catch (e) {
      debugPrint('PurchaseService: Failed to create purchase: $e');
      rethrow;
    }
  }

  /// Get a single purchase by ID
  Future<PurchaseModel?> getPurchaseById(String id) async {
    try {
      if (id.isEmpty) return null;

      final doc = await _purchasesCollection.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;

      return PurchaseModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      debugPrint('PurchaseService: Failed to get purchase: $e');
      return null;
    }
  }

  /// Get purchases for a date range
  Future<List<PurchaseModel>> getPurchasesByDateRange(DateTime start, DateTime end) async {
    try {
      final snapshot = await _purchasesCollection
          .where('purchaseDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('purchaseDate', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('purchaseDate', descending: true)
          .get();

      return snapshot.docs.map((doc) => PurchaseModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      debugPrint('PurchaseService: Failed to get purchases by date range: $e');
      return [];
    }
  }

  /// Get total purchases for a month
  Future<double> getMonthlyPurchaseTotal(int year, int month) async {
    try {
      final start = DateTime(year, month, 1);
      final end = DateTime(year, month + 1, 0, 23, 59, 59);

      final snapshot = await _purchasesCollection
          .where('purchaseDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('purchaseDate', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      double total = 0.0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        total += (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
      }

      return total;
    } catch (e) {
      debugPrint('PurchaseService: Failed to get monthly total: $e');
      return 0.0;
    }
  }

  /// Delete a purchase (reverses stock)
  Future<void> deletePurchase(String id) async {
    try {
      if (id.isEmpty) throw ArgumentError('Purchase ID is required');

      final purchase = await getPurchaseById(id);
      if (purchase == null) throw ArgumentError('Purchase not found');

      // Reverse stock for each item
      for (final item in purchase.items) {
        await _productService.updateStock(item.productId, -item.quantity);
      }

      await _purchasesCollection.doc(id).delete();
      
      debugPrint('PurchaseService: Deleted purchase ${purchase.id}');
    } catch (e) {
      debugPrint('PurchaseService: Failed to delete purchase: $e');
      rethrow;
    }
  }
}
