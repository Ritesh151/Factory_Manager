import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDto {
  ProductDto({
    required this.name,
    required this.hsnCode,
    required this.gstRate,
    required this.price,
    required this.stock,
    required this.unit,
    this.description,
    this.costPrice,
    this.lowStockThreshold = 10,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });
  final String name;
  final String hsnCode;
  final int gstRate;
  final double price;
  final int stock;
  final String unit;
  final String? description;
  final double? costPrice;
  final int lowStockThreshold;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() => {
        'name': name,
        'hsnCode': hsnCode,
        'gstRate': gstRate,
        'price': price,
        'stock': stock,
        'unit': unit,
        if (description != null) 'description': description,
        if (costPrice != null) 'costPrice': costPrice,
        'lowStockThreshold': lowStockThreshold,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  static ProductDto fromMap(Map<String, dynamic> map, String id) {
    final createdAt = map['createdAt'];
    final updatedAt = map['updatedAt'];
    return ProductDto(
      name: map['name'] as String,
      hsnCode: map['hsnCode'] as String,
      gstRate: (map['gstRate'] as num).toInt(),
      price: (map['price'] as num).toDouble(),
      stock: (map['stock'] as num).toInt(),
      unit: map['unit'] as String,
      description: map['description'] as String?,
      costPrice: (map['costPrice'] as num?)?.toDouble(),
      lowStockThreshold: (map['lowStockThreshold'] as num?)?.toInt() ?? 10,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.parse(createdAt.toString()),
      updatedAt: updatedAt is Timestamp
          ? updatedAt.toDate()
          : DateTime.parse(updatedAt.toString()),
    );
  }
}
