import 'package:dalanda/components/common.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool pushNotify = true;
  bool emailNotify = false;
  bool meetingAlerts = true;
  bool leaveAlerts = true;

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Notifications',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildSwitchTile(
                "Push Notifications",
                "Receive alerts on your device",
                pushNotify,
                    (val) => setState(() => pushNotify = val),
              ),
              _buildSwitchTile(
                "Email Notifications",
                "Receive daily summaries via email",
                emailNotify,
                    (val) => setState(() => emailNotify = val),
              ),
              _buildSwitchTile(
                "Meeting Alerts",
                "Reminders 15 mins before meetings",
                meetingAlerts,
                    (val) => setState(() => meetingAlerts = val),
              ),
              _buildSwitchTile(
                "Leave Updates",
                "Status changes on leave requests",
                leaveAlerts,
                    (val) => setState(() => leaveAlerts = val),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String sub, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          sub,
          style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
        ),
        value: value,
        activeColor: const Color(0xFFB84CFF),
        onChanged: onChanged,
      ),
    );
  }
}