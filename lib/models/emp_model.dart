import 'package:cloud_firestore/cloud_firestore.dart';

class Employee {
  String? id;
  String name;
  String department;
  double salary;

  Employee({
    this.id,
    required this.name,
    required this.department,
    required this.salary,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'department': department,
      'salary': salary,
    };
  }

  factory Employee.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;

    return Employee(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      department: data['department'] ?? 'Unknown',
      salary: (data['salary'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
