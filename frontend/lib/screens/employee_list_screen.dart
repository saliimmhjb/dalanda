import 'package:dalanda/models/employee.dart';
import 'package:dalanda/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/common.dart';
import 'employee_details_screen.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  String _myRole = 'Employee';

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  void _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _myRole = prefs.getString('role') ?? 'Employee');
  }
  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Employees',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: FutureBuilder<List<dynamic>>(
                  future: ApiService.getEmployees(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFB84CFF),
                        ),
                      );
                    }

                    if (snapshot.hasError || snapshot.data == null) {
                      return const Center(
                        child: Text(
                          "Failed to load employees. Check your server.",
                        ),
                      );
                    }

                    final employees = snapshot.data!;

                    if (employees.isEmpty) {
                      return const Center(
                        child: Text("No employees found. Add one!"),
                      );
                    }

                    return ListView.builder(
                      itemCount: employees.length,
                      itemBuilder: (context, index) {
                        final empMap = employees[index];
                        final employeeObject = Employee.fromJson(empMap);

                        String subtitle = employeeObject.role;
                        if (_myRole == 'HR') {
                          subtitle = '${employeeObject.department} • ${employeeObject.annual_leave_balance}d / ${employeeObject.sick_leave_balance}d';
                        }

                        return GlassTile(
                          imageUrl: employeeObject.imageUrl,
                          title: employeeObject.name,
                          subtitle: subtitle,
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EmployeeDetailsScreen(
                                  employee: employeeObject,
                                ),
                              ),
                            );

                            if (result == true) {
                              setState(() {});
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}