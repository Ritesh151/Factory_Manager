import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/services/firebase_service.dart';
import '../../../shared/widgets/section_header.dart';
import '../models/employee_model.dart';
import '../services/payroll_service.dart';
import '../widgets/employee_form.dart';
import '../widgets/salary_payment_dialog.dart';

/// Payroll screen for employee management
class PayrollScreen extends ConsumerStatefulWidget {
  const PayrollScreen({super.key});

  @override
  ConsumerState<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends ConsumerState<PayrollScreen> {
  late final PayrollService _payrollService;

  @override
  void initState() {
    super.initState();
    final firebaseService = FirebaseService();
    _payrollService = PayrollService();
    _payrollService.initialize(firebaseService);
  }

  Future<void> _addEmployee() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const EmployeeForm(),
    );

    if (result != null && mounted) {
      try {
        await _payrollService.createEmployee(
          name: result['name'],
          salary: result['salary'],
          department: result['department'],
          joiningDate: result['joiningDate'],
          phone: result['phone'],
          email: result['email'],
        );
        _showSnackBar('Employee added successfully', isError: false);
      } catch (e) {
        _showSnackBar('Failed to add employee: $e', isError: true);
      }
    }
  }

  Future<void> _paySalary(EmployeeModel employee) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SalaryPaymentDialog(
        employeeName: employee.name,
        salary: employee.salary,
      ),
    );

    if (result != null && mounted) {
      try {
        await _payrollService.paySalary(
          employee.id,
          amount: result['amount'],
          notes: result['notes'],
        );
        _showSnackBar('Salary paid successfully', isError: false);
      } catch (e) {
        _showSnackBar('Failed to pay salary: $e', isError: true);
      }
    }
  }

  Future<void> _deleteEmployee(EmployeeModel employee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete "${employee.name}"?'),
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
        await _payrollService.deleteEmployee(employee.id);
        _showSnackBar('Employee deleted successfully', isError: false);
      } catch (e) {
        _showSnackBar('Failed to delete employee: $e', isError: true);
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
                const SectionHeader(title: 'Payroll'),
                FilledButton.icon(
                  onPressed: _addEmployee,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Employee'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Employees list
            Expanded(
              child: StreamBuilder<List<EmployeeModel>>(
                stream: _payrollService.streamEmployees(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading employees...'),
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

                  final employees = snapshot.data ?? [];

                  if (employees.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 80, color: theme.colorScheme.outline),
                          const SizedBox(height: 16),
                          Text(
                            'No employees yet',
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first employee',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: _addEmployee,
                            icon: const Icon(Icons.person_add),
                            label: const Text('Add Employee'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Calculate totals
                  final activeEmployees = employees.where((e) => e.isActive).toList();
                  final totalMonthlySalary = activeEmployees.fold(0.0, (sum, e) => sum + e.salary);
                  final totalPaid = employees.fold(0.0, (sum, e) => sum + e.totalPaid);

                  return Column(
                    children: [
                      // Summary cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              'Total Employees',
                              '${employees.length}',
                              Icons.people,
                              theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSummaryCard(
                              'Monthly Salary',
                              '₹${totalMonthlySalary.toStringAsFixed(0)}',
                              Icons.account_balance_wallet,
                              theme.colorScheme.tertiary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSummaryCard(
                              'Total Paid',
                              '₹${totalPaid.toStringAsFixed(0)}',
                              Icons.paid,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // List
                      Expanded(
                        child: ListView.builder(
                          itemCount: employees.length,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemBuilder: (context, index) {
                            final employee = employees[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                  backgroundColor: employee.isActive 
                                      ? theme.colorScheme.primaryContainer
                                      : theme.colorScheme.surfaceContainerHighest,
                                  child: Icon(
                                    Icons.person,
                                    color: employee.isActive
                                        ? theme.colorScheme.onPrimaryContainer
                                        : theme.colorScheme.outline,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        employee.name,
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          decoration: employee.isActive ? null : TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ),
                                    if (!employee.isCurrentMonthPaid && employee.isActive)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.errorContainer,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Salary Due',
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: theme.colorScheme.error,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Text(
                                  '${employee.department} • ₹${employee.salary.toStringAsFixed(0)}/month',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (employee.isActive && !employee.isCurrentMonthPaid)
                                      FilledButton.tonal(
                                        onPressed: () => _paySalary(employee),
                                        child: const Text('Pay'),
                                      )
                                    else if (employee.isCurrentMonthPaid)
                                      Icon(Icons.check_circle, color: Colors.green),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                                      onPressed: () => _deleteEmployee(employee),
                                    ),
                                  ],
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Phone: ${employee.phone ?? "-"}'),
                                                  Text('Email: ${employee.email ?? "-"}'),
                                                  Text('Joined: ${DateFormat('dd/MM/yyyy').format(employee.joiningDate)}'),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Total Paid: ₹${employee.totalPaid.toStringAsFixed(2)}'),
                                                  Text('Payments: ${employee.paymentHistory.length}'),
                                                  if (employee.lastPaymentDate != null)
                                                    Text('Last Paid: ${DateFormat('dd/MM/yyyy').format(employee.lastPaymentDate!)}'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (employee.paymentHistory.isNotEmpty) ...[
                                          const SizedBox(height: 16),
                                          Text('Payment History', style: theme.textTheme.titleSmall),
                                          const SizedBox(height: 8),
                                          ...employee.paymentHistory.reversed.take(6).map((payment) => ListTile(
                                            dense: true,
                                            leading: const Icon(Icons.payment, size: 20),
                                            title: Text(payment.month),
                                            subtitle: payment.notes != null ? Text(payment.notes!) : null,
                                            trailing: Text(
                                              '₹${payment.amount.toStringAsFixed(2)}',
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          )),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
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

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
