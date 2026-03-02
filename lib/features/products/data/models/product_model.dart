import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product_entity.dart';

/// ProductModel is the DTO (Data Transfer Object) for Firestore
/// Contains JSON serialization logic for database storage
class ProductModel extends ProductEntity {
  const ProductModel({
    required String id,
    required String name,
    required String description,
    required double price,
    required int quantity,
    required String sku,
    required String category,
    required double gstPercentage,
    required double tax,
    required String hsn,
    required bool active,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
    id: id,
    name: name,
    description: description,
    price: price,
    quantity: quantity,
    sku: sku,
    category: category,
    gstPercentage: gstPercentage,
    tax: tax,
    hsn: hsn,
    active: active,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  /// Create ProductModel from Firestore document snapshot
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel.fromMap({...data, 'id': doc.id});
  }

  /// Create ProductModel from JSON map
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: map['quantity'] as int? ?? 0,
      sku: map['sku'] as String? ?? '',
      category: map['category'] as String? ?? '',
      gstPercentage: (map['gstPercentage'] as num?)?.toDouble() ?? 0.0,
      tax: (map['tax'] as num?)?.toDouble() ?? 0.0,
      hsn: map['hsn'] as String? ?? '',
      active: map['active'] as bool? ?? true,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : (map['createdAt'] as DateTime? ?? DateTime.now()),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : (map['updatedAt'] as DateTime? ?? DateTime.now()),
    );
  }

  /// Create ProductModel from ProductEntity
  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      quantity: entity.quantity,
      sku: entity.sku,
      category: entity.category,
      gstPercentage: entity.gstPercentage,
      tax: entity.tax,
      hsn: entity.hsn,
      active: entity.active,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert ProductModel to JSON map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'sku': sku,
      'category': category,
      'gstPercentage': gstPercentage,
      'tax': tax,
      'hsn': hsn,
      'active': active,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Convert ProductModel to ProductEntity (for domain layer)
  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      name: name,
      description: description,
      price: price,
      quantity: quantity,
      sku: sku,
      category: category,
      gstPercentage: gstPercentage,
      tax: tax,
      hsn: hsn,
      active: active,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Copy with method
  ProductModel copyWith({
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
    return ProductModel(
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
}
