import 'package:dalanda/models/meeting.dart';
import 'package:dalanda/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/common.dart';

class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({super.key});

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  void _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('role');
    });
  }

  void _handleStatusUpdate(int id, String status) async {
    bool success = await ApiService.updateMeetingStatus(id, status);
    if (success) {
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Meeting $status")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: FutureBuilder<List<Meeting>>(
          future: ApiService.getMeetings(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFB84CFF)));
            }

            if (snapshot.hasError) {
              return const Center(child: Text("Error loading meetings"));
            }

            final meetings = snapshot.data ?? [];
            final count = meetings.length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text('Meetings',
                    style: GoogleFonts.poppins(
                        fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(
                  'You have $count meeting records',
                  style: GoogleFonts.poppins(color: Colors.white54),
                ),
                const SizedBox(height: 25),
                Expanded(
                  child: count == 0
                      ? const Center(child: Text("No meetings scheduled"))
                      : ListView.builder(
                    itemCount: count,
                    itemBuilder: (context, index) {
                      final m = meetings[index];

                      bool showHRButtons =
                          _userRole == 'HR' && m.status == 'Pending';

                      return _MeetingItem(
                        time: m.time,
                        title: m.title,
                        type: m.type,
                        color: m.color,
                        status: m.status,
                        trailing: showHRButtons
                            ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              onPressed: () => _handleStatusUpdate(m.id!, 'Approved'),
                            ),
                            const SizedBox(width: 4), // control spacing manually
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () => _handleStatusUpdate(m.id!, 'Rejected'),
                            ),
                          ],
                        )
                            : null,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 100),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MeetingItem extends StatelessWidget {
  final String time, title, type, status;
  final Color color;
  final Widget? trailing;

  const _MeetingItem({
    required this.time,
    required this.title,
    required this.type,
    required this.color,
    required this.status,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.white38;
    if (status == 'Approved') statusColor = Colors.greenAccent;
    if (status == 'Rejected') statusColor = Colors.redAccent;
    if (status == 'Pending') statusColor = Colors.amber;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      type,
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "• $status",
                      style: GoogleFonts.poppins(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          trailing ?? const Icon(Icons.videocam_outlined, color: Colors.white24),
        ],
      ),
    );
  }
}