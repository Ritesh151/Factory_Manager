import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
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

  final String id;
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

  bool get isLowStock => stock <= lowStockThreshold;

  Product copyWith({
    String? id,
    String? name,
    String? hsnCode,
    int? gstRate,
    double? price,
    int? stock,
    String? unit,
    String? description,
    double? costPrice,
    int? lowStockThreshold,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      hsnCode: hsnCode ?? this.hsnCode,
      gstRate: gstRate ?? this.gstRate,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      description: description ?? this.description,
      costPrice: costPrice ?? this.costPrice,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, hsnCode, gstRate, price, stock, unit, isActive, createdAt];
}
