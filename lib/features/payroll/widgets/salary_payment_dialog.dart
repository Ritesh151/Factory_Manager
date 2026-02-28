import 'package:flutter/material.dart';

/// Dialog for paying salary to employee
class SalaryPaymentDialog extends StatefulWidget {
  final String employeeName;
  final double salary;

  const SalaryPaymentDialog({
    super.key,
    required this.employeeName,
    required this.salary,
  });

  @override
  State<SalaryPaymentDialog> createState() => _SalaryPaymentDialogState();
}

class _SalaryPaymentDialogState extends State<SalaryPaymentDialog> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.salary.toStringAsFixed(0);
  }

  void _save() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    Navigator.of(context).pop({
      'amount': amount,
      'notes': _notesController.text.trim().isEmpty 
          ? null 
          : _notesController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pay Salary'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Employee: ${widget.employeeName}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (₹)',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Additional details...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Confirm Payment'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
