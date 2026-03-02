import 'package:equatable/equatable.dart';

/// Expense entity representing business expenses
class ExpenseEntity extends Equatable {
  final String id;
  final String title;
  final String category; // office supplies, travel, meals, utilities, etc.
  final double amount;
  final String description;
  final List<String> receiptUrls; // URLs to receipt images/PDFs
  final String status; // pending, approved, rejected
  final DateTime expenseDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy; // User ID who created this expense

  const ExpenseEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.description,
    required this.receiptUrls,
    required this.status,
    required this.expenseDate,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  ExpenseEntity copyWith({
    String? id,
    String? title,
    String? category,
    double? amount,
    String? description,
    List<String>? receiptUrls,
    String? status,
    DateTime? expenseDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      receiptUrls: receiptUrls ?? this.receiptUrls,
      status: status ?? this.status,
      expenseDate: expenseDate ?? this.expenseDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        category,
        amount,
        description,
        receiptUrls,
        status,
        expenseDate,
        createdAt,
        updatedAt,
        createdBy,
      ];
}
