import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/modern_theme.dart';
import '../../providers/payroll_providers.dart';
import '../../models/employee_model.dart';

class ModernPayrollPage extends ConsumerStatefulWidget {
  const ModernPayrollPage({super.key});

  @override
  ConsumerState<ModernPayrollPage> createState() => _ModernPayrollPageState();
}

class _ModernPayrollPageState extends ConsumerState<ModernPayrollPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final payrollAsync = ref.watch(employeesStreamProvider);
    
    return Padding(
      padding: const EdgeInsets.all(ModernTheme.lg),
      child: Column(
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  padding:
                      const EdgeInsets.symmetric(horizontal: ModernTheme.md),
                  decoration: BoxDecoration(
                    color: ModernTheme.surface,
                    borderRadius:
                        BorderRadius.circular(ModernTheme.radiusMedium),
                    border: Border.all(color: ModernTheme.border),
                    boxShadow: ModernTheme.cardShadow,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded,
                          size: 18, color: ModernTheme.textMuted),
                      const SizedBox(width: ModernTheme.sm),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search employees...',
                            hintStyle: TextStyle(
                                color: ModernTheme.textMuted, fontSize: 14),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.toLowerCase();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: ModernTheme.md),
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddEmployeeDialog(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Employee'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ModernTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: ModernTheme.lg),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(ModernTheme.radiusMedium),
                    ),
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: ModernTheme.lg),

          // ── Content Area ─────────────────────────────────────────────────
          Expanded(
            child: payrollAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading payroll',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              data: (payrollRecords) {
                final filteredRecords = payrollRecords.where((record) {
                  return record.name.toLowerCase().contains(_searchQuery) ||
                         record.department.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredRecords.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline_rounded, size: 64, color: ModernTheme.textMuted),
                        SizedBox(height: 16),
                        Text(
                          'No Payroll Records Yet',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: ModernTheme.textMuted),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add employees and manage their salary, attendance and payroll.',
                          style: TextStyle(color: ModernTheme.textMuted),
                        ),
                      ],
                    ),
                  );
                }

                return _buildPayrollList(filteredRecords);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayrollList(List<EmployeeModel> records) {
    return Container(
      decoration: BoxDecoration(
        color: ModernTheme.surface,
        borderRadius: BorderRadius.circular(ModernTheme.radiusLarge),
        border: Border.all(color: ModernTheme.border),
        boxShadow: ModernTheme.cardShadow,
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(ModernTheme.md),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          return _buildPayrollCard(record);
        },
      ),
    );
  }

  Widget _buildPayrollCard(EmployeeModel record) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final dateFormat = DateFormat('dd MMM yyyy');
    
    return Container(
      margin: const EdgeInsets.only(bottom: ModernTheme.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ModernTheme.radiusMedium),
        border: Border.all(color: ModernTheme.border),
        boxShadow: ModernTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(ModernTheme.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ModernTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        record.department,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: record.isActive ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    record.isActive ? 'ACTIVE' : 'INACTIVE',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Details Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currencyFormat.format(record.salary),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ModernTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${record.id}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: ModernTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Salary: ${currencyFormat.format(record.salary)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: ModernTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Joined: ${dateFormat.format(record.joiningDate)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: ModernTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Actions Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _viewPayrollDetails(record),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _editPayroll(record),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _deletePayroll(record),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showAddEmployeeDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Employee dialog coming soon!')),
    );
  }

  void _viewPayrollDetails(EmployeeModel record) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing employee: ${record.name}')),
    );
  }

  void _editPayroll(EmployeeModel record) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing employee: ${record.name}')),
    );
  }

  void _deletePayroll(EmployeeModel record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete employee ${record.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(payrollServiceProvider).deleteEmployee(record.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Employee deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting employee: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
