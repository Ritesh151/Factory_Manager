import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/invoice_entity.dart';

/// Invoice item model for JSON serialization
class InvoiceItemModel extends InvoiceItemEntity {
  const InvoiceItemModel({
    required String productId,
    required String productName,
    required double quantity,
    required double unitPrice,
    required double taxRate,
    required double total,
  }) : super(
    productId: productId,
    productName: productName,
    quantity: quantity,
    unitPrice: unitPrice,
    taxRate: taxRate,
    total: total,
  );

  factory InvoiceItemModel.fromMap(Map<String, dynamic> map) {
    return InvoiceItemModel(
      productId: map['productId'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
      taxRate: (map['taxRate'] as num?)?.toDouble() ?? 0.0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory InvoiceItemModel.fromEntity(InvoiceItemEntity entity) {
    return InvoiceItemModel(
      productId: entity.productId,
      productName: entity.productName,
      quantity: entity.quantity,
      unitPrice: entity.unitPrice,
      taxRate: entity.taxRate,
      total: entity.total,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'taxRate': taxRate,
      'total': total,
    };
  }

  InvoiceItemEntity toEntity() => InvoiceItemEntity(
    productId: productId,
    productName: productName,
    quantity: quantity,
    unitPrice: unitPrice,
    taxRate: taxRate,
    total: total,
  );
}

/// Invoice model for Firestore
class InvoiceModel extends InvoiceEntity {
  const InvoiceModel({
    required String id,
    required String invoiceNumber,
    required String customerId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required List<InvoiceItemEntity> items,
    required double subtotal,
    required double taxAmount,
    required double totalAmount,
    required String status,
    required String notes,
    required DateTime invoiceDate,
    required DateTime dueDate,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? pdfUrl,
  }) : super(
    id: id,
    invoiceNumber: invoiceNumber,
    customerId: customerId,
    customerName: customerName,
    customerEmail: customerEmail,
    customerPhone: customerPhone,
    items: items,
    subtotal: subtotal,
    taxAmount: taxAmount,
    totalAmount: totalAmount,
    status: status,
    notes: notes,
    invoiceDate: invoiceDate,
    dueDate: dueDate,
    createdAt: createdAt,
    updatedAt: updatedAt,
    pdfUrl: pdfUrl,
  );

  factory InvoiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InvoiceModel.fromMap({...data, 'id': doc.id});
  }

  factory InvoiceModel.fromMap(Map<String, dynamic> map) {
    final itemsList = map['items'] as List? ?? [];
    final items = itemsList
        .map((item) => InvoiceItemModel.fromMap(item as Map<String, dynamic>))
        .toList();

    return InvoiceModel(
      id: map['id'] as String? ?? '',
      invoiceNumber: map['invoiceNumber'] as String? ?? '',
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      customerEmail: map['customerEmail'] as String? ?? '',
      customerPhone: map['customerPhone'] as String? ?? '',
      items: items,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (map['taxAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'draft',
      notes: map['notes'] as String? ?? '',
      invoiceDate: map['invoiceDate'] is Timestamp
          ? (map['invoiceDate'] as Timestamp).toDate()
          : (map['invoiceDate'] as DateTime? ?? DateTime.now()),
      dueDate: map['dueDate'] is Timestamp
          ? (map['dueDate'] as Timestamp).toDate()
          : (map['dueDate'] as DateTime? ?? DateTime.now()),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : (map['createdAt'] as DateTime? ?? DateTime.now()),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : (map['updatedAt'] as DateTime? ?? DateTime.now()),
      pdfUrl: map['pdfUrl'] as String?,
    );
  }

  factory InvoiceModel.fromEntity(InvoiceEntity entity) {
    return InvoiceModel(
      id: entity.id,
      invoiceNumber: entity.invoiceNumber,
      customerId: entity.customerId,
      customerName: entity.customerName,
      customerEmail: entity.customerEmail,
      customerPhone: entity.customerPhone,
      items: entity.items,
      subtotal: entity.subtotal,
      taxAmount: entity.taxAmount,
      totalAmount: entity.totalAmount,
      status: entity.status,
      notes: entity.notes,
      invoiceDate: entity.invoiceDate,
      dueDate: entity.dueDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      pdfUrl: entity.pdfUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'invoiceNumber': invoiceNumber,
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'items': items
          .map((item) => (item as InvoiceItemModel).toMap())
          .toList(),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'status': status,
      'notes': notes,
      'invoiceDate': Timestamp.fromDate(invoiceDate),
      'dueDate': Timestamp.fromDate(dueDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'pdfUrl': pdfUrl,
    };
  }

  InvoiceEntity toEntity() {
    return InvoiceEntity(
      id: id,
      invoiceNumber: invoiceNumber,
      customerId: customerId,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      items: items,
      subtotal: subtotal,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
      status: status,
      notes: notes,
      invoiceDate: invoiceDate,
      dueDate: dueDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
      pdfUrl: pdfUrl,
    );
  }

  InvoiceModel copyWith({
    String? id,
    String? invoiceNumber,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    List<InvoiceItemEntity>? items,
    double? subtotal,
    double? taxAmount,
    double? totalAmount,
    String? status,
    String? notes,
    DateTime? invoiceDate,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? pdfUrl,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pdfUrl: pdfUrl ?? this.pdfUrl,
    );
  }
}
