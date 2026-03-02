import 'package:equatable/equatable.dart';

/// Product entity representing a product in the inventory
/// This entity is used in the domain layer and contains no serialization logic
/// Serialization is handled by the ProductModel in the data layer
class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final String sku;
  final String category;
  final double gstPercentage;
  final double tax;
  final String hsn;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.sku,
    required this.category,
    required this.gstPercentage,
    required this.tax,
    required this.hsn,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Copy with method for creating modified copies
  ProductEntity copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? quantity,
    String? sku,
    String? category,
    double? gstPercentage,
    double? tax,
    String? hsn,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      gstPercentage: gstPercentage ?? this.gstPercentage,
      tax: tax ?? this.tax,
      hsn: hsn ?? this.hsn,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculate total value in stock
  double get totalStockValue => price * quantity;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        quantity,
        sku,
        category,
        gstPercentage,
        tax,
        hsn,
        active,
        createdAt,
        updatedAt,
      ];
}
