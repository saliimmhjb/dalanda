import 'package:dalanda/models/employee.dart';
import 'package:dalanda/screens/edit_employee_screen.dart';
import 'package:dalanda/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/common.dart';

class EmployeeDetailsScreen extends StatefulWidget {
  final Employee employee;

  const EmployeeDetailsScreen({
    super.key,
    required this.employee,
  });

  @override
  State<EmployeeDetailsScreen> createState() =>
      _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState
    extends State<EmployeeDetailsScreen> {
  String? userRole;
  late Employee currentEmployee;
  bool _wasEdited = false;

  @override
  void initState() {
    super.initState();
    currentEmployee = widget.employee;
    _checkRole();
  }

  void _checkRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('role');
    });
  }

  Future<void> _refreshEmployeeData() async {
    final updated =
    await ApiService.getEmployeeById(currentEmployee.id!);
    if (updated != null) {
      setState(() {
        currentEmployee = updated;
        _wasEdited = true;
      });
    }
  }

  ImageProvider getImageProvider(String url) {
    if (url.startsWith('http')) return NetworkImage(url);
    if (url.startsWith('/media/')) {
      return NetworkImage("http://10.0.2.2:8000$url");
    }
    return const AssetImage('assets/default_profile.png');
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context, _wasEdited);
            },
          ),
          title: Text(
            'Employee Profile',
            style: GoogleFonts.poppins(fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding:
          const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor:
                  const Color(0xFFB84CFF),
                  child: CircleAvatar(
                    radius: 56,
                    backgroundImage:
                    getImageProvider(
                      currentEmployee.imageUrl,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                currentEmployee.name,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                currentEmployee.role,
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceAround,
                children: [
                  _infoStat(
                    currentEmployee.performance,
                    'Performance',
                  ),
                  _infoStat(
                    currentEmployee.projects,
                    'Projects',
                  ),
                  _infoStat(
                    currentEmployee.tenure,
                    'Tenure',
                  ),
                ],
              ),
              const SizedBox(height: 30),
              GlassTile(
                icon: Icons.email_outlined,
                title: currentEmployee.email,
                subtitle: 'Work Email',
              ),
              GlassTile(
                icon: Icons.phone_outlined,
                title: currentEmployee.phone,
                subtitle: 'Mobile',
              ),
              GlassTile(
                icon: Icons.business_outlined,
                title: currentEmployee.department,
                subtitle: 'Department',
              ),
              const SizedBox(height: 20),
              if (userRole == 'HR')
                GradientButton(
                  text: 'Edit Profile',
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EditEmployeeScreen(
                              employee: currentEmployee,
                            ),
                      ),
                    );

                    if (result == true) {
                      _refreshEmployeeData();
                    }
                  },
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoStat(String val, String label) {
    return Column(
      children: [
        Text(
          val,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFB84CFF),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white30,
          ),
        ),
      ],
    );
  }
}