import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  const Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.expenseDate,
    this.subCategory,
    this.description,
    this.paymentMode,
    this.gstAmount,
    this.gstRate,
    this.vendor,
    this.billNumber,
    this.isLocked = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final double amount;
  final String category;
  final DateTime expenseDate;
  final String? subCategory;
  final String? description;
  final String? paymentMode;
  final double? gstAmount;
  final int? gstRate;
  final String? vendor;
  final String? billNumber;
  final bool isLocked;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props =>
      [id, amount, category, expenseDate, createdAt];
}
