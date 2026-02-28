import 'package:equatable/equatable.dart';

class Purchase extends Equatable {
  const Purchase({
    required this.id,
    required this.purchaseNumber,
    required this.purchaseDate,
    required this.supplier,
    required this.lineItems,
    required this.summary,
    this.notes,
    this.isLocked = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String purchaseNumber;
  final DateTime purchaseDate;
  final PurchaseSupplier supplier;
  final List<PurchaseLineItem> lineItems;
  final PurchaseSummary summary;
  final String? notes;
  final bool isLocked;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props =>
      [id, purchaseNumber, purchaseDate, supplier, lineItems, summary];
}

class PurchaseSupplier extends Equatable {
  const PurchaseSupplier({
    required this.name,
    this.gstin,
    this.address,
  });
  final String name;
  final String? gstin;
  final String? address;
  @override
  List<Object?> get props => [name, gstin, address];
}

class PurchaseLineItem extends Equatable {
  const PurchaseLineItem({
    required this.productId,
    required this.productName,
    required this.hsnCode,
    required this.quantity,
    required this.rate,
    required this.gstRate,
  });
  final String productId;
  final String productName;
  final String hsnCode;
  final double quantity;
  final double rate;
  final int gstRate;
  @override
  List<Object?> get props => [productId, quantity, rate];
}

class PurchaseSummary extends Equatable {
  const PurchaseSummary({
    required this.subtotal,
    required this.totalCgst,
    required this.totalSgst,
    required this.totalAmount,
  });
  final double subtotal;
  final double totalCgst;
  final double totalSgst;
  final double totalAmount;
  @override
  List<Object?> get props => [subtotal, totalAmount];
}
