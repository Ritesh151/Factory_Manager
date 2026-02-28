import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../core/services/firebase_service.dart';
import '../models/employee_model.dart';

/// Service for managing employees and payroll
class PayrollService {
  static final PayrollService _instance = PayrollService._internal();
  
  factory PayrollService() => _instance;
  PayrollService._internal();

  FirebaseFirestore? _firestore;

  /// Initialize with FirebaseService
  void initialize(FirebaseService firebaseService) {
    _firestore = firebaseService.firestore;
  }

  /// Get employees collection reference
  CollectionReference<Map<String, dynamic>> get _employeesCollection {
    if (_firestore == null) {
      throw StateError('PayrollService not initialized');
    }
    return _firestore!.collection('employees');
  }

  /// Stream of all employees
  Stream<List<EmployeeModel>> streamEmployees() {
    try {
      return _employeesCollection
          .orderBy('name')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return EmployeeModel.fromMap(doc.data(), doc.id);
        }).toList();
      });
    } catch (e) {
      debugPrint('PayrollService: Error streaming employees: $e');
      return Stream.error(e);
    }
  }

  /// Stream of active employees only
  Stream<List<EmployeeModel>> streamActiveEmployees() {
    try {
      return _employeesCollection
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return EmployeeModel.fromMap(doc.data(), doc.id);
        }).toList();
      });
    } catch (e) {
      debugPrint('PayrollService: Error streaming active employees: $e');
      return Stream.error(e);
    }
  }

  /// Create a new employee
  Future<EmployeeModel> createEmployee({
    required String name,
    required double salary,
    required String department,
    required DateTime joiningDate,
    String? phone,
    String? email,
  }) async {
    try {
      if (name.trim().isEmpty) {
        throw ArgumentError('Name is required');
      }
      if (salary <= 0) {
        throw ArgumentError('Salary must be greater than 0');
      }

      final now = DateTime.now();
      final employee = EmployeeModel(
        id: '',
        name: name.trim(),
        salary: salary,
        department: department,
        joiningDate: joiningDate,
        phone: phone?.trim(),
        email: email?.trim(),
        paymentHistory: [],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final docRef = await _employeesCollection.add(employee.toMap());
      
      debugPrint('PayrollService: Created employee ${employee.name}');
      
      return employee.copyWith(id: docRef.id);
    } catch (e) {
      debugPrint('PayrollService: Failed to create employee: $e');
      rethrow;
    }
  }

  /// Update employee
  Future<void> updateEmployee(String id, {
    String? name,
    double? salary,
    String? department,
    DateTime? joiningDate,
    String? phone,
    String? email,
    bool? isActive,
  }) async {
    try {
      if (id.isEmpty) throw ArgumentError('Employee ID is required');

      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };
      
      if (name != null) updates['name'] = name.trim();
      if (salary != null) updates['salary'] = salary;
      if (department != null) updates['department'] = department;
      if (joiningDate != null) updates['joiningDate'] = Timestamp.fromDate(joiningDate);
      if (phone != null) updates['phone'] = phone.trim();
      if (email != null) updates['email'] = email.trim();
      if (isActive != null) updates['isActive'] = isActive;

      await _employeesCollection.doc(id).update(updates);
      
      debugPrint('PayrollService: Updated employee $id');
    } catch (e) {
      debugPrint('PayrollService: Failed to update employee: $e');
      rethrow;
    }
  }

  /// Pay salary to employee
  Future<void> paySalary(String id, {
    required double amount,
    String? notes,
  }) async {
    try {
      if (id.isEmpty) throw ArgumentError('Employee ID is required');
      if (amount <= 0) throw ArgumentError('Amount must be greater than 0');

      final now = DateTime.now();
      final monthYear = '${now.month}/${now.year}';

      final payment = PaymentHistoryEntry(
        amount: amount,
        date: now,
        month: monthYear,
        notes: notes,
      );

      // Get current employee
      final doc = await _employeesCollection.doc(id).get();
      if (!doc.exists) throw ArgumentError('Employee not found');

      final employee = EmployeeModel.fromMap(doc.data()!, id);
      
      // Check if already paid for this month
      if (employee.isCurrentMonthPaid) {
        throw ArgumentError('Salary already paid for this month');
      }

      // Add payment to history
      final updatedHistory = [...employee.paymentHistory, payment];

      await _employeesCollection.doc(id).update({
        'paymentHistory': updatedHistory.map((e) => e.toMap()).toList(),
        'updatedAt': Timestamp.fromDate(now),
      });

      debugPrint('PayrollService: Paid salary to ${employee.name}');
    } catch (e) {
      debugPrint('PayrollService: Failed to pay salary: $e');
      rethrow;
    }
  }

  /// Get total salary paid for a month
  Future<double> getMonthlyPayrollTotal(int year, int month) async {
    try {
      final monthYear = '$month/$year';
      
      final snapshot = await _employeesCollection.get();
      
      double total = 0.0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final history = (data['paymentHistory'] as List<dynamic>?) ?? [];
        
        for (final payment in history) {
          if (payment['month'] == monthYear) {
            total += (payment['amount'] as num?)?.toDouble() ?? 0.0;
          }
        }
      }

      return total;
    } catch (e) {
      debugPrint('PayrollService: Failed to get monthly payroll: $e');
      return 0.0;
    }
  }

  /// Get salary due for current month
  Future<double> getSalaryDue() async {
    try {
      final snapshot = await _employeesCollection
          .where('isActive', isEqualTo: true)
          .get();

      double totalDue = 0.0;
      final now = DateTime.now();
      final monthYear = '${now.month}/${now.year}';

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final salary = (data['salary'] as num?)?.toDouble() ?? 0.0;
        final history = (data['paymentHistory'] as List<dynamic>?) ?? [];
        
        // Check if paid for current month
        final isPaid = history.any((p) => p['month'] == monthYear);
        
        if (!isPaid) {
          totalDue += salary;
        }
      }

      return totalDue;
    } catch (e) {
      debugPrint('PayrollService: Failed to get salary due: $e');
      return 0.0;
    }
  }

  /// Delete employee
  Future<void> deleteEmployee(String id) async {
    try {
      if (id.isEmpty) throw ArgumentError('Employee ID is required');

      await _employeesCollection.doc(id).delete();
      
      debugPrint('PayrollService: Deleted employee $id');
    } catch (e) {
      debugPrint('PayrollService: Failed to delete employee: $e');
      rethrow;
    }
  }
}
