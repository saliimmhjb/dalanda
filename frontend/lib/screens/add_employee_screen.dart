import 'dart:io';
import 'package:dalanda/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../components/common.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});
  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  List<dynamic> _departments = [];
  String? _selectedDeptId;
  String _selectedGrade = "Junior";
  bool _isLoading = false;
  File? _image;

  @override
  void initState() {
    super.initState();
    _fetchDepts();
  }

  void _fetchDepts() async {
    var depts = await ApiService.getDepartments();
    setState(() {
      _departments = depts;
      if (depts.isNotEmpty) _selectedDeptId = depts[0]['id'].toString();
    });
  }

  void _saveEmployee() async {
    if (_nameController.text.isEmpty || _selectedDeptId == null) return;
    setState(() => _isLoading = true);

    Map<String, String> data = {
      "name": _nameController.text,
      "email": _emailController.text,
      "position": _roleController.text,
      "department": _selectedDeptId!,
      "grade": _selectedGrade,
      "phone": _phoneController.text,
    };

    bool success = await ApiService.addEmployeeWithImage(data, _image);
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Employee Added & User Account Created!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: const Text('Add New Employee')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (picked != null) setState(() => _image = File(picked.path));
                },
                child: CircleAvatar(radius: 50, backgroundColor: Colors.white10, backgroundImage: _image != null ? FileImage(_image!) : null, child: _image == null ? const Icon(Icons.camera_alt) : null),
              ),
              const SizedBox(height: 20),
              CustomTextField(hintText: 'Full Name', prefixIcon: Icons.person, controller: _nameController),
              CustomTextField(hintText: 'Email', prefixIcon: Icons.email, controller: _emailController),
              CustomTextField(hintText: 'Job Title', prefixIcon: Icons.work, controller: _roleController),

              // Department Dropdown
              _buildDropdown("Department", _selectedDeptId, _departments.map((d) => DropdownMenuItem(value: d['id'].toString(), child: Text(d['name']))).toList(), (val) => setState(() => _selectedDeptId = val)),

              // Grade Dropdown
              _buildDropdown("Grade", _selectedGrade, ["Junior", "Senior", "Expert"].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(), (val) => setState(() => _selectedGrade = val!)),

              CustomTextField(hintText: 'Phone', prefixIcon: Icons.phone, controller: _phoneController),
              const SizedBox(height: 30),
              _isLoading ? const CircularProgressIndicator() : GradientButton(text: 'Save Employee', onPressed: _saveEmployee),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<DropdownMenuItem<String>> items, Function(String?) onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: const Color(0xFF1E1E2A), borderRadius: BorderRadius.circular(16)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, items: items, onChanged: onChanged, dropdownColor: const Color(0xFF1E1E2A), isExpanded: true, style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
    );
  }
}