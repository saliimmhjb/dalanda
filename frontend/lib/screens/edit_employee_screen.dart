import 'dart:io';
import 'package:dalanda/models/employee.dart';
import 'package:dalanda/services/api_service.dart';
import 'package:flutter/material.dart';
import '../components/common.dart';

class EditEmployeeScreen extends StatefulWidget {
  final Employee employee;

  const EditEmployeeScreen({
    super.key,
    required this.employee,
  });

  @override
  State<EditEmployeeScreen> createState() =>
      _EditEmployeeScreenState();
}

class _EditEmployeeScreenState
    extends State<EditEmployeeScreen> {
  late TextEditingController _nameController;
  late TextEditingController _roleController;
  late TextEditingController _deptController;
  late TextEditingController _phoneController;

  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.employee.name);
    _roleController =
        TextEditingController(text: widget.employee.role);
    _deptController =
        TextEditingController(text: widget.employee.department);
    _phoneController =
        TextEditingController(text: widget.employee.phone);
  }

  void _updateProfile() async {
    setState(() => _isLoading = true);

    Map<String, dynamic> data = {
      "name": _nameController.text,
      "position": _roleController.text,
      "department": _deptController.text,
      "phone": _phoneController.text,
      "email": widget.employee.email,
    };

    bool success = await ApiService.updateEmployee(
      widget.employee.id!,
      data,
      _imageFile,
    );

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile Updated successfully!"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Update failed. Check your data."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text("Edit Profile"),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              CustomTextField(
                hintText: "Name",
                prefixIcon: Icons.person,
                controller: _nameController,
              ),
              CustomTextField(
                hintText: "Role",
                prefixIcon: Icons.work,
                controller: _roleController,
              ),
              CustomTextField(
                hintText: "Department",
                prefixIcon: Icons.business,
                controller: _deptController,
              ),
              CustomTextField(
                hintText: "Phone",
                prefixIcon: Icons.phone,
                controller: _phoneController,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : GradientButton(
                text: "Save Changes",
                onPressed: _updateProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}