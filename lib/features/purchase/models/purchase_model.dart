import 'package:cloud_firestore/cloud_firestore.dart';

/// Purchase item representing a product in a purchase
class PurchaseItem {
  final String productId;
  final String productName;
  final double purchasePrice;
  final int quantity;
  final double total;

  PurchaseItem({
    required this.productId,
    required this.productName,
    required this.purchasePrice,
    required this.quantity,
  }) : total = purchasePrice * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'purchasePrice': purchasePrice,
      'quantity': quantity,
      'total': total,
    };
  }

  factory PurchaseItem.fromMap(Map<String, dynamic> map) {
    return PurchaseItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      purchasePrice: (map['purchasePrice'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Purchase model for supplier purchases
class PurchaseModel {
  final String id;
  final String supplierName;
  final String? supplierContact;
  final List<PurchaseItem> items;
  final double totalAmount;
  final DateTime purchaseDate;
  final String? notes;
  final DateTime createdAt;

  PurchaseModel({
    required this.id,
    required this.supplierName,
    this.supplierContact,
    required this.items,
    required this.totalAmount,
    required this.purchaseDate,
    this.notes,
    required this.createdAt,
  });

  /// Get total quantity purchased
  int get totalQuantity => items.fold(0, (total, item) => total + item.quantity);

  factory PurchaseModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PurchaseModel(
      id: documentId,
      supplierName: map['supplierName'] ?? '',
      supplierContact: map['supplierContact'],
      items: (map['items'] as List<dynamic>?)
              ?.map((e) => PurchaseItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      purchaseDate: (map['purchaseDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'supplierName': supplierName,
      'supplierContact': supplierContact,
      'items': items.map((e) => e.toMap()).toList(),
      'totalAmount': totalAmount,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  PurchaseModel copyWith({
    String? id,
    String? supplierName,
    String? supplierContact,
    List<PurchaseItem>? items,
    double? totalAmount,
    DateTime? purchaseDate,
    String? notes,
    DateTime? createdAt,
  }) {
    return PurchaseModel(
      id: id ?? this.id,
      supplierName: supplierName ?? this.supplierName,
      supplierContact: supplierContact ?? this.supplierContact,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
