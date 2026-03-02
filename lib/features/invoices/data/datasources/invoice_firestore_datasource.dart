import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/invoice_model.dart';

/// Firestore data source for invoice operations
class InvoiceFirestoreDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  static const String collectionName = 'invoices';
  static const String counterDocName = 'nextInvoiceNumber';
  static const String settingsCollection = 'settings';

  InvoiceFirestoreDataSource(this._firestore, this._storage);

  /// Get real-time stream of all invoices
  Stream<List<InvoiceModel>> getAllInvoicesStream() {
    return _firestore
        .collection(collectionName)
        .orderBy('invoiceDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => InvoiceModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get invoices filtered by status with real-time updates
  Stream<List<InvoiceModel>> getInvoicesByStatusStream(String status) {
    return _firestore
        .collection(collectionName)
        .where('status', isEqualTo: status)
        .orderBy('invoiceDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => InvoiceModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get invoices for a specific customer (real-time)
  Stream<List<InvoiceModel>> getCustomerInvoicesStream(String customerId) {
    return _firestore
        .collection(collectionName)
        .where('customerId', isEqualTo: customerId)
        .orderBy('invoiceDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => InvoiceModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get invoices within date range
  Future<List<InvoiceModel>> getInvoicesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .where('invoiceDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('invoiceDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();
      
      return snapshot.docs
          .map((doc) => InvoiceModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch invoices by date: ${e.message}');
    }
  }

  /// Get a single invoice by ID
  Future<InvoiceModel?> getInvoiceById(String invoiceId) async {
    try {
      final doc = await _firestore
          .collection(collectionName)
          .doc(invoiceId)
          .get();
      if (doc.exists) {
        return InvoiceModel.fromFirestore(doc);
      }
      return null;
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch invoice: ${e.message}');
    }
  }

  /// Create a new invoice
  Future<InvoiceModel> createInvoice(InvoiceModel invoiceModel) async {
    try {
      final docRef = await _firestore
          .collection(collectionName)
          .add(invoiceModel.toMap());
      
      final doc = await docRef.get();
      return InvoiceModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw Exception('Failed to create invoice: ${e.message}');
    }
  }

  /// Update an invoice
  Future<InvoiceModel> updateInvoice(InvoiceModel invoiceModel) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(invoiceModel.id)
          .update(invoiceModel.toMap());
      
      final doc = await _firestore
          .collection(collectionName)
          .doc(invoiceModel.id)
          .get();
      return InvoiceModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw Exception('Failed to update invoice: ${e.message}');
    }
  }

  /// Update invoice status only
  Future<void> updateInvoiceStatus(String invoiceId, String newStatus) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(invoiceId)
          .update({
        'status': newStatus,
        'updatedAt': Timestamp.now(),
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to update invoice status: ${e.message}');
    }
  }

  /// Delete an invoice
  Future<void> deleteInvoice(String invoiceId) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(invoiceId)
          .delete();
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete invoice: ${e.message}');
    }
  }

  /// Generate next invoice number (e.g., INV-00001)
  Future<String> generateInvoiceNumber() async {
    try {
      final settingsDoc = _firestore
          .collection(settingsCollection)
          .doc(counterDocName);
      
      // Check if counter exists
      final doc = await settingsDoc.get();
      int nextNumber = 1;
      
      if (doc.exists) {
        nextNumber = (doc['number'] as int? ?? 0) + 1;
      }
      
      // Increment the counter
      await settingsDoc.set({'number': nextNumber});
      
      // Format as INV-00001, INV-00002, etc.
      return 'INV-${nextNumber.toString().padLeft(5, '0')}';
    } on FirebaseException catch (e) {
      throw Exception('Failed to generate invoice number: ${e.message}');
    }
  }

  /// Save PDF URL to invoice
  Future<void> savePdfUrl(String invoiceId, String pdfUrl) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(invoiceId)
          .update({
        'pdfUrl': pdfUrl,
        'updatedAt': Timestamp.now(),
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to save PDF URL: ${e.message}');
    }
  }

  /// Get PDF URL from invoice
  Future<String?> getPdfUrl(String invoiceId) async {
    try {
      final doc = await _firestore
          .collection(collectionName)
          .doc(invoiceId)
          .get();
      return doc['pdfUrl'] as String?;
    } on FirebaseException catch (e) {
      throw Exception('Failed to get PDF URL: ${e.message}');
    }
  }

  /// Search invoices by invoice number or customer name
  Future<List<InvoiceModel>> searchInvoices(String query) async {
    try {
      final lowerQuery = query.toLowerCase();
      final snapshot = await _firestore
          .collection(collectionName)
          .get();
      
      final filtered = snapshot.docs
          .where((doc) {
        final invoice = InvoiceModel.fromFirestore(doc);
        return invoice.invoiceNumber.toLowerCase().contains(lowerQuery) ||
            invoice.customerName.toLowerCase().contains(lowerQuery);
      })
          .map((doc) => InvoiceModel.fromFirestore(doc))
          .toList();
      
      return filtered;
    } on FirebaseException catch (e) {
      throw Exception('Failed to search invoices: ${e.message}');
    }
  }
}
