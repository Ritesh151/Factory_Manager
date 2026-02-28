import 'package:cloud_firestore/cloud_firestore.dart';

/// Invoice item representing a line item in a sale
class InvoiceItem {
  final String productId;
  final String productName;
  final String hsnCode;
  final double price;
  final int quantity;
  final double gstPercentage;
  final double discount;

  InvoiceItem({
    required this.productId,
    required this.productName,
    required this.hsnCode,
    required this.price,
    required this.quantity,
    required this.gstPercentage,
    this.discount = 0,
  });

  /// Calculate amount before GST
  double get amount => price * quantity * (1 - discount / 100);

  /// Calculate GST amount
  double get gstAmount => (amount * gstPercentage) / 100;

  /// Calculate CGST (half of GST)
  double get cgst => gstAmount / 2;

  /// Calculate SGST (half of GST)
  double get sgst => gstAmount / 2;

  /// Calculate final amount with GST
  double get finalAmount => amount + gstAmount;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'hsnCode': hsnCode,
      'price': price,
      'quantity': quantity,
      'gstPercentage': gstPercentage,
      'discount': discount,
      'amount': amount,
      'gstAmount': gstAmount,
      'cgst': cgst,
      'sgst': sgst,
      'finalAmount': finalAmount,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      hsnCode: map['hsnCode'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      gstPercentage: (map['gstPercentage'] as num?)?.toDouble() ?? 18.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Sales/Invoice model for GST tax invoice
class SalesModel {
  final String id;
  final String invoiceNumber;
  final String customerName;
  final String? customerPhone;
  final String? customerGstin;
  final List<InvoiceItem> items;
  final double subtotal;
  final double totalCgst;
  final double totalSgst;
  final double extraCharges;
  final double roundOff;
  final double finalAmount;
  final DateTime createdAt;
  final bool isLocked;
  final String status;

  SalesModel({
    required this.id,
    required this.invoiceNumber,
    required this.customerName,
    this.customerPhone,
    this.customerGstin,
    required this.items,
    required this.subtotal,
    required this.totalCgst,
    required this.totalSgst,
    this.extraCharges = 0.0,
    this.roundOff = 0.0,
    required this.finalAmount,
    required this.createdAt,
    this.isLocked = false,
    this.status = 'pending',
  });

  /// Calculate total GST (CGST + SGST)
  double get totalGst => totalCgst + totalSgst;

  /// Get total amount (alias for finalAmount)
  double get totalAmount => finalAmount;

  /// Get total quantity
  int get totalQuantity => items.fold(0, (total, item) => total + item.quantity);

  /// Amount in words (simplified)
  String get amountInWords {
    final amount = finalAmount.toInt();
    return 'Rupees $amount only';
  }

  factory SalesModel.fromMap(Map<String, dynamic> map, String documentId) {
    return SalesModel(
      id: documentId,
      invoiceNumber: map['invoiceNumber'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'],
      customerGstin: map['customerGstin'],
      items: (map['items'] as List<dynamic>?)
              ?.map((e) => InvoiceItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      totalCgst: (map['totalCgst'] as num?)?.toDouble() ?? 0.0,
      totalSgst: (map['totalSgst'] as num?)?.toDouble() ?? 0.0,
      extraCharges: (map['extraCharges'] as num?)?.toDouble() ?? 0.0,
      roundOff: (map['roundOff'] as num?)?.toDouble() ?? 0.0,
      finalAmount: (map['finalAmount'] as num?)?.toDouble() ?? 0.0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isLocked: map['isLocked'] ?? false,
      status: map['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'invoiceNumber': invoiceNumber,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerGstin': customerGstin,
      'items': items.map((e) => e.toMap()).toList(),
      'subtotal': subtotal,
      'totalCgst': totalCgst,
      'totalSgst': totalSgst,
      'extraCharges': extraCharges,
      'roundOff': roundOff,
      'finalAmount': finalAmount,
      'createdAt': Timestamp.fromDate(createdAt),
      'isLocked': isLocked,
      'status': status,
    };
  }

  SalesModel copyWith({
    String? id,
    String? invoiceNumber,
    String? customerName,
    String? customerPhone,
    String? customerGstin,
    List<InvoiceItem>? items,
    double? subtotal,
    double? totalCgst,
    double? totalSgst,
    double? extraCharges,
    double? roundOff,
    double? finalAmount,
    DateTime? createdAt,
    bool? isLocked,
    String? status,
  }) {
    return SalesModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerGstin: customerGstin ?? this.customerGstin,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      totalCgst: totalCgst ?? this.totalCgst,
      totalSgst: totalSgst ?? this.totalSgst,
      extraCharges: extraCharges ?? this.extraCharges,
      roundOff: roundOff ?? this.roundOff,
      finalAmount: finalAmount ?? this.finalAmount,
      createdAt: createdAt ?? this.createdAt,
      isLocked: isLocked ?? this.isLocked,
      status: status ?? this.status,
    );
  }
}
