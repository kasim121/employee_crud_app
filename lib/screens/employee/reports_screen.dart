import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/emp_providers.dart';
import '../../widgets/custome_button.dart';
import '../../models/emp_model.dart'; // Assuming Employee model exists
import 'package:pdf/widgets.dart' as pw; // Pdf package
import 'package:printing/printing.dart'; // Printing package

class ViewSalaryScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const ViewSalaryScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ViewSalaryScreenState createState() => _ViewSalaryScreenState();
}

class _ViewSalaryScreenState extends State<ViewSalaryScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the employees when the screen is loaded
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
                      // Name and Department Row
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              employee.department,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Salary Row
                      Row(
                        children: [
                          const Text(
                            'Salary:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '₹${employee.salary.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Buttons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CustomButton(
                              fontSize: 12,
                              text: 'PDF',
                              height: 40.0,
                              onPressed: () {
                                _generatePDF(employee);
                              },
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CustomButton(
                              fontSize: 12,
                              text: 'Update',
                              height: 40.0,
                              onPressed: () async {
                                _showEmployeeDialog(context,
                                    employee: employee);
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CustomButton(
                              fontSize: 12,
                              text: 'Delete',
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

  Future<void> _generatePDF(Employee employee) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text("Employee Salary Details",
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text("Employee Name: ${employee.name}"),
              pw.Text("Department: ${employee.department}"),
              pw.Text("Salary: ₹${employee.salary.toStringAsFixed(2)}"),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  void _showEmployeeDialog(BuildContext context, {Employee? employee}) {
    final salaryController =
        TextEditingController(text: employee?.salary.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Salary'),
          content: SingleChildScrollView(
            child: Column(
              children: [
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
                final salary = double.tryParse(salaryController.text) ?? 0.0;

                if (employee != null) {
                  await Provider.of<EmployeeProvider>(context, listen: false)
                      .updateEmployee(Employee(
                    id: employee.id,
                    name: employee.name,
                    department: employee.department,
                    salary: salary,
                  ));

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Salary updated successfully!')),
                  );

                  // Fetch updated employees list
                  await Provider.of<EmployeeProvider>(context, listen: false)
                      .fetchEmployees();
                  Navigator.pop(context);
                }
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
            onPressed: () async {
              await employeeProvider.deleteEmployee(employeeId);
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
              // Optionally show a confirmation snackbar
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Employee deleted successfully!')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
