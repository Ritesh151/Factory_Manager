import 'dart:typed_data';
import '../entities/invoice_entity.dart';

/// Service for generating and processing invoices
abstract class InvoiceService {
  /// Generate a new invoice from transaction data
  Future<InvoiceEntity> generateInvoice({
    required String billNo,
    required String customerVendorName,
    required String customerVendorAddress,
    required String customerVendorGst,
    required String productName,
    required String productDescription,
    required double quantity,
    required double unitPrice,
    required double gstRate,
    required double transportCharges,
    required String transactionType, // 'sale' or 'purchase'
    required String paymentMethod,
    String? notes,
    String? terms,
  });

  /// Generate invoice number automatically
  Future<String> generateInvoiceNumber();

  /// Export invoice to PDF
  Future<Uint8List> exportToPdf(InvoiceEntity invoice);

  /// Export invoice to JSON
  Map<String, dynamic> exportToJson(InvoiceEntity invoice);

  /// Calculate GST amount
  double calculateGstAmount(double subtotal, double gstRate);

  /// Calculate grand total
  double calculateGrandTotal(double subtotal, double gstAmount, double transportCharges);
}

/// Implementation of InvoiceService
class InvoiceServiceImpl implements InvoiceService {
  // Default company details - can be made configurable
  static const String _companyName = 'SmartERP';
  static const String _companyAddress = '123 Business Street, City, State - 400001';
  static const String _companyPhone = '+91-98765-43210';
  static const String _companyEmail = 'info@smarterp.com';
  static const String _companyGst = '27AABCT1234H1Z0';
  static const String _companyPan = 'AABCT1234H';

  @override
  Future<String> generateInvoiceNumber() async {
    // Implementation: Generate unique invoice number
    // In production, this would query database for the latest invoice number
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = (10000 + (timestamp % 90000)).toString();
    return 'INV-${DateTime.now().year}-$randomPart';
  }

  @override
  double calculateGstAmount(double subtotal, double gstRate) {
    return (subtotal * gstRate) / 100;
  }

  @override
  double calculateGrandTotal(double subtotal, double gstAmount, double transportCharges) {
    return subtotal + gstAmount + transportCharges;
  }

  @override
  Future<InvoiceEntity> generateInvoice({
    required String billNo,
    required String customerVendorName,
    required String customerVendorAddress,
    required String customerVendorGst,
    required String productName,
    required String productDescription,
    required double quantity,
    required double unitPrice,
    required double gstRate,
    required double transportCharges,
    required String transactionType,
    required String paymentMethod,
    String? notes,
    String? terms,
  }) async {
    final invoiceNumber = await generateInvoiceNumber();
    final subtotal = quantity * unitPrice;
    final gstAmount = calculateGstAmount(subtotal, gstRate);
    final grandTotal = calculateGrandTotal(subtotal, gstAmount, transportCharges);
    final now = DateTime.now();

    return InvoiceEntity(
      invoiceNumber: invoiceNumber,
      invoiceDate: now,
      billNo: billNo,
      companyName: _companyName,
      companyAddress: _companyAddress,
      companyPhone: _companyPhone,
      companyEmail: _companyEmail,
      companyGst: _companyGst,
      companyPan: _companyPan,
      customerVendorName: customerVendorName,
      customerVendorAddress: customerVendorAddress,
      customerVendorGst: customerVendorGst,
      transactionType: transactionType,
      productName: productName,
      productDescription: productDescription,
      quantity: quantity,
      unitPrice: unitPrice,
      subtotal: subtotal,
      gstRate: gstRate,
      gstAmount: gstAmount,
      transportCharges: transportCharges,
      grandTotal: grandTotal,
      paymentMethod: paymentMethod,
      paymentStatus: 'pending',
      terms: terms,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Uint8List exportToPdf(InvoiceEntity invoice) {
    // This is a placeholder. In production, use pdf package
    // For now, we'll create a simple PDF-like structure
    // The actual PDF generation would use the `pdf` package
    throw UnimplementedError('PDF export requires pdf package integration');
  }

  @override
  Map<String, dynamic> exportToJson(InvoiceEntity invoice) {
    return {
      'invoiceNumber': invoice.invoiceNumber,
      'invoiceDate': invoice.invoiceDate.toIso8601String(),
      'billNo': invoice.billNo,
      'referenceNo': invoice.referenceNo,
      'company': {
        'name': invoice.companyName,
        'address': invoice.companyAddress,
        'phone': invoice.companyPhone,
        'email': invoice.companyEmail,
        'gst': invoice.companyGst,
        'pan': invoice.companyPan,
      },
      'customer': {
        'name': invoice.customerVendorName,
        'address': invoice.customerVendorAddress,
        'gst': invoice.customerVendorGst,
      },
      'transaction': {
        'type': invoice.transactionType,
        'billNo': invoice.billNo,
      },
      'items': [
        {
          'name': invoice.productName,
          'description': invoice.productDescription,
          'quantity': invoice.quantity,
          'unitPrice': invoice.unitPrice,
        }
      ],
      'calculations': {
        'subtotal': invoice.subtotal,
        'gstRate': invoice.gstRate,
        'gstAmount': invoice.gstAmount,
        'transportCharges': invoice.transportCharges,
        'grandTotal': invoice.grandTotal,
      },
      'payment': {
        'method': invoice.paymentMethod,
        'status': invoice.paymentStatus,
      },
      'notes': invoice.notes,
      'terms': invoice.terms,
    };
  }
}
