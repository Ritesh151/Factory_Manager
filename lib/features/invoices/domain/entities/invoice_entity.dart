import 'package:equatable/equatable.dart';

/// Invoice line item entity
class InvoiceItemEntity extends Equatable {
  final String productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double taxRate;
  final double total;

  const InvoiceItemEntity({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.taxRate,
    required this.total,
  });

  /// Calculate tax amount for this item
  double get taxAmount => total * (taxRate / 100);

  /// Calculate subtotal before tax
  double get subtotal => quantity * unitPrice;

  @override
  List<Object?> get props => [
        productId,
        productName,
        quantity,
        unitPrice,
        taxRate,
        total,
      ];
}

/// Invoice entity representing a sales invoice
class InvoiceEntity extends Equatable {
  final String id;
  final String invoiceNumber;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final List<InvoiceItemEntity> items;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final String status; // draft, sent, paid, overdue
  final String notes;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? pdfUrl; // Firebase Storage URL for generated PDF

  const InvoiceEntity({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
    required this.status,
    required this.notes,
    required this.invoiceDate,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.pdfUrl,
  });

  /// Copy with method for creating modified copies
  InvoiceEntity copyWith({
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
    return InvoiceEntity(
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

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        customerId,
        customerName,
        customerEmail,
        customerPhone,
        items,
        subtotal,
        taxAmount,
        totalAmount,
        status,
        notes,
        invoiceDate,
        dueDate,
        createdAt,
        updatedAt,
        pdfUrl,
      ];
}
