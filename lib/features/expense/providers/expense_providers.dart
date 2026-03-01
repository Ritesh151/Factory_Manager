import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';
import '../../../core/providers/firebase_provider.dart';

/// Expense service provider
final expenseServiceProvider = Provider((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  final service = ExpenseService();
  service.initialize(firebaseService);
  return service;
});

/// Stream all expenses
final expensesStreamProvider = StreamProvider((ref) {
  return ref.watch(expenseServiceProvider).streamExpenses();
});

/// Stream expenses by category
final expensesByCategoryProvider = StreamProvider.family<List<ExpenseModel>, String>((ref, category) {
  return ref.watch(expenseServiceProvider).streamExpensesByCategory(category);
});

/// Cached expenses
final expensesCacheProvider = FutureProvider((ref) async {
  final service = ref.watch(expenseServiceProvider);
  try {
    final stream = service.streamExpenses();
    return await stream.first;
  } catch (e) {
    throw Exception('Failed to fetch expenses: $e');
  }
});

/// Monthly expenses total
final monthlyExpensesTotalProvider = FutureProvider.family<double, (int, int)>((ref, params) async {
  final service = ref.watch(expenseServiceProvider);
  final (year, month) = params;
  try {
    return await service.getMonthlyExpensesTotal(year, month);
  } catch (e) {
    throw Exception('Failed to fetch monthly expenses: $e');
  }
});
