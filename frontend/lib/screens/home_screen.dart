import 'dart:ui';
import 'package:dalanda/models/employee.dart';
import 'package:dalanda/screens/add_employee_screen.dart';
import 'package:dalanda/screens/create_leave_screen.dart';
import 'package:dalanda/screens/settings_screen.dart';
import 'package:dalanda/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/common.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = "User";
  String _userRole = "Employee";
  bool _isLoading = true;
  String? _userImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('username') ?? "User";
      _userRole = prefs.getString('role') ?? "Employee";
      _userImage = prefs.getString('user_image');
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String firstName = _userName.split(' ').first;

    if (_isLoading) {
      return const BackgroundWrapper(
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFB84CFF)),
        ),
      );
    }

    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // --- Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Hello, Hassan',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text('👋', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                      Text(
                        _userRole == 'HR' ? 'HR Manager' : 'Employee',
                        style: GoogleFonts.poppins(color: Colors.white54),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                    child: Badge(
                      label: const Text('1'),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: const Color(0xFFB84CFF),
                        backgroundImage:
                        (_userImage != null && _userImage!.isNotEmpty)
                            ? NetworkImage(_userImage!)
                            : const AssetImage('assets/default_profile.png')
                        as ImageProvider,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // --- AI Assistant Card ---
              GlassCard(
                height: 240,
                borderColor: const Color(0xFFB84CFF).withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(radius: 40,backgroundImage: AssetImage('assets/logo.png'),),
                      Text(
                        'Dalanda',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'How can I help you today?',
                        style: GoogleFonts.poppins(color: Colors.white70),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search,
                              color: Colors.white54,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Type a message...',
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.white30,
                                    fontSize: 13,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.mic_none,
                              color: Colors.white54,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // --- Stats Grid ---
              FutureBuilder<List<dynamic>>(
                future: Future.wait([
                  ApiService.getEmployees(),
                  ApiService.getLeaves(),
                  ApiService.getMeetings(),
                  ApiService.getMyProfile(),
                ]),
                builder: (context, snapshot) {
                  bool hasData = snapshot.hasData;
                  Employee? me = hasData ? snapshot.data![3] : null;

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.4,
                    children: _userRole == 'HR'
                        ? [
                      StatCard(
                        title: 'Total Employees',
                        count: hasData ? snapshot.data![0].length.toString() : '...',
                        icon: Icons.people,
                        accentColor: const Color(0xFFB84CFF),
                      ),
                      StatCard(
                        title: 'All Leaves',
                        count: hasData ? snapshot.data![1].length.toString() : '...',
                        icon: Icons.calendar_today,
                        accentColor: Colors.amber,
                      ),
                      StatCard(
                        title: 'Meetings',
                        count: hasData ? snapshot.data![2].length.toString() : '...',
                        icon: Icons.event,
                        accentColor: Colors.blueAccent,
                      ),
                      const StatCard(
                        title: 'Positions',
                        count: '12',
                        icon: Icons.work,
                        accentColor: Colors.tealAccent,
                      ),
                    ]
                        : [
                      // VUE EMPLOYÉ : Nouveaux scores de congés
                      StatCard(
                          title: 'Annual Leave',
                          count: me != null ? '${me.annual_leave_balance}d' : '...',
                          icon: Icons.beach_access,
                          accentColor: Colors.orangeAccent
                      ),
                      StatCard(
                          title: 'Sick Leave',
                          count: me != null ? '${me.sick_leave_balance}d' : '...',
                          icon: Icons.medical_services_outlined,
                          accentColor: Colors.redAccent
                      ),
                      StatCard(
                          title: 'My Projects',
                          count: me?.projects ?? '0',
                          icon: Icons.assignment,
                          accentColor: Colors.blueAccent
                      ),
                      StatCard(
                          title: 'Meetings',
                          count: hasData ? snapshot.data![2].length.toString() : '...',
                          icon: Icons.videocam,
                          accentColor: Colors.tealAccent
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              // --- Boutons d'action ---
              Row(
                children: [
                  if (_userRole == 'HR')
                    Expanded(
                      child: _SmallActionButton(
                        icon: Icons.person_add_alt_1_outlined,
                        label: 'Add Employee',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddEmployeeScreen(),
                            ),
                          );
                        },
                      ),
                    ),

                  if (_userRole == 'HR') const SizedBox(width: 10),

                  Expanded(
                    child: _SmallActionButton(
                      icon: _userRole == 'HR'
                          ? Icons.video_call_outlined
                          : Icons.question_answer_outlined,
                      label: _userRole == 'HR'
                          ? 'Schedule Meeting'
                          : 'Request Meeting',
                      onTap: () {
                        showScheduleMeetingSheet(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              _LargeActionButton(
                icon: Icons.post_add_outlined,
                label: 'Create Leave Request',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateLeaveScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SmallActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2A),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xFFB84CFF)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.poppins(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LargeActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LargeActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2A),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.amber),
            const SizedBox(width: 12),
            Text(label, style: GoogleFonts.poppins()),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}