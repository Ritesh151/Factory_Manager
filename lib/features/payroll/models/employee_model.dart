import 'package:cloud_firestore/cloud_firestore.dart';

/// Payment history entry for an employee
class PaymentHistoryEntry {
  final double amount;
  final DateTime date;
  final String month;
  final String? notes;

  PaymentHistoryEntry({
    required this.amount,
    required this.date,
    required this.month,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'month': month,
      'notes': notes,
    };
  }

  factory PaymentHistoryEntry.fromMap(Map<String, dynamic> map) {
    return PaymentHistoryEntry(
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      month: map['month'] ?? '',
      notes: map['notes'],
    );
  }
}

/// Employee model with payroll information
class EmployeeModel {
  final String id;
  final String name;
  final double salary;
  final String department;
  final DateTime joiningDate;
  final String? phone;
  final String? email;
  final List<PaymentHistoryEntry> paymentHistory;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  EmployeeModel({
    required this.id,
    required this.name,
    required this.salary,
    required this.department,
    required this.joiningDate,
    this.phone,
    this.email,
    this.paymentHistory = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate total salary paid
  double get totalPaid => paymentHistory.fold(0.0, (total, p) => total + p.amount);

  /// Get current month and year string
  String get _currentMonthYear {
    final now = DateTime.now();
    return '${now.month}/${now.year}';
  }

  /// Check if salary is paid for current month
  bool get isCurrentMonthPaid {
    return paymentHistory.any((p) => p.month == _currentMonthYear);
  }

  /// Get last payment date
  DateTime? get lastPaymentDate {
    if (paymentHistory.isEmpty) return null;
    return paymentHistory.last.date;
  }

  /// Predefined departments
  static const List<String> departments = [
    'Sales',
    'Marketing',
    'Operations',
    'Finance',
    'HR',
    'IT',
    'Management',
    'Other',
  ];

  factory EmployeeModel.fromMap(Map<String, dynamic> map, String documentId) {
    return EmployeeModel(
      id: documentId,
      name: map['name'] ?? '',
      salary: (map['salary'] as num?)?.toDouble() ?? 0.0,
      department: map['department'] ?? 'Other',
      joiningDate: (map['joiningDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      phone: map['phone'],
      email: map['email'],
      paymentHistory: (map['paymentHistory'] as List<dynamic>?)
              ?.map((e) => PaymentHistoryEntry.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'salary': salary,
      'department': department,
      'joiningDate': Timestamp.fromDate(joiningDate),
      'phone': phone,
      'email': email,
      'paymentHistory': paymentHistory.map((e) => e.toMap()).toList(),
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  EmployeeModel copyWith({
    String? id,
    String? name,
    double? salary,
    String? department,
    DateTime? joiningDate,
    String? phone,
    String? email,
    List<PaymentHistoryEntry>? paymentHistory,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      salary: salary ?? this.salary,
      department: department ?? this.department,
      joiningDate: joiningDate ?? this.joiningDate,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      paymentHistory: paymentHistory ?? this.paymentHistory,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
