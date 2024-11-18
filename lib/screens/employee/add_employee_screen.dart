import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/emp_model.dart';
import '../../providers/emp_providers.dart';
import '../../widgets/custome_button.dart';
import '../../widgets/custome_textfield.dart';
import '../home_screen.dart';

class CreateEmployeeScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const CreateEmployeeScreen({Key? key}) : super(key: key);

  @override
  State<CreateEmployeeScreen> createState() => _CreateEmployeeScreenState();
}

class _CreateEmployeeScreenState extends State<CreateEmployeeScreen> {
  final nameController = TextEditingController();
  final departmentController = TextEditingController();
  final salaryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: Text(
                "Create Employee Details",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 9, 35, 113),
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: nameController,
              hintText: 'Enter Name',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: departmentController,
              hintText: 'Enter Department',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: salaryController,
              hintText: 'Enter Salary',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            Center(
              child: CustomButton(
                onPressed: _saveEmployee,
                text: 'Add Employee',
                fontSize: 12,
                width: double.infinity,
                height: 50,
                color: const Color.fromARGB(255, 9, 35, 113),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveEmployee() async {
    final name = nameController.text;
    final department = departmentController.text;
    final salary = double.tryParse(salaryController.text) ?? 0.0;

    if (name.isEmpty || department.isEmpty || salary <= 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields correctly')),
      );
      return;
    }

    await Provider.of<EmployeeProvider>(context, listen: false).addEmployee(
      Employee(
        id: DateTime.now().toString(),
        name: name,
        department: department,
        salary: salary,
      ),
    );

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Employee saved successfully!')),
    );

    // ignore: use_build_context_synchronously
    Provider.of<EmployeeProvider>(context, listen: false).fetchEmployees();

    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const EmployeeManagementHome(),
      ),
    );
  }
}
