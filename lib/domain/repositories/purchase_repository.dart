import '../entities/purchase.dart';
import '../value_objects/date_range.dart';

abstract class PurchaseRepository {
  Stream<List<Purchase>> watchByDateRange(
    String userId, {
    DateRange? dateRange,
  });
  Future<List<Purchase>> getByDateRange(
    String userId,
    DateRange dateRange, {
    int limit = 100,
  });
  Future<Purchase?> getById(String userId, String purchaseId);
  Future<Purchase> create(
    String userId,
    Purchase purchase,
    List<PurchaseLineItem> lineItems,
    List<StockAddition> stockAdditions,
  );
  Future<double> getMonthlyTotal(String userId, DateTime month);
  Future<String> getNextPurchaseNumber(String userId);
}

class StockAddition {
  const StockAddition({
    required this.productId,
    required this.quantity,
    required this.currentStock,
  });
  final String productId;
  final int quantity;
  final int currentStock;
}
