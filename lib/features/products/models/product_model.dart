import 'package:cloud_firestore/cloud_firestore.dart';

/// Price history entry for tracking price changes
class PriceHistoryEntry {
  final double price;
  final DateTime date;

  PriceHistoryEntry({required this.price, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'price': price,
      'date': Timestamp.fromDate(date),
    };
  }

  factory PriceHistoryEntry.fromMap(Map<String, dynamic> map) {
    return PriceHistoryEntry(
      price: (map['price'] as num).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
    );
  }
}

/// Product model with complete GST and inventory fields
class ProductModel {
  final String id;
  final String name;
  final double price;
  final double discount;
  final double gstPercentage;
  final String hsnCode;
  final int stock;
  final String? imageUrl;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PriceHistoryEntry> priceHistory;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.discount = 0.0,
    this.gstPercentage = 18.0,
    this.hsnCode = '',
    this.stock = 0,
    this.imageUrl,
    this.description = '',
    required this.createdAt,
    required this.updatedAt,
    this.priceHistory = const [],
  });

  /// Calculate price after discount
  double get discountedPrice => price * (1 - discount / 100);

  /// Calculate GST amount
  double get gstAmount => (discountedPrice * gstPercentage) / 100;

  /// Calculate final price with GST
  double get finalPrice => discountedPrice + gstAmount;

  /// Check if stock is low (below 10)
  bool get isLowStock => stock < 10;

  /// Check if out of stock
  bool get isOutOfStock => stock <= 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, price: $price, stock: $stock, hsnCode: $hsnCode)';
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ProductModel(
      id: documentId,
      name: map['name'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      gstPercentage: (map['gstPercentage'] as num?)?.toDouble() ?? 18.0,
      hsnCode: map['hsnCode'] ?? '',
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      imageUrl: map['imageUrl'],
      description: map['description'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      priceHistory: (map['priceHistory'] as List<dynamic>?)
              ?.map((e) => PriceHistoryEntry.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'discount': discount,
      'gstPercentage': gstPercentage,
      'hsnCode': hsnCode,
      'stock': stock,
      'imageUrl': imageUrl,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'priceHistory': priceHistory.map((e) => e.toMap()).toList(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    double? discount,
    double? gstPercentage,
    String? hsnCode,
    int? stock,
    String? imageUrl,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PriceHistoryEntry>? priceHistory,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      gstPercentage: gstPercentage ?? this.gstPercentage,
      hsnCode: hsnCode ?? this.hsnCode,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      priceHistory: priceHistory ?? this.priceHistory,
    );
  }
}
