import '../entities/employee.dart';

abstract class EmployeeRepository {
  Stream<List<Employee>> watchAll(String userId);
  Future<List<Employee>> getAll(String userId);
  Future<Employee?> getById(String userId, String employeeId);
  Future<Employee> create(String userId, Employee employee);
  Future<Employee> update(String userId, Employee employee);
  Future<void> delete(String userId, String employeeId);
  Future<List<Employee>> search(String userId, String query);
}
