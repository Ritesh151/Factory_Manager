import '../entities/expense_entity.dart';

/// Abstract repository for expense operations
abstract class ExpenseRepository {
  /// Get a stream of all expenses
  Stream<List<ExpenseEntity>> getAllExpensesStream();

  /// Get expenses for a specific date range
  Future<List<ExpenseEntity>> getExpensesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get expenses by category
  Stream<List<ExpenseEntity>> getExpensesByCategoryStream(String category);

  /// Get expenses by status (pending, approved, rejected)
  Stream<List<ExpenseEntity>> getExpensesByStatusStream(String status);

  /// Create a new expense
  Future<ExpenseEntity> createExpense(ExpenseEntity expense);

  /// Update an expense
  Future<ExpenseEntity> updateExpense(ExpenseEntity expense);

  /// Delete an expense
  Future<void> deleteExpense(String expenseId);

  /// Update expense status
  Future<void> updateExpenseStatus(String expenseId, String newStatus);

  /// Upload receipt image/PDF and return URL
  Future<String> uploadReceipt(String expenseId, String filePath);

  /// Get total expenses for a date range
  Future<double> getTotalExpenses({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get expenses grouped by category
  Future<Map<String, double>> getExpensesByCategory({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Search expenses by title or description
  Future<List<ExpenseEntity>> searchExpenses(String query);

  /// Approve all pending expenses (admin function)
  Future<void> approvePendingExpenses(List<String> expenseIds);
}
