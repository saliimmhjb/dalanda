import 'package:dalanda/models/leave_request.dart';
import 'package:dalanda/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/common.dart';

class LeaveRequestsScreen extends StatefulWidget {
  const LeaveRequestsScreen({super.key});

  @override
  State<LeaveRequestsScreen> createState() => _LeaveRequestsScreenState();
}

class _LeaveRequestsScreenState extends State<LeaveRequestsScreen> {
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  void _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _userRole = prefs.getString('role'));
  }

  void _updateStatus(int id, String status) async {
    bool success = await ApiService.updateLeaveStatus(id, status);
    if (success) {
      setState(() {}); // Refresh list
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Request $status")));
    }
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
            Text('Leave Requests', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<LeaveRequest>>(
                future: ApiService.getLeaves(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final leaves = snapshot.data!;
                  return ListView.builder(
                    itemCount: leaves.length,
                    itemBuilder: (context, index) {
                      final leave = leaves[index];

                      bool showButtons = _userRole == 'HR' && leave.status == 'Pending';

                      return GlassTile(
                        icon: leave.iconName == 'pause' ? Icons.pause_circle_outline : Icons.beach_access,
                        title: leave.employeeName,
                        subtitle: '${leave.type} - ${leave.duration}',
                        trailing: showButtons
                            ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              onPressed: () => _updateStatus(leave.id!, 'Approved'),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () => _updateStatus(leave.id!, 'Rejected'),
                            ),
                          ],
                        )
                            : Text(leave.status, style: TextStyle(
                            color: leave.status == 'Approved' ? Colors.green : (leave.status == 'Rejected' ? Colors.red : Colors.amber),
                            fontWeight: FontWeight.bold)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}