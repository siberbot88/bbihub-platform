import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import 'package:bengkel_online_flutter/core/widgets/custom_alert.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _storage = const FlutterSecureStorage();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool rememberMe = false;
  bool obscureText = true;
  bool _isLoading = false;
  bool _prefillChecked = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Prefill dari route arguments (dipasang dari deep link handler di main.dart)
    if (_prefillChecked) return;
    _prefillChecked = true;
    final args = ModalRoute.of(context)?.settings.arguments as Map<dynamic, dynamic>?;
    final emailArg = (args?['email'] ?? args?['prefillEmail']) as String?;
    if (emailArg != null && emailArg.trim().isNotEmpty) {
      emailController.text = emailArg.trim();
    }
  }

  Future<void> _loadRememberedEmail() async {
    final remembered = await _storage.read(key: 'remember_email');
    if (!context.mounted) return;
    if (remembered != null && remembered.isNotEmpty) {
      setState(() {
        emailController.text = remembered;
        rememberMe = true;
      });
    }
  }

  Future<void> _persistRemember(bool on, String email) async {
    if (on && email.isNotEmpty) {
      await _storage.write(key: 'remember_email', value: email);
    } else {
      await _storage.delete(key: 'remember_email');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/icons/inibg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 26),
              Center(
                child: Image.asset(
                  "assets/icons/logo.png",
                  height: 54,
                ),
              ),
              const SizedBox(height: 40),
              Text("Login",
                  style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 215, 43, 28))),
              const SizedBox(height: 8),
              Text(
                "Kelola bengkel & teknisi Anda\ndengan mudah",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              _buildTextField(
                controller: emailController,
                label: "Username/Email",
                hint: "Masukkan email",
                iconPath: "assets/icons/log.png",
              ),
              const SizedBox(height: 18),

              _buildTextField(
                controller: passwordController,
                label: "Password",
                hint: "Masukkan password",
                iconPath: "assets/icons/password.png",
                isPassword: true,
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        activeColor: const Color.fromARGB(255, 215, 43, 28),
                        checkColor: Colors.white,
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value ?? false;
                          });
                        },
                      ),
                      Text(
                        "Remember me",
                        style: GoogleFonts.poppins(
                            color: const Color.fromARGB(255, 215, 43, 28)),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, "/forgot-password");
                    },
                    child: Text(
                      "Forgot password?",
                      style: GoogleFonts.poppins(
                        color: const Color.fromARGB(255, 68, 68, 68),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 21),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 215, 43, 28),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                    elevation: 8,
                    shadowColor:
                    const Color.fromARGB(255, 215, 43, 28).withAlpha(153),
                  ),
                  onPressed: _isLoading ? null : () async {
                    FocusScope.of(context).unfocus();
                    final email = emailController.text.trim();
                    final password = passwordController.text.trim();

                    if (email.isEmpty || password.isEmpty) {
                      CustomAlert.show(
                        context,
                        title: "Peringatan",
                        message: "Email dan password tidak boleh kosong",
                        type: AlertType.warning,
                      );
                      return;
                    }

                    setState(() => _isLoading = true);
                    try {
                      final auth = Provider.of<AuthProvider>(context, listen: false);
                      final success = await auth.login(email, password);

                      // Simpan / hapus email remembered
                      await _persistRemember(rememberMe, email);

                      if (!context.mounted) return;

                      if (success) {
                        // Jika server wajibkan ganti password → arahkan ke halaman ubah password
                        if (auth.mustChangePassword) {
                          CustomAlert.show(
                            context,
                            title: "Perhatian",
                            message: "Silakan ganti password Anda terlebih dahulu",
                            type: AlertType.warning,
                          );
                          if (!context.mounted) return;
                          Navigator.pushNamedAndRemoveUntil(context, '/changePassword', (_) => false);
                        } else {
                          Navigator.pushNamedAndRemoveUntil(context, '/main', (_) => false);
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        CustomAlert.show(
                          context,
                          title: "Login Gagal",
                          message: e.toString().replaceFirst('Exception: ', ''),
                          type: AlertType.error,
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  },
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    "LOG IN",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),


              const SizedBox(height: 35),

              // Sign Up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: GoogleFonts.poppins(),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, "/register/owner");
                    },
                    child: Text(
                      "Sign Up",
                      style: GoogleFonts.poppins(
                        color: const Color.fromARGB(255, 215, 43, 28),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }

  /// Reusable TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String iconPath,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? obscureText : false,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.red,
          fontWeight: FontWeight.w500,
        ),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset(iconPath, width: 20, height: 20, color: Colors.red),
        ),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: const Color.fromARGB(255, 215, 43, 28),
          ),
          onPressed: () {
            setState(() {
              obscureText = !obscureText;
            });
          },
        )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 215, 43, 28), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 215, 43, 28), width: 2),
        ),
        filled: true,
        fillColor: const Color.fromARGB(222, 255, 255, 255).withAlpha(102),
      ),
      style: GoogleFonts.poppins(color: Colors.black),
    );
  }
}
