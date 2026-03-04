import '../../domain/entities/transaction_entity.dart';
import 'transport_model.dart';

/// Transaction data model with JSON serialization
class TransactionModel extends TransactionEntity {
  TransactionModel({
    super.id,
    required super.date,
    required super.billNo,
    required super.customerVendorName,
    required super.productName,
    required super.quantity,
    required super.amount,
    required super.paymentStatus,
    required super.type,
    required super.gst,
    required super.subtotal,
    required super.grandTotal,
    super.transport,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      billNo: json['billNo'],
      customerVendorName: json['customerVendorName'],
      productName: json['productName'],
      quantity: (json['quantity'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      paymentStatus: json['paymentStatus'],
      type: json['type'],
      gst: (json['gst'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      grandTotal: (json['grandTotal'] as num).toDouble(),
      transport: json['transport'] != null
          ? TransportModel.fromJson(json['transport'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      date: entity.date,
      billNo: entity.billNo,
      customerVendorName: entity.customerVendorName,
      productName: entity.productName,
      quantity: entity.quantity,
      amount: entity.amount,
      paymentStatus: entity.paymentStatus,
      type: entity.type,
      gst: entity.gst,
      subtotal: entity.subtotal,
      grandTotal: entity.grandTotal,
      transport: entity.transport,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'billNo': billNo,
      'customerVendorName': customerVendorName,
      'productName': productName,
      'quantity': quantity,
      'amount': amount,
      'paymentStatus': paymentStatus,
      'type': type,
      'gst': gst,
      'subtotal': subtotal,
      'grandTotal': grandTotal,
      'transport': transport != null
          ? TransportModel.fromEntity(transport!).toJson()
          : null,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
