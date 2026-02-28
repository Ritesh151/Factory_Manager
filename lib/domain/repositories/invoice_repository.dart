import '../entities/invoice.dart';
import '../value_objects/date_range.dart';

abstract class InvoiceRepository {
  Stream<List<Invoice>> watchByDateRange(
    String userId, {
    DateRange? dateRange,
  });
  Future<List<Invoice>> getByDateRange(
    String userId,
    DateRange dateRange, {
    int limit = 100,
    String? lastDocumentId,
  });
  Future<Invoice?> getById(String userId, String invoiceId);
  Future<Invoice?> getByNumber(String userId, String invoiceNumber);
  /// Creates invoice and updates stock in batch. Throws on insufficient stock.
  Future<Invoice> create(
    String userId,
    Invoice invoice,
    List<InvoiceLineItem> lineItems,
    List<StockDeduction> stockDeductions,
  );
  Future<String> getNextInvoiceNumber(String userId);
  Future<bool> invoiceNumberExists(String userId, String invoiceNumber);
  Future<double> getMonthlyTotal(String userId, DateTime month);
}

class StockDeduction {
  const StockDeduction({
    required this.productId,
    required this.quantity,
    required this.currentStock,
  });
  final String productId;
  final int quantity;
  final int currentStock;
}
