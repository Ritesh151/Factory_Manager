import 'package:equatable/equatable.dart';

class SalaryPayment extends Equatable {
  const SalaryPayment({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.month,
    required this.year,
    required this.monthYear,
    required this.amount,
    required this.paymentDate,
    required this.paymentMode,
    this.workingDays,
    this.paidDays,
    this.notes,
    this.isLocked = true,
    required this.createdAt,
  });

  final String id;
  final String employeeId;
  final String employeeName;
  final int month;
  final int year;
  final String monthYear;
  final double amount;
  final DateTime paymentDate;
  final String paymentMode;
  final int? workingDays;
  final int? paidDays;
  final String? notes;
  final bool isLocked;
  final DateTime createdAt;

  @override
  List<Object?> get props =>
      [id, employeeId, month, year, amount, paymentDate];
}
