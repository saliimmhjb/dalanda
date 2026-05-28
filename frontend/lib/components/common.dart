import 'dart:ui';
import 'package:dalanda/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.controller,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: _obscureText,
        style: GoogleFonts.poppins(color: Colors.white),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(widget.prefixIcon, color: Colors.grey, size: 20),
          suffixIcon: widget.isPassword
              ? IconButton(
            icon: Icon(
              _obscureText
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: () => setState(() => _obscureText = !_obscureText),
          )
              : null,
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const GradientButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 58,
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF6A4CFF), Color(0xFFB84CFF)],
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }
}

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(child: Image.asset('assets/logo.png', width: 85)),
        const SizedBox(height: 12),
        Text(
          'Dalanda',
          style: GoogleFonts.poppins(
              fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          'AI-Powered HR Assistant',
          style: GoogleFonts.poppins(
              fontSize: 15, color: Colors.white60, letterSpacing: 0.5),
        ),
      ],
    );
  }
}

class BackgroundWrapper extends StatelessWidget {
  final Widget child;
  final bool safeBottom;

  const BackgroundWrapper({
    super.key,
    required this.child,
    this.safeBottom = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12121B),
      body: SafeArea(
        bottom: safeBottom,
        child: Stack(
          children: [
            Positioned(
              top: -100,
              left: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6A4CFF).withOpacity(0.2),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final double height;
  final Color? borderColor;

  const GlassCard({super.key, required this.child, this.height = 180, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor ?? Colors.white.withOpacity(0.1), width: 1),
        ),
        child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: child),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color accentColor;

  const StatCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accentColor.withOpacity(0.2), const Color(0xFF1E1E2A)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 24),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const Spacer(),
          Text(count,
              style: GoogleFonts.poppins(
                  color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class GlassTile extends StatelessWidget {
  final IconData? icon;
  final String? imageUrl;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color iconColor;

  const GlassTile({
    super.key,
    this.icon,
    this.imageUrl,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor = const Color(0xFFB84CFF),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            if (imageUrl != null)
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: () {
                      if (imageUrl!.startsWith('http')) return NetworkImage(imageUrl!);
                      if (imageUrl!.startsWith('/media/')) return NetworkImage("http://10.0.2.2:8000${imageUrl!}");
                      return const AssetImage("assets/default_profile.png") as ImageProvider;
                    }(),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon ?? Icons.help_outline, color: iconColor, size: 22),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, color: Colors.white)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}

void showScheduleMeetingSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _ScheduleMeetingSheetContent(),
  );
}

class _ScheduleMeetingSheetContent extends StatefulWidget {
  const _ScheduleMeetingSheetContent();

  @override
  State<_ScheduleMeetingSheetContent> createState() =>
      _ScheduleMeetingSheetContentState();
}

class _ScheduleMeetingSheetContentState extends State<_ScheduleMeetingSheetContent> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  List<dynamic> _depts = [];
  String? _targetDeptId; // Null means "Everyone"
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDepts();
  }

  void _loadDepts() async {
    var data = await ApiService.getDepartments();
    setState(() => _depts = data);
  }

  void _handleSchedule() async {
    if (_titleController.text.isEmpty ||
        _typeController.text.isEmpty ||
        _timeController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in title, type, and time')),
        );
      }
      return;
    }
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    String role = prefs.getString('role') ?? 'Employee';
    String username = prefs.getString('username') ?? '';
    String initialStatus = (role == 'HR') ? 'Approved' : 'Pending';

    Map<String, dynamic> data = {
      "title": _titleController.text,
      "type": _typeController.text,
      "time": _timeController.text,
      "color_hex": "#B84CFF",
      "status": initialStatus,
      "requested_by": username,
      "target_department": _targetDeptId,
    };

    bool success = await ApiService.addMeeting(data);
    setState(() => _isLoading = false);
    if (success && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 25, right: 25, top: 25),
      decoration: const BoxDecoration(color: Color(0xFF1E1E2A), borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Schedule Meeting', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          CustomTextField(hintText: 'Title', prefixIcon: Icons.title, controller: _titleController),
          const SizedBox(height: 8),
          CustomTextField(hintText: 'Type (e.g. Sync, All-Hands)', prefixIcon: Icons.label, controller: _typeController),

          // Target Dept Dropdown
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: const Text("Target: Everyone"),
                value: _targetDeptId,
                isExpanded: true,
                dropdownColor: const Color(0xFF1E1E2A),
                items: [
                  const DropdownMenuItem(value: null, child: Text("Target: Everyone")),
                  ..._depts.map((d) => DropdownMenuItem(value: d['id'].toString(), child: Text("Only: ${d['name']}")))
                ],
                onChanged: (val) => setState(() => _targetDeptId = val),
              ),
            ),
          ),

          CustomTextField(hintText: 'Date & Time', prefixIcon: Icons.calendar_today, controller: _timeController),
          const SizedBox(height: 20),
          _isLoading ? const CircularProgressIndicator() : GradientButton(text: 'Schedule', onPressed: _handleSchedule),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}