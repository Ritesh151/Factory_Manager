class InvoiceEntity {
  final String id;
  final String invoiceNumber;
  final String customerName;
  final String customerEmail;
  final String customerAddress;
  final String companyName;
  final String companyAddress;
  final String companyEmail;
  final String companyPhone;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final List<InvoiceItemEntity> items;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double total;
  final double totalAmount;
  final String status;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InvoiceEntity({
    required this.id,
    required this.invoiceNumber,
    required this.customerName,
    required this.customerEmail,
    required this.customerAddress,
    required this.companyName,
    required this.companyAddress,
    required this.companyEmail,
    required this.companyPhone,
    required this.invoiceDate,
    required this.dueDate,
    required this.items,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.total,
    required this.totalAmount,
    required this.status,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  InvoiceEntity copyWith({
    String? id,
    String? invoiceNumber,
    String? customerName,
    String? customerEmail,
    String? customerAddress,
    String? companyName,
    String? companyAddress,
    String? companyEmail,
    String? companyPhone,
    DateTime? invoiceDate,
    DateTime? dueDate,
    List<InvoiceItemEntity>? items,
    double? subtotal,
    double? taxRate,
    double? taxAmount,
    double? total,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvoiceEntity(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerAddress: customerAddress ?? this.customerAddress,
      companyName: companyName ?? this.companyName,
      companyAddress: companyAddress ?? this.companyAddress,
      companyEmail: companyEmail ?? this.companyEmail,
      companyPhone: companyPhone ?? this.companyPhone,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      total: total ?? this.total,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class InvoiceItemEntity {
  final String id;
  final String productName;
  final String description;
  final int quantity;
  final double price;
  final double total;
  final double taxRate;
  final double unitPrice;

  const InvoiceItemEntity({
    required this.id,
    required this.productName,
    required this.description,
    required this.quantity,
    required this.price,
    required this.total,
    required this.taxRate,
    required this.unitPrice,
  });

  InvoiceItemEntity copyWith({
    String? id,
    String? productName,
    String? description,
    int? quantity,
    double? price,
    double? total,
    double? taxRate,
    double? unitPrice,
  }) {
    return InvoiceItemEntity(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      total: total ?? this.total,
      taxRate: taxRate ?? this.taxRate,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}
