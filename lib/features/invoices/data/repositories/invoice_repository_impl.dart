import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../datasources/invoice_firestore_datasource.dart';
import '../models/invoice_model.dart';

/// Invoice repository implementation
class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceFirestoreDataSource _firestoreDataSource;

  InvoiceRepositoryImpl(this._firestoreDataSource);

  @override
  Stream<List<InvoiceEntity>> getAllInvoicesStream() {
    return _firestoreDataSource
        .getAllInvoicesStream()
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Stream<List<InvoiceEntity>> getInvoicesByStatusStream(String status) {
    return _firestoreDataSource
        .getInvoicesByStatusStream(status)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Stream<List<InvoiceEntity>> getCustomerInvoicesStream(String customerId) {
    return _firestoreDataSource
        .getCustomerInvoicesStream(customerId)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Future<List<InvoiceEntity>> getInvoicesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final models = await _firestoreDataSource.getInvoicesByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<InvoiceEntity> getInvoiceById(String invoiceId) async {
    try {
      final model = await _firestoreDataSource.getInvoiceById(invoiceId);
      if (model == null) {
        throw Exception('Invoice not found');
      }
      return model.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<InvoiceEntity> createInvoice(InvoiceEntity invoice) async {
    try {
      final model = InvoiceModel.fromEntity(invoice);
      final createdModel = await _firestoreDataSource.createInvoice(model);
      return createdModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<InvoiceEntity> updateInvoice(InvoiceEntity invoice) async {
    try {
      final model = InvoiceModel.fromEntity(invoice);
      final updatedModel = await _firestoreDataSource.updateInvoice(model);
      return updatedModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateInvoiceStatus(String invoiceId, String newStatus) async {
    try {
      await _firestoreDataSource.updateInvoiceStatus(invoiceId, newStatus);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteInvoice(String invoiceId) async {
    try {
      await _firestoreDataSource.deleteInvoice(invoiceId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> generateInvoiceNumber() async {
    try {
      return await _firestoreDataSource.generateInvoiceNumber();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> savePdfUrl(String invoiceId, String pdfUrl) async {
    try {
      await _firestoreDataSource.savePdfUrl(invoiceId, pdfUrl);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String?> getPdfUrl(String invoiceId) async {
    try {
      return await _firestoreDataSource.getPdfUrl(invoiceId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<InvoiceEntity>> searchInvoices(String query) async {
    try {
      final models = await _firestoreDataSource.searchInvoices(query);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }
}
