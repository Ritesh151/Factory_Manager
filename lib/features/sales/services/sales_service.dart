import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../core/services/firebase_service.dart';
import '../../products/services/product_service.dart';
import '../models/sales_model.dart';

/// Service for managing sales and invoices
class SalesService {
  static final SalesService _instance = SalesService._internal();
  
  factory SalesService() => _instance;
  SalesService._internal();

  FirebaseFirestore? _firestore;
  final ProductService _productService = ProductService();

  /// Initialize with FirebaseService
  void initialize(FirebaseService firebaseService) {
    _firestore = firebaseService.firestore;
    _productService.initialize(firebaseService);
  }

  /// Get sales collection reference
  CollectionReference<Map<String, dynamic>> get _salesCollection {
    if (_firestore == null) {
      throw StateError('SalesService not initialized');
    }
    return _firestore!.collection('sales');
  }

  /// Get settings collection for invoice counter
  CollectionReference<Map<String, dynamic>> get _settingsCollection {
    if (_firestore == null) {
      throw StateError('SalesService not initialized');
    }
    return _firestore!.collection('settings');
  }

  /// Stream of all sales ordered by date
  Stream<List<SalesModel>> streamSales() {
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
      debugPrint('SalesService: Error streaming sales: $e');
      return Stream.error(e);
    }
  }

  /// Generate next invoice number (format: 32/25-26)
  Future<String> _generateInvoiceNumber() async {
    final fiscalYear = _getFiscalYear();
    final docRef = _settingsCollection.doc('invoice_counter');
    
    return _firestore!.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      
      int currentNumber = 1;
      String storedFiscalYear = fiscalYear;
      
      if (doc.exists) {
        final data = doc.data()!;
        storedFiscalYear = data['fiscalYear'] ?? fiscalYear;
        
        // Reset counter if fiscal year changed
        if (storedFiscalYear == fiscalYear) {
          currentNumber = (data['lastNumber'] ?? 0) + 1;
        } else {
          currentNumber = 1;
        }
      }
      
      transaction.set(docRef, {
        'lastNumber': currentNumber,
        'fiscalYear': fiscalYear,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      
      return '$currentNumber/${fiscalYear.substring(2, 4)}-${fiscalYear.substring(7, 9)}';
    });
  }

  /// Get current fiscal year (YYYY-YY format)
  String _getFiscalYear() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    
    // Fiscal year in India: April 1 - March 31
    if (month >= 4) {
      return '$year-${(year + 1).toString().substring(2)}';
    } else {
      return '${year - 1}-${year.toString().substring(2)}';
    }
  }

  /// Create a new sale with invoice locking and stock deduction
  Future<SalesModel> createSale({
    required String customerName,
    String? customerPhone,
    String? customerGstin,
    required List<InvoiceItem> items,
    double extraCharges = 0.0,
  }) async {
    try {
      if (customerName.trim().isEmpty) {
        throw ArgumentError('Customer name is required');
      }
      if (items.isEmpty) {
        throw ArgumentError('At least one item is required');
      }

      // Calculate totals
      final subtotal = items.fold(0.0, (total, item) => total + item.amount);
      final totalCgst = items.fold(0.0, (total, item) => total + item.cgst);
      final totalSgst = items.fold(0.0, (total, item) => total + item.sgst);
      final rawTotal = subtotal + totalCgst + totalSgst + extraCharges;
      
      // Calculate round off
      final roundedTotal = rawTotal.roundToDouble();
      final roundOff = roundedTotal - rawTotal;

      final invoiceNumber = await _generateInvoiceNumber();

      final sale = SalesModel(
        id: '',
        invoiceNumber: invoiceNumber,
        customerName: customerName.trim(),
        customerPhone: customerPhone?.trim(),
        customerGstin: customerGstin?.trim(),
        items: items,
        subtotal: subtotal,
        totalCgst: totalCgst,
        totalSgst: totalSgst,
        extraCharges: extraCharges,
        roundOff: roundOff,
        finalAmount: roundedTotal,
        createdAt: DateTime.now(),
        isLocked: true, // Lock immediately after creation
      );

      // Use batched write for atomic operation
      final batch = _firestore!.batch();

      // Add sale document
      final saleDocRef = _salesCollection.doc();
      batch.set(saleDocRef, sale.toMap());

      // Deduct stock for each item
      for (final item in items) {
        await _productService.updateStock(item.productId, -item.quantity);
      }

      await batch.commit();

      debugPrint('SalesService: Created invoice ${sale.invoiceNumber}');
      
      return sale.copyWith(id: saleDocRef.id);
    } catch (e) {
      debugPrint('SalesService: Failed to create sale: $e');
      rethrow;
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
      debugPrint('SalesService: Failed to get sale: $e');
      return null;
    }
  }

  /// Get sales for a date range
  Future<List<SalesModel>> getSalesByDateRange(DateTime start, DateTime end) async {
    try {
      final snapshot = await _salesCollection
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => SalesModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      debugPrint('SalesService: Failed to get sales by date range: $e');
      return [];
    }
  }

  /// Get total sales for a month
  Future<double> getMonthlySalesTotal(int year, int month) async {
    try {
      final start = DateTime(year, month, 1);
      final end = DateTime(year, month + 1, 0, 23, 59, 59);

      final snapshot = await _salesCollection
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      double total = 0.0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        total += (data['finalAmount'] as num?)?.toDouble() ?? 0.0;
      }

      return total;
    } catch (e) {
      debugPrint('SalesService: Failed to get monthly total: $e');
      return 0.0;
    }
  }

  /// Delete a sale (admin only - reverses stock)
  Future<void> deleteSale(String id) async {
    try {
      if (id.isEmpty) throw ArgumentError('Sale ID is required');

      final sale = await getSaleById(id);
      if (sale == null) throw ArgumentError('Sale not found');

      // Restore stock for each item
      for (final item in sale.items) {
        await _productService.updateStock(item.productId, item.quantity);
      }

      await _salesCollection.doc(id).delete();
      
      debugPrint('SalesService: Deleted invoice ${sale.invoiceNumber}');
    } catch (e) {
      debugPrint('SalesService: Failed to delete sale: $e');
      rethrow;
    }
  }
}
