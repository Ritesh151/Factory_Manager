import 'package:equatable/equatable.dart';
import '../../../core/constants/company_info.dart';

class LineItem extends Equatable {
  final int srNo;
  final String description;
  final String hsnCode;
  final double qty;
  final double rate;
  final double amount;

  const LineItem({
    required this.srNo,
    required this.description,
    required this.hsnCode,
    required this.qty,
    required this.rate,
    required this.amount,
  });

  LineItem copyWith({
    int? srNo,
    String? description,
    String? hsnCode,
    double? qty,
    double? rate,
    double? amount,
  }) {
    return LineItem(
      srNo: srNo ?? this.srNo,
      description: description ?? this.description,
      hsnCode: hsnCode ?? this.hsnCode,
      qty: qty ?? this.qty,
      rate: rate ?? this.rate,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'srNo': srNo,
      'description': description,
      'hsnCode': hsnCode,
      'qty': qty,
      'rate': rate,
      'amount': amount,
    };
  }

  factory LineItem.fromMap(Map<String, dynamic> map) {
    return LineItem(
      srNo: map['srNo'] ?? 0,
      description: map['description'] ?? '',
      hsnCode: map['hsnCode'] ?? '',
      qty: (map['qty'] ?? 0).toDouble(),
      rate: (map['rate'] ?? 0).toDouble(),
      amount: (map['amount'] ?? 0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [srNo, description, hsnCode, qty, rate, amount];
}

class InvoiceModel extends Equatable {
  final String id;
  final String invoiceNo;
  final DateTime date;
  
  // Company Details
  static String get companyNameConst => CompanyInfo.name;
  static String get companyAddressConst => CompanyInfo.address;
  static String get companyGSTINConst => CompanyInfo.gstin;
  static const String companyPANConst = "BCTPC3372F";
  static String get companyContactConst => CompanyInfo.formattedPhone;
  static String get companyEmailConst => CompanyInfo.email;

  // Header Details
  final String transportName;
  final String vehicleNo;
  final String deliveryAt;

  // Customer Details
  final String customerName;
  final String customerGSTNo;
  final String customerAddress;
  final String customerState; 

  // Table Data
  final List<LineItem> items;

  // Financial Summary
  final double subtotal;
  final double cgstRate; 
  final double sgstRate;
  final double igstRate;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double transportCharges;
  final double roundOff;
  final double grandTotal;
  final String totalInWords;

  const InvoiceModel({
    required this.id,
    required this.invoiceNo,
    required this.date,
    required this.transportName,
    required this.vehicleNo,
    required this.deliveryAt,
    required this.customerName,
    required this.customerGSTNo,
    required this.customerAddress,
    required this.customerState,
    required this.items,
    required this.subtotal,
    this.cgstRate = 0.09,
    this.sgstRate = 0.09,
    this.igstRate = 0.18,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.transportCharges,
    required this.roundOff,
    required this.grandTotal,
    required this.totalInWords,
  });

  factory InvoiceModel.empty() {
    return InvoiceModel(
      id: '',
      invoiceNo: '',
      date: DateTime.now(),
      transportName: '',
      vehicleNo: '',
      deliveryAt: '',
      customerName: '',
      customerGSTNo: '',
      customerAddress: '',
      customerState: 'MAHARASHTRA',
      items: const [],
      subtotal: 0,
      cgstAmount: 0,
      sgstAmount: 0,
      igstAmount: 0,
      transportCharges: 0,
      roundOff: 0,
      grandTotal: 0,
      totalInWords: 'Zero Rupees Only',
    );
  }

  InvoiceModel copyWith({
    String? id,
    String? invoiceNo,
    DateTime? date,
    String? transportName,
    String? vehicleNo,
    String? deliveryAt,
    String? customerName,
    String? customerGSTNo,
    String? customerAddress,
    String? customerState,
    List<LineItem>? items,
    double? subtotal,
    double? cgstAmount,
    double? sgstAmount,
    double? igstAmount,
    double? transportCharges,
    double? roundOff,
    double? grandTotal,
    String? totalInWords,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      date: date ?? this.date,
      transportName: transportName ?? this.transportName,
      vehicleNo: vehicleNo ?? this.vehicleNo,
      deliveryAt: deliveryAt ?? this.deliveryAt,
      customerName: customerName ?? this.customerName,
      customerGSTNo: customerGSTNo ?? this.customerGSTNo,
      customerAddress: customerAddress ?? this.customerAddress,
      customerState: customerState ?? this.customerState,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      cgstAmount: cgstAmount ?? this.cgstAmount,
      sgstAmount: sgstAmount ?? this.sgstAmount,
      igstAmount: igstAmount ?? this.igstAmount,
      transportCharges: transportCharges ?? this.transportCharges,
      roundOff: roundOff ?? this.roundOff,
      grandTotal: grandTotal ?? this.grandTotal,
      totalInWords: totalInWords ?? this.totalInWords,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNo': invoiceNo,
      'date': date.toIso8601String(),
      'transportName': transportName,
      'vehicleNo': vehicleNo,
      'deliveryAt': deliveryAt,
      'customerName': customerName,
      'customerGSTNo': customerGSTNo,
      'customerAddress': customerAddress,
      'customerState': customerState,
      'items': items.map((x) => x.toMap()).toList(),
      'subtotal': subtotal,
      'cgstAmount': cgstAmount,
      'sgstAmount': sgstAmount,
      'igstAmount': igstAmount,
      'transportCharges': transportCharges,
      'roundOff': roundOff,
      'grandTotal': grandTotal,
      'totalInWords': totalInWords,
    };
  }

  factory InvoiceModel.fromMap(Map<String, dynamic> map) {
    return InvoiceModel(
      id: map['id'] ?? '',
      invoiceNo: map['invoiceNo'] ?? '',
      date: DateTime.parse(map['date']),
      transportName: map['transportName'] ?? '',
      vehicleNo: map['vehicleNo'] ?? '',
      deliveryAt: map['deliveryAt'] ?? '',
      customerName: map['customerName'] ?? '',
      customerGSTNo: map['customerGSTNo'] ?? '',
      customerAddress: map['customerAddress'] ?? '',
      customerState: map['customerState'] ?? 'MAHARASHTRA',
      items: List<LineItem>.from(map['items']?.map((x) => LineItem.fromMap(x)) ?? []),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      cgstAmount: (map['cgstAmount'] ?? 0).toDouble(),
      sgstAmount: (map['sgstAmount'] ?? 0).toDouble(),
      igstAmount: (map['igstAmount'] ?? 0).toDouble(),
      transportCharges: (map['transportCharges'] ?? 0).toDouble(),
      roundOff: (map['roundOff'] ?? 0).toDouble(),
      grandTotal: (map['grandTotal'] ?? 0).toDouble(),
      totalInWords: map['totalInWords'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
        id,
        invoiceNo,
        date,
        transportName,
        vehicleNo,
        deliveryAt,
        customerName,
        customerGSTNo,
        customerAddress,
        customerState,
        items,
        subtotal,
        cgstAmount,
        sgstAmount,
        igstAmount,
        transportCharges,
        roundOff,
        grandTotal,
        totalInWords,
      ];
}
