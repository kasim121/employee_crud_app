import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/emp_model.dart';

class EmployeeProvider with ChangeNotifier {
  List<Employee> _employees = [];
  bool _isLoading = false;
  String? _error;

  List<Employee> get employees => _employees;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchEmployees() async {
    if (_employees.isNotEmpty || _isLoading) {
      return;
    }

    _setLoading(true);

    try {
      var snapshot =
          await FirebaseFirestore.instance.collection('employees').get();
      _employees =
          snapshot.docs.map((doc) => Employee.fromFirestore(doc)).toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch employees: $e';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;

      Future.delayed(Duration.zero, () {
        notifyListeners();
      });
    }
  }

  Future<void> addEmployee(Employee employee) async {
    try {
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('employees')
          .add(employee.toMap());
      employee.id = docRef.id;
      _employees.add(employee);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add employee: $e';
      notifyListeners();
    }
  }

  Future<void> updateEmployee(Employee updatedEmployee) async {
    try {
      await FirebaseFirestore.instance
          .collection('employees')
          .doc(updatedEmployee.id)
          .update(updatedEmployee.toMap());

      _employees = _employees.map((emp) {
        return emp.id == updatedEmployee.id ? updatedEmployee : emp;
      }).toList();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update employee: $e';
      notifyListeners();
    }
  }

  Future<void> deleteEmployee(String employeeId) async {
    try {
      await FirebaseFirestore.instance
          .collection('employees')
          .doc(employeeId)
          .delete();

      _employees.removeWhere((emp) => emp.id == employeeId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete employee: $e';
      notifyListeners();
    }
  }

  Future<void> deleteMultipleEmployees(List<String> employeeIds) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (String id in employeeIds) {
        DocumentReference docRef =
            FirebaseFirestore.instance.collection('employees').doc(id);
        batch.delete(docRef);
      }
      await batch.commit();

      _employees.removeWhere((emp) => employeeIds.contains(emp.id));
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete multiple employees: $e';
      notifyListeners();
    }
  }

  Employee? getEmployeeById(String employeeId) {
    try {
      return _employees.firstWhere((employee) => employee.id == employeeId);
    } catch (e) {
      return null;
    }
  }
}
