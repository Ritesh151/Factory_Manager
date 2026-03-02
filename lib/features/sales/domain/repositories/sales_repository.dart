import '../entities/sales_entity.dart';

/// Abstract repository for sales operations
abstract class SalesRepository {
  /// Get a stream of all sales orders
  Stream<List<SalesOrderEntity>> getAllSalesOrdersStream();

  /// Get sales orders for a specific date range
  Future<List<SalesOrderEntity>> getSalesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Create a new sales order
  Future<SalesOrderEntity> createSalesOrder(SalesOrderEntity order);

  /// Update sales order status
  Future<void> updateSalesOrderStatus(String orderId, String status);

  /// Get total sales for a date range
  Future<double> getTotalSales({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get total profit for a date range
  Future<double> getTotalProfit({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get sales analytics data
  Future<Map<String, dynamic>> getSalesAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Search sales by order number or customer
  Future<List<SalesOrderEntity>> searchSales(String query);
}
