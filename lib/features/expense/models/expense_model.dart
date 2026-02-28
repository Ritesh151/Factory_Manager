import 'package:cloud_firestore/cloud_firestore.dart';

/// Expense model for tracking business expenses
class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
    required this.createdAt,
  });

  /// Predefined expense categories
  static const List<String> categories = [
    'Rent',
    'Utilities',
    'Salaries',
    'Transportation',
    'Marketing',
    'Office Supplies',
    'Maintenance',
    'Insurance',
    'Taxes',
    'Other',
  ];

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ExpenseModel(
      id: documentId,
      title: map['title'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] ?? 'Other',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ExpenseModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
