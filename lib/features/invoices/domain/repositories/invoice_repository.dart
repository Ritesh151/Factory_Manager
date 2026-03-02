import '../entities/invoice_entity.dart';

/// Abstract repository for invoice operations
abstract class InvoiceRepository {
  /// Get a stream of all invoices from Firestore
  /// Real-time updates
  Stream<List<InvoiceEntity>> getAllInvoicesStream();

  /// Get invoices by status (draft, sent, paid, overdue)
  Stream<List<InvoiceEntity>> getInvoicesByStatusStream(String status);

  /// Get invoices by date range
  Future<List<InvoiceEntity>> getInvoicesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get a single invoice by ID
  Future<InvoiceEntity> getInvoiceById(String invoiceId);

  /// Create a new invoice in Firestore
  Future<InvoiceEntity> createInvoice(InvoiceEntity invoice);

  /// Update an existing invoice
  Future<InvoiceEntity> updateInvoice(InvoiceEntity invoice);

  /// Update invoice status
  Future<void> updateInvoiceStatus(String invoiceId, String newStatus);

  /// Delete an invoice
  Future<void> deleteInvoice(String invoiceId);

  /// Generate the next invoice number
  Future<String> generateInvoiceNumber();

  /// Save PDF URL to invoice document
  Future<void> savePdfUrl(String invoiceId, String pdfUrl);

  /// Get PDF URL for an invoice
  Future<String?> getPdfUrl(String invoiceId);

  /// Search invoices by invoice number or customer name
  Future<List<InvoiceEntity>> searchInvoices(String query);

  /// Get invoices for a specific customer
  Stream<List<InvoiceEntity>> getCustomerInvoicesStream(String customerId);
}
