/// Invoice entity representing a complete invoice
class InvoiceEntity {
  final String? id;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final String billNo;
  final String? referenceNo;
  
  // Company Details (auto-filled)
  final String companyName;
  final String companyAddress;
  final String companyPhone;
  final String companyEmail;
  final String companyGst;
  final String companyPan;
  
  // Customer/Vendor Details
  final String customerVendorName;
  final String customerVendorAddress;
  final String customerVendorGst;
  
  // Transaction Details
  final String transactionType; // 'sale' or 'purchase'
  final String productName;
  final String productDescription;
  final double quantity;
  final double unitPrice;
  
  // Calculations
  final double subtotal;
  final double gstRate;
  final double gstAmount;
  final double transportCharges;
  final double grandTotal;
  
  // Payment Details
  final String paymentMethod;
  final String paymentStatus;
  
  // Terms & Notes
  final String? terms;
  final String? notes;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  InvoiceEntity({
    this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.billNo,
    this.referenceNo,
    required this.companyName,
    required this.companyAddress,
    required this.companyPhone,
    required this.companyEmail,
    required this.companyGst,
    required this.companyPan,
    required this.customerVendorName,
    required this.customerVendorAddress,
    required this.customerVendorGst,
    required this.transactionType,
    required this.productName,
    required this.productDescription,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.gstRate,
    required this.gstAmount,
    required this.transportCharges,
    required this.grandTotal,
    required this.paymentMethod,
    required this.paymentStatus,
    this.terms,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  InvoiceEntity copyWith({
    String? id,
    String? invoiceNumber,
    DateTime? invoiceDate,
    String? billNo,
    String? referenceNo,
    String? companyName,
    String? companyAddress,
    String? companyPhone,
    String? companyEmail,
    String? companyGst,
    String? companyPan,
    String? customerVendorName,
    String? customerVendorAddress,
    String? customerVendorGst,
    String? transactionType,
    String? productName,
    String? productDescription,
    double? quantity,
    double? unitPrice,
    double? subtotal,
    double? gstRate,
    double? gstAmount,
    double? transportCharges,
    double? grandTotal,
    String? paymentMethod,
    String? paymentStatus,
    String? terms,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvoiceEntity(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      billNo: billNo ?? this.billNo,
      referenceNo: referenceNo ?? this.referenceNo,
      companyName: companyName ?? this.companyName,
      companyAddress: companyAddress ?? this.companyAddress,
      companyPhone: companyPhone ?? this.companyPhone,
      companyEmail: companyEmail ?? this.companyEmail,
      companyGst: companyGst ?? this.companyGst,
      companyPan: companyPan ?? this.companyPan,
      customerVendorName: customerVendorName ?? this.customerVendorName,
      customerVendorAddress: customerVendorAddress ?? this.customerVendorAddress,
      customerVendorGst: customerVendorGst ?? this.customerVendorGst,
      transactionType: transactionType ?? this.transactionType,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
      gstRate: gstRate ?? this.gstRate,
      gstAmount: gstAmount ?? this.gstAmount,
      transportCharges: transportCharges ?? this.transportCharges,
      grandTotal: grandTotal ?? this.grandTotal,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      terms: terms ?? this.terms,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
