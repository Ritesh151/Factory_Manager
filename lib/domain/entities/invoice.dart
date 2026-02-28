import 'package:equatable/equatable.dart';

class Invoice extends Equatable {
  const Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.customer,
    required this.lineItems,
    required this.summary,
    this.isLocked = true,
    this.notes,
    this.terms,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final InvoiceCustomer customer;
  final List<InvoiceLineItem> lineItems;
  final InvoiceSummary summary;
  final bool isLocked;
  final String? notes;
  final String? terms;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props =>
      [id, invoiceNumber, invoiceDate, customer, lineItems, summary, isLocked];
}

class InvoiceCustomer extends Equatable {
  const InvoiceCustomer({
    required this.name,
    required this.address,
    this.gstin,
    this.phone,
  });
  final String name;
  final String address;
  final String? gstin;
  final String? phone;
  @override
  List<Object?> get props => [name, address, gstin, phone];
}

class InvoiceLineItem extends Equatable {
  const InvoiceLineItem({
    required this.productId,
    required this.productName,
    required this.hsnCode,
    required this.quantity,
    required this.unit,
    required this.rate,
    required this.gstRate,
    required this.amount,
    required this.gstAmount,
    required this.totalAmount,
  });
  final String productId;
  final String productName;
  final String hsnCode;
  final double quantity;
  final String unit;
  final double rate;
  final int gstRate;
  final double amount;
  final double gstAmount;
  final double totalAmount;
  @override
  List<Object?> get props =>
      [productId, productName, quantity, rate, amount, totalAmount];
}

class InvoiceSummary extends Equatable {
  const InvoiceSummary({
    required this.subtotal,
    required this.totalCgst,
    required this.totalSgst,
    required this.totalIgst,
    required this.totalGst,
    required this.totalAmount,
    this.roundOff = 0,
    required this.amountInWords,
  });
  final double subtotal;
  final double totalCgst;
  final double totalSgst;
  final double totalIgst;
  final double totalGst;
  final double totalAmount;
  final double roundOff;
  final String amountInWords;
  @override
  List<Object?> get props =>
      [subtotal, totalCgst, totalSgst, totalAmount, amountInWords];
}
