import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bengkel_online_flutter/core/widgets/custom_alert.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bengkel_online_flutter/core/theme/app_colors.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _email;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get email from arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _email = args;
    }
  }

  // Helper: Build password requirement item
  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            color: isMet ? Colors.green : Colors.red.shade300,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: isMet ? Colors.green.shade700 : Colors.grey.shade600,
                fontSize: 12,
                fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build password requirements checklist
  Widget _buildPasswordRequirements() {
    final password = _passwordController.text;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Syarat Password:",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirement('Minimal 8 karakter', password.length >= 8),
          _buildRequirement('Huruf besar (A-Z)', password.contains(RegExp(r'[A-Z]'))),
          _buildRequirement('Huruf kecil (a-z)', password.contains(RegExp(r'[a-z]'))),
          _buildRequirement('Angka (0-9)', password.contains(RegExp(r'[0-9]'))),
          _buildRequirement('Simbol (!@#\$%^&*)', password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))),
        ],
      ),
    );
  }

  Future<void> _resetPassword() async {
    final otp = _otpController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (otp.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      CustomAlert.show(context, title: "Error", message: "Semua kolom wajib diisi", type: AlertType.error);
      return;
    }

    if (password != confirmPassword) {
      CustomAlert.show(context, title: "Error", message: "Konfirmasi password tidak cocok", type: AlertType.error);
      return;
    }

    setState(() => _isLoading = true);

    try {
        const baseUrl = 'http://10.0.2.2:8000/api/v1/auth/reset-password';
        
        final response = await http.post(
            Uri.parse(baseUrl),
            headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
            body: json.encode({
                'email': _email,
                'otp': otp,
                'password': password,
                'password_confirmation': confirmPassword
            }),
        );

        if (!mounted) return;
        final data = json.decode(response.body);

        if (response.statusCode == 200) {
             CustomAlert.show(
                context,
                title: "Sukses",
                message: "Password berhasil diubah via OTP. Silakan login.",
                type: AlertType.success,
             );
             
             // Wait for alert to be seen
             await Future.delayed(const Duration(seconds: 2));

             // Clear stack and go to login
             if (!mounted) return;
             Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        } else {
             CustomAlert.show(
                context,
                title: "Gagal",
                message: data['message'] ?? 'Gagal mereset password.',
                type: AlertType.error,
             );
        }

    } catch (e) {
        if (mounted) {
             CustomAlert.show(context, title: "Error", message: "Connection error: $e", type: AlertType.error);
        }
    } finally {
        if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_email == null) {
      return Scaffold(body: Center(child: Text("Invalid Route: Email missing")));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Buat Password Baru", style: GoogleFonts.poppins(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(
                    "Verifikasi OTP",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                    "Masukkan kode OTP yang dikirim ke $_email",
                    style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 16),
                TextField(
                    controller: _otpController,
                    decoration: InputDecoration(
                        labelText: "Kode OTP (6 Digit)",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.lock_clock),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                ),
                const SizedBox(height: 24),

                Text(
                    "Password Baru",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onChanged: (value) => setState(() {}), // Trigger rebuild for realtime validation
                    decoration: InputDecoration(
                        labelText: "New Password",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        helperText: "Password harus memenuhi syarat di bawah",
                        helperStyle: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                    ),
                ),
                const SizedBox(height: 12),
                
                // Password Requirements Checklist
                _buildPasswordRequirements(),
                
                const SizedBox(height: 16),
                TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                        labelText: "Confirm Password",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.lock_reset),
                    ),
                ),

                const SizedBox(height: 32),
                SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isLoading ? null : _resetPassword,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text("Reset Password", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                ),
            ],
        ),
      ),
    );
  }
}
