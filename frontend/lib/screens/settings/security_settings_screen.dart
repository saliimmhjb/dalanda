import 'package:dalanda/components/common.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Security',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Account Protection",
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 15),
              GlassTile(
                icon: Icons.lock_outline,
                title: "Change Password",
                subtitle: "Last changed 3 months ago",
                onTap: () {},
              ),
              GlassTile(
                icon: Icons.fingerprint,
                title: "Biometric Login",
                subtitle: "Face ID or Fingerprint",
                trailing: Switch(
                  value: true,
                  activeColor: const Color(0xFFB84CFF),
                  onChanged: (v) {},
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Devices",
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 15),
              GlassTile(
                icon: Icons.phone_android,
                title: "iPhone 13 Pro",
                subtitle: "Active now • Tunis, TN",
                trailing: const Text(
                  "Current",
                  style: TextStyle(color: Colors.green, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}