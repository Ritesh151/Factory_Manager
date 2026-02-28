import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/employee_model.dart';

/// Form for adding an employee
class EmployeeForm extends StatefulWidget {
  const EmployeeForm({super.key});

  @override
  State<EmployeeForm> createState() => _EmployeeFormState();
}

class _EmployeeFormState extends State<EmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _salaryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  
  String _selectedDepartment = EmployeeModel.departments.first;
  DateTime _joiningDate = DateTime.now();

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _joiningDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _joiningDate = picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop({
      'name': _nameController.text.trim(),
      'salary': double.tryParse(_salaryController.text) ?? 0.0,
      'department': _selectedDepartment,
      'joiningDate': _joiningDate,
      'phone': _phoneController.text.trim().isEmpty 
          ? null 
          : _phoneController.text.trim(),
      'email': _emailController.text.trim().isEmpty 
          ? null 
          : _emailController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Employee'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 400, maxWidth: 500),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _salaryController,
                  decoration: const InputDecoration(
                    labelText: 'Monthly Salary (₹) *',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Salary is required';
                    }
                    final salary = double.tryParse(value);
                    if (salary == null || salary <= 0) {
                      return 'Enter valid salary';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedDepartment,
                  decoration: const InputDecoration(
                    labelText: 'Department *',
                    border: OutlineInputBorder(),
                  ),
                  items: EmployeeModel.departments.map((dept) {
                    return DropdownMenuItem(
                      value: dept,
                      child: Text(dept),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedDepartment = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Joining Date *',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(DateFormat('dd/MM/yyyy').format(_joiningDate)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Add Employee'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _salaryController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
