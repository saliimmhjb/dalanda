import 'package:dalanda/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/common.dart';

class CreateLeaveScreen extends StatefulWidget {
  const CreateLeaveScreen({super.key});

  @override
  State<CreateLeaveScreen> createState() => _CreateLeaveScreenState();
}

class _CreateLeaveScreenState extends State<CreateLeaveScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  String _leaveType = 'Annual Leave';
  bool _isLoading = false;
  String? _userRole;
  String? _currentUserName;
  List<dynamic> _employees = [];
  int? _selectedEmployeeId;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  void _getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('role');
      _currentUserName = prefs.getString('username');

      if (_userRole == 'Employee') {
        _nameController.text = _currentUserName ?? "";
      }
    });

    if (_userRole == 'HR') {
      await _loadEmployeeList();
    }
  }

  Future<void> _loadEmployeeList() async {
    final employees = await ApiService.getEmployees();
    setState(() {
      _employees = employees;
      if (_employees.isNotEmpty) {
        _selectedEmployeeId = _employees.first['id'] as int?;
        _nameController.text = _employees.first['name'] ?? '';
      }
    });
  }

  int _computeDuration(String start, String end) {
    try {
      final parsedStart = _parseDateString(start);
      final parsedEnd = _parseDateString(end);
      if (parsedStart != null && parsedEnd != null) {
        final diff = parsedEnd.difference(parsedStart).inDays + 1;
        return diff > 0 ? diff : 1;
      }
    } catch (_) {}
    return 1;
  }

  DateTime? _parseDateString(String value) {
    final trimmed = value.trim();
    final parts = trimmed.split(RegExp(r'[\/\-]'));
    if (parts.length == 3) {
      try {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        var year = int.parse(parts[2]);
        if (year < 100) year += 2000;
        return DateTime(year, month, day);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _reasonController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _submitLeaveRequest() async {
    if (_nameController.text.isEmpty ||
        _startDateController.text.isEmpty ||
        _endDateController.text.isEmpty ||
        _reasonController.text.isEmpty ||
        (_userRole == 'HR' && _selectedEmployeeId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    int duration = _computeDuration(
      _startDateController.text,
      _endDateController.text,
    );

    String icon = _leaveType == 'Sick Leave' ? 'pause' : 'beach';

    Map<String, dynamic> leaveData = {
      "employee_name": _nameController.text,
      "type": _leaveType,
      "reason": _reasonController.text.trim(),
      "start_date": _startDateController.text.trim(),
      "end_date": _endDateController.text.trim(),
      "duration": duration,
      "status": "Pending",
      "icon_data": icon,
    };

    if (_userRole == 'HR' && _selectedEmployeeId != null) {
      leaveData['employee'] = _selectedEmployeeId;
    }

    bool success = await ApiService.addLeave(leaveData);

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leave Request Submitted! 🚀'),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error connecting to Django'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      safeBottom: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'New Leave Request',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Requesting for:',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              if (_userRole == 'HR')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      hint: const Text(
                        'Select employee',
                        style: TextStyle(color: Colors.white70),
                      ),
                      value: _selectedEmployeeId,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1E1E2A),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                      ),
                      items: _employees.map<DropdownMenuItem<int>>((employee) {
                        final id = employee['id'] as int?;
                        final name = employee['name']?.toString() ?? '';
                        return DropdownMenuItem<int>(
                          value: id,
                          child: Text(name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedEmployeeId = val;
                          final selected = _employees.firstWhere(
                            (employee) => employee['id'] == val,
                            orElse: () => null,
                          );
                          _nameController.text = selected != null ? selected['name'] ?? '' : '';
                        });
                      },
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person,
                        color: Color(0xFFB84CFF),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        _currentUserName ?? "Loading...",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 25),
              Text(
                'Type of Leave',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _leaveType,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1E1E2A),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                    ),
                    items: <String>[
                      'Annual Leave',
                      'Sick Leave',
                      'Personal Leave',
                      'Maternity'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => _leaveType = val!),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Text(
                'Reason',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              CustomTextField(
                hintText: 'Briefly explain why...',
                prefixIcon: Icons.notes,
                controller: _reasonController,
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Date',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        CustomTextField(
                          hintText: 'DD/MM/YY',
                          prefixIcon: Icons.calendar_today,
                          controller: _startDateController,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          'End Date',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        CustomTextField(
                          hintText: 'DD/MM/YY',
                          prefixIcon: Icons.calendar_today,
                          controller: _endDateController,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFB84CFF),
                ),
              )
                  : GradientButton(
                text: 'Submit Request',
                onPressed: _submitLeaveRequest,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}