import 'package:dalanda/screens/main_navigation.dart';
import 'package:dalanda/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/common.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const LogoWidget(),
            const SizedBox(height: 60),
            Text('Welcome Back!', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            CustomTextField(
              hintText: 'Enter your email',
              prefixIcon: Icons.email_outlined,
              controller: emailController,
            ),
            CustomTextField(
              hintText: 'Enter your password',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              controller: passwordController,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text('Forgot password?', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13)),
              ),
            ),
            GradientButton(
              text: 'Login',
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );

                bool success = await ApiService.login(
                  emailController.text.trim().toLowerCase(),
                  passwordController.text.trim(),
                );

                if (mounted) Navigator.pop(context);

                if (success) {
                  if (mounted) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigation()));
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Login Failed! Check credentials.")),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 40),
            Text("Official Corporate Access Only", style: GoogleFonts.poppins(color: Colors.white24, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}