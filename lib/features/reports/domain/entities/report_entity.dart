import 'package:equatable/equatable.dart';

/// Report entity for business analytics
class ReportEntity extends Equatable {
  final String id;
  final String title;
  final String type; // sales, expenses, revenue, inventory, etc.
  final double totalSales;
  final double totalExpenses;
  final double profit;
  final int invoiceCount;
  final int expenseCount;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime generatedAt;

  const ReportEntity({
    required this.id,
    required this.title,
    required this.type,
    required this.totalSales,
    required this.totalExpenses,
    required this.profit,
    required this.invoiceCount,
    required this.expenseCount,
    required this.startDate,
    required this.endDate,
    required this.generatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        type,
        totalSales,
        totalExpenses,
        profit,
        invoiceCount,
        expenseCount,
        startDate,
        endDate,
        generatedAt,
      ];
}
