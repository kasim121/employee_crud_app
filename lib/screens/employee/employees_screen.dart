import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/emp_providers.dart';
import '../../widgets/custome_button.dart';
import '../../models/emp_model.dart';

class ViewEmployeesScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const ViewEmployeesScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ViewEmployeesScreenState createState() => _ViewEmployeesScreenState();
}

class _ViewEmployeesScreenState extends State<ViewEmployeesScreen> {
  @override
  void initState() {
    super.initState();

    Provider.of<EmployeeProvider>(context, listen: false).fetchEmployees();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Consumer<EmployeeProvider>(
        builder: (context, employeeProvider, child) {
          if (employeeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (employeeProvider.error != null) {
            return Center(child: Text(employeeProvider.error!));
          }
          if (employeeProvider.employees.isEmpty) {
            return const Center(child: Text('No employees found.'));
          }
          return ListView.builder(
            itemCount: employeeProvider.employees.length,
            itemBuilder: (context, index) {
              final employee = employeeProvider.employees[index];
              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: 8,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Employee Name and Salary in a Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              employee.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '₹${employee.salary.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Department Information
                      Text(
                        'Department: ${employee.department}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.grey, height: 1), // Separator
                      const SizedBox(height: 16),
                      // Buttons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Update',
                              fontSize: 14,
                              height: 40.0,
                              onPressed: () async {
                                _showEmployeeDialog(context,
                                    employee: employee);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              text: 'Delete',
                              fontSize: 14,
                              height: 40.0,
                              onPressed: () {
                                _confirmDelete(context, employeeProvider,
                                    employee.id.toString());
                              },
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEmployeeDialog(BuildContext context, {Employee? employee}) {
    final nameController = TextEditingController(text: employee?.name ?? '');
    final departmentController =
        TextEditingController(text: employee?.department ?? '');
    final salaryController =
        TextEditingController(text: employee?.salary.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(employee == null ? 'Add Employee' : 'Update Employee'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: departmentController,
                  decoration: const InputDecoration(labelText: 'Department'),
                ),
                TextField(
                  controller: salaryController,
                  decoration: const InputDecoration(labelText: 'Salary'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text;
                final department = departmentController.text;
                final salary = double.tryParse(salaryController.text) ?? 0.0;

                if (employee == null) {
                  await Provider.of<EmployeeProvider>(context, listen: false)
                      .addEmployee(Employee(
                    id: DateTime.now().toString(),
                    name: name,
                    department: department,
                    salary: salary,
                  ));
                } else {
                  await Provider.of<EmployeeProvider>(context, listen: false)
                      .updateEmployee(Employee(
                    id: employee.id,
                    name: name,
                    department: department,
                    salary: salary,
                  ));
                }

                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Employee saved successfully!')),
                );

                // ignore: use_build_context_synchronously
                Provider.of<EmployeeProvider>(context, listen: false)
                    .fetchEmployees();
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, EmployeeProvider employeeProvider,
      String employeeId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: const Text('Are you sure you want to delete this employee?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              employeeProvider.deleteEmployee(employeeId);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
