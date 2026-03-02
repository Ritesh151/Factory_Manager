import 'package:equatable/equatable.dart';

/// Sales order entity
class SalesOrderEntity extends Equatable {
  final String id;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final double totalAmount;
  final double profit;
  final String status; // pending, completed, cancelled
  final List<SalesItemEntity> items;
  final DateTime orderDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SalesOrderEntity({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.totalAmount,
    required this.profit,
    required this.status,
    required this.items,
    required this.orderDate,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        customerId,
        customerName,
        totalAmount,
        profit,
        status,
        items,
        orderDate,
        createdAt,
        updatedAt,
      ];
}

/// Sales item entity
class SalesItemEntity extends Equatable {
  final String productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double costPrice;
  final DateTime saleDate;

  const SalesItemEntity({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.costPrice,
    required this.saleDate,
  });

  double get profit => (unitPrice - costPrice) * quantity;

  @override
  List<Object?> get props => [
        productId,
        productName,
        quantity,
        unitPrice,
        costPrice,
        saleDate,
      ];
}
