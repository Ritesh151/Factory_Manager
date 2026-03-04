import 'transport_entity.dart';

/// Unified transaction entity for sales and purchases
class TransactionEntity {
  final String? id;
  final DateTime date;
  final String billNo;
  final String customerVendorName;
  final String productName;
  final double quantity;
  final double amount;
  final String paymentStatus; // 'pending', 'completed', 'partial'
  final String type; // 'sale' or 'purchase'
  final double gst;
  final double subtotal;
  final double grandTotal;
  final TransportEntity? transport;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionEntity({
    this.id,
    required this.date,
    required this.billNo,
    required this.customerVendorName,
    required this.productName,
    required this.quantity,
    required this.amount,
    required this.paymentStatus,
    required this.type,
    required this.gst,
    required this.subtotal,
    required this.grandTotal,
    this.transport,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper getter for profit calculation
  double get netProfit => grandTotal;

  TransactionEntity copyWith({
    String? id,
    DateTime? date,
    String? billNo,
    String? customerVendorName,
    String? productName,
    double? quantity,
    double? amount,
    String? paymentStatus,
    String? type,
    double? gst,
    double? subtotal,
    double? grandTotal,
    TransportEntity? transport,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      date: date ?? this.date,
      billNo: billNo ?? this.billNo,
      customerVendorName: customerVendorName ?? this.customerVendorName,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      amount: amount ?? this.amount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      type: type ?? this.type,
      gst: gst ?? this.gst,
      subtotal: subtotal ?? this.subtotal,
      grandTotal: grandTotal ?? this.grandTotal,
      transport: transport ?? this.transport,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
