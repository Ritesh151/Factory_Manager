import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../core/services/firebase_service.dart';
import '../models/expense_model.dart';

/// Service for managing expenses
class ExpenseService {
  static final ExpenseService _instance = ExpenseService._internal();
  
  factory ExpenseService() => _instance;
  ExpenseService._internal();

  FirebaseFirestore? _firestore;

  /// Initialize with FirebaseService
  void initialize(FirebaseService firebaseService) {
    _firestore = firebaseService.firestore;
  }

  /// Get expenses collection reference
  CollectionReference<Map<String, dynamic>> get _expensesCollection {
    if (_firestore == null) {
      throw StateError('ExpenseService not initialized');
    }
    return _firestore!.collection('expenses');
  }

  /// Stream of all expenses ordered by date
  Stream<List<ExpenseModel>> streamExpenses() {
    try {
      return _expensesCollection
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return ExpenseModel.fromMap(doc.data(), doc.id);
        }).toList();
      });
    } catch (e) {
      debugPrint('ExpenseService: Error streaming expenses: $e');
      return Stream.error(e);
    }
  }

  /// Stream of expenses by category
  Stream<List<ExpenseModel>> streamExpensesByCategory(String category) {
    try {
      return _expensesCollection
          .where('category', isEqualTo: category)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return ExpenseModel.fromMap(doc.data(), doc.id);
        }).toList();
      });
    } catch (e) {
      debugPrint('ExpenseService: Error streaming expenses by category: $e');
      return Stream.error(e);
    }
  }

  /// Create a new expense
  Future<ExpenseModel> createExpense({
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    String? notes,
  }) async {
    try {
      if (title.trim().isEmpty) {
        throw ArgumentError('Title is required');
      }
      if (amount <= 0) {
        throw ArgumentError('Amount must be greater than 0');
      }

      final expense = ExpenseModel(
        id: '',
        title: title.trim(),
        amount: amount,
        category: category,
        date: date,
        notes: notes?.trim(),
        createdAt: DateTime.now(),
      );

      final docRef = await _expensesCollection.add(expense.toMap());
      
      debugPrint('ExpenseService: Created expense ${expense.title}');
      
      return expense.copyWith(id: docRef.id);
    } catch (e) {
      debugPrint('ExpenseService: Failed to create expense: $e');
      rethrow;
    }
  }

  /// Update an expense
  Future<void> updateExpense(String id, {
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? notes,
  }) async {
    try {
      if (id.isEmpty) throw ArgumentError('Expense ID is required');

      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title.trim();
      if (amount != null) updates['amount'] = amount;
      if (category != null) updates['category'] = category;
      if (date != null) updates['date'] = Timestamp.fromDate(date);
      if (notes != null) updates['notes'] = notes.trim();

      await _expensesCollection.doc(id).update(updates);
      
      debugPrint('ExpenseService: Updated expense $id');
    } catch (e) {
      debugPrint('ExpenseService: Failed to update expense: $e');
      rethrow;
    }
  }

  /// Delete an expense
  Future<void> deleteExpense(String id) async {
    try {
      if (id.isEmpty) throw ArgumentError('Expense ID is required');

      await _expensesCollection.doc(id).delete();
      
      debugPrint('ExpenseService: Deleted expense $id');
    } catch (e) {
      debugPrint('ExpenseService: Failed to delete expense: $e');
      rethrow;
    }
  }

  /// Get expenses for date range
  Future<List<ExpenseModel>> getExpensesByDateRange(DateTime start, DateTime end) async {
    try {
      final snapshot = await _expensesCollection
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) => ExpenseModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      debugPrint('ExpenseService: Failed to get expenses by date range: $e');
      return [];
    }
  }

  /// Get monthly expense total
  Future<double> getMonthlyExpenseTotal(int year, int month) async {
    try {
      final start = DateTime(year, month, 1);
      final end = DateTime(year, month + 1, 0, 23, 59, 59);

      final snapshot = await _expensesCollection
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      double total = 0.0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        total += (data['amount'] as num?)?.toDouble() ?? 0.0;
      }

      return total;
    } catch (e) {
      debugPrint('ExpenseService: Failed to get monthly total: $e');
      return 0.0;
    }
  }

  /// Get expenses grouped by category for a month
  Future<Map<String, double>> getExpensesByCategoryForMonth(int year, int month) async {
    try {
      final start = DateTime(year, month, 1);
      final end = DateTime(year, month + 1, 0, 23, 59, 59);

      final snapshot = await _expensesCollection
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      final Map<String, double> categoryTotals = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final category = data['category'] as String? ?? 'Other';
        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
        categoryTotals[category] = (categoryTotals[category] ?? 0.0) + amount;
      }

      return categoryTotals;
    } catch (e) {
      debugPrint('ExpenseService: Failed to get category totals: $e');
      return {};
    }
  }
}
