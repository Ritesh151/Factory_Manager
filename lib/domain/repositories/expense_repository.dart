import '../entities/expense.dart';
import '../value_objects/date_range.dart';

abstract class ExpenseRepository {
  Stream<List<Expense>> watchByDateRange(
    String userId, {
    DateRange? dateRange,
    String? category,
  });
  Future<List<Expense>> getByDateRange(
    String userId,
    DateRange dateRange, {
    String? category,
  });
  Future<Expense?> getById(String userId, String expenseId);
  Future<Expense> create(String userId, Expense expense);
  Future<Expense> update(String userId, Expense expense);
  Future<void> delete(String userId, String expenseId);
  Future<double> getMonthlyTotal(String userId, DateTime month);
  Future<Map<String, double>> getCategoryTotals(
    String userId,
    DateRange dateRange,
  );
}
