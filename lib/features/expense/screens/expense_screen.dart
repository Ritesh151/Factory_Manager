import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/services/firebase_service.dart';
import '../../../shared/widgets/section_header.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';
import '../widgets/expense_form.dart';

/// Expense screen with category filtering
class ExpenseScreen extends ConsumerStatefulWidget {
  const ExpenseScreen({super.key});

  @override
  ConsumerState<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends ConsumerState<ExpenseScreen> {
  late final ExpenseService _expenseService;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    final firebaseService = FirebaseService();
    _expenseService = ExpenseService();
    _expenseService.initialize(firebaseService);
  }

  Future<void> _addExpense() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const ExpenseForm(),
    );

    if (result != null && mounted) {
      try {
        await _expenseService.createExpense(
          title: result['title'],
          amount: result['amount'],
          category: result['category'],
          date: result['date'],
          notes: result['notes'],
        );
        _showSnackBar('Expense added successfully', isError: false);
      } catch (e) {
        _showSnackBar('Failed to add expense: $e', isError: true);
      }
    }
  }

  Future<void> _deleteExpense(ExpenseModel expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text('Are you sure you want to delete "${expense.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _expenseService.deleteExpense(expense.id);
        _showSnackBar('Expense deleted successfully', isError: false);
      } catch (e) {
        _showSnackBar('Failed to delete expense: $e', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SectionHeader(title: 'Expenses'),
                FilledButton.icon(
                  onPressed: _addExpense,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Expense'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Category filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  'All',
                  ...ExpenseModel.categories,
                ].map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(category),
                      onSelected: (_) => setState(() => _selectedCategory = category),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Expenses list
            Expanded(
              child: StreamBuilder<List<ExpenseModel>>(
                stream: _selectedCategory == 'All' 
                    ? _expenseService.streamExpenses()
                    : _expenseService.streamExpensesByCategory(_selectedCategory),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading expenses...'),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                          const SizedBox(height: 16),
                          Text('Error: ${snapshot.error}'),
                        ],
                      ),
                    );
                  }

                  final expenses = snapshot.data ?? [];

                  if (expenses.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_outlined, size: 80, color: theme.colorScheme.outline),
                          const SizedBox(height: 16),
                          Text(
                            'No expenses found',
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first expense',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: _addExpense,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Expense'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Calculate total
                  final total = expenses.fold(0.0, (sum, e) => sum + e.amount);

                  return Column(
                    children: [
                      // Total card
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedCategory == 'All' 
                                    ? 'Total Expenses' 
                                    : '$_selectedCategory Expenses',
                                style: theme.textTheme.titleMedium,
                              ),
                              Text(
                                '₹${total.toStringAsFixed(2)}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // List
                      Expanded(
                        child: ListView.builder(
                          itemCount: expenses.length,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemBuilder: (context, index) {
                            final expense = expenses[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: _getCategoryColor(expense.category),
                                  child: Icon(
                                    _getCategoryIcon(expense.category),
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  expense.title,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(expense.category),
                                    Text(
                                      DateFormat('dd/MM/yyyy').format(expense.date),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.outline,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '₹${expense.amount.toStringAsFixed(2)}',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.error,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                                      onPressed: () => _deleteExpense(expense),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Rent': return Colors.blue;
      case 'Utilities': return Colors.orange;
      case 'Salaries': return Colors.green;
      case 'Transportation': return Colors.purple;
      case 'Marketing': return Colors.pink;
      case 'Office Supplies': return Colors.teal;
      case 'Maintenance': return Colors.brown;
      case 'Insurance': return Colors.indigo;
      case 'Taxes': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Rent': return Icons.home;
      case 'Utilities': return Icons.bolt;
      case 'Salaries': return Icons.people;
      case 'Transportation': return Icons.local_shipping;
      case 'Marketing': return Icons.campaign;
      case 'Office Supplies': return Icons.folder;
      case 'Maintenance': return Icons.build;
      case 'Insurance': return Icons.security;
      case 'Taxes': return Icons.account_balance;
      default: return Icons.receipt;
    }
  }
}
