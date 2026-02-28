import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../core/services/firebase_service.dart';
import '../models/sales_model.dart';

/// Clean Sales Repository without circular dependencies
/// Direct Firestore integration with proper error handling
class SalesRepository {
  static final SalesRepository _instance = SalesRepository._internal();
  
  factory SalesRepository() => _instance;
  SalesRepository._internal();

  late final FirebaseService _firebaseService;
  bool _initialized = false;

  /// Initialize repository with FirebaseService
  void initialize(FirebaseService firebaseService) {
    if (_initialized) return;
    
    _firebaseService = firebaseService;
    _initialized = true;
  }

  /// Get Firestore collection reference
  CollectionReference<Map<String, dynamic>> get _salesCollection {
    return _firebaseService.firestore.collection('sales');
  }

  /// Stream all sales ordered by creation date (newest first)
  Stream<List<SalesModel>> streamAllSales() {
    try {
      return _salesCollection
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return SalesModel.fromMap(doc.data(), doc.id);
        }).toList();
      });
    } catch (e) {
      debugPrint('SalesRepository: Error streaming sales: $e');
      return Stream.error(e);
    }
  }

  /// Get a single sale by ID
  Future<SalesModel?> getSaleById(String id) async {
    try {
      if (id.isEmpty) return null;

      final doc = await _salesCollection.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;

      return SalesModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      debugPrint('SalesRepository: Error getting sale by ID: $e');
      return null;
    }
  }

  /// Create new sale with immutable data
  Future<String> createSale(SalesModel sale) async {
    try {
      // Ensure sale has creation timestamp
      final saleWithTimestamp = sale.createdAt.isBefore(DateTime(2000))
          ? sale.copyWith(createdAt: DateTime.now())
          : sale;

      final docRef = await _salesCollection.add(saleWithTimestamp.toMap());
      
      debugPrint('SalesRepository: Created sale "${sale.invoiceNumber}" with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('SalesRepository: Error creating sale: $e');
      rethrow;
    }
  }

  /// Update existing sale (for status changes only, not data modification)
  Future<void> updateSaleStatus(String saleId, String status) async {
    try {
      await _salesCollection.doc(saleId).update({
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      debugPrint('SalesRepository: Updated sale status to: $status');
    } catch (e) {
      debugPrint('SalesRepository: Error updating sale status: $e');
      rethrow;
    }
  }

  /// Get sales by date range
  Future<List<SalesModel>> getSalesByDateRange(DateTime start, DateTime end) async {
    try {
      final snapshot = await _salesCollection
          .where('createdAt', isGreaterThanOrEqualTo: start)
          .where('createdAt', isLessThan: end)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SalesModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('SalesRepository: Error getting sales by date range: $e');
      return [];
    }
  }

  /// Get monthly sales total
  Future<double> getMonthlySalesTotal(int year, int month) async {
    try {
      final start = DateTime(year, month, 1);
      final end = DateTime(year, month + 1, 0, 23, 59, 59);

      final snapshot = await _salesCollection
          .where('createdAt', isGreaterThanOrEqualTo: start)
          .where('createdAt', isLessThan: end)
          .get();

      double total = 0.0;
      for (final doc in snapshot.docs) {
        final sale = SalesModel.fromMap(doc.data(), doc.id);
        total += sale.finalAmount;
      }

      return total;
    } catch (e) {
      debugPrint('SalesRepository: Error getting monthly sales total: $e');
      return 0.0;
    }
  }

  /// Get GST collected for a month
  Future<double> getMonthlyGstCollected(int year, int month) async {
    try {
      final start = DateTime(year, month, 1);
      final end = DateTime(year, month + 1, 0, 23, 59, 59);

      final snapshot = await _salesCollection
          .where('createdAt', isGreaterThanOrEqualTo: start)
          .where('createdAt', isLessThan: end)
          .get();

      double totalGst = 0.0;
      for (final doc in snapshot.docs) {
        final sale = SalesModel.fromMap(doc.data(), doc.id);
        totalGst += sale.totalCgst + sale.totalSgst;
      }

      return totalGst;
    } catch (e) {
      debugPrint('SalesRepository: Error getting monthly GST collected: $e');
      return 0.0;
    }
  }

  /// Delete a sale
  Future<void> deleteSale(String saleId) async {
    try {
      await _salesCollection.doc(saleId).delete();
      
      debugPrint('SalesRepository: Deleted sale: $saleId');
    } catch (e) {
      debugPrint('SalesRepository: Error deleting sale: $e');
      rethrow;
    }
  }
}
