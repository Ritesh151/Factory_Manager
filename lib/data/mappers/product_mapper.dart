import '../../domain/entities/product.dart';
import '../models/product_dto.dart';

Product productFromDto(String id, ProductDto dto) {
  return Product(
    id: id,
    name: dto.name,
    hsnCode: dto.hsnCode,
    gstRate: dto.gstRate,
    price: dto.price,
    stock: dto.stock,
    unit: dto.unit,
    description: dto.description,
    costPrice: dto.costPrice,
    lowStockThreshold: dto.lowStockThreshold,
    isActive: dto.isActive,
    createdAt: dto.createdAt,
    updatedAt: dto.updatedAt,
  );
}

ProductDto productToDto(Product entity) {
  return ProductDto(
    name: entity.name,
    hsnCode: entity.hsnCode,
    gstRate: entity.gstRate,
    price: entity.price,
    stock: entity.stock,
    unit: entity.unit,
    description: entity.description,
    costPrice: entity.costPrice,
    lowStockThreshold: entity.lowStockThreshold,
    isActive: entity.isActive,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );
}
