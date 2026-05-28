import 'package:dalanda/models/employee.dart';
import 'package:dalanda/screens/edit_employee_screen.dart';
import 'package:dalanda/screens/settings/help_support_screen.dart';
import 'package:dalanda/screens/settings/notifications_settings_screen.dart';
import 'package:dalanda/screens/settings/security_settings_screen.dart';
import 'package:dalanda/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/common.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isSyncing = false;

  void _editMyProfile() async {
    setState(() => _isSyncing = true);

    Employee? myProfile = await ApiService.getMyProfile();

    setState(() => _isSyncing = false);

    if (myProfile != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditEmployeeScreen(employee: myProfile),
        ),
      );

      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Your profile has been updated!")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not find your employee record.")),
      );
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
            Text('Settings',
                style: GoogleFonts.poppins(
                    fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            GlassTile(
              icon: Icons.person_outline,
              title: 'Account Settings',
              subtitle: _isSyncing ? 'Syncing...' : 'Edit your personal info',
              trailing: _isSyncing
                  ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
                  : null,
              onTap: _isSyncing ? null : _editMyProfile,
            ),
            GlassTile(
              icon: Icons.notifications_none_outlined,
              title: 'Notifications',
              subtitle: 'Meeting alerts, Leave alerts',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NotificationsSettingsScreen())),
            ),
            GlassTile(
              icon: Icons.security_outlined,
              title: 'Security',
              subtitle: 'Change password, 2FA',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SecuritySettingsScreen())),
            ),
            GlassTile(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'FAQ, Contact us',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
            ),
            const Spacer(),
            GlassTile(
              icon: Icons.logout,
              title: 'Logout',
              iconColor: Colors.redAccent,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false);
                }
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}