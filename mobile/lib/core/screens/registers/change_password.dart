import 'package:bengkel_online_flutter/core/widgets/custom_alert.dart';
import 'package:bengkel_online_flutter/feature/owner/widgets/custom_header.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Import yang Anda butuhkan untuk logika
import 'package:bengkel_online_flutter/core/services/api_service.dart';
import 'package:bengkel_online_flutter/core/services/auth_provider.dart';

class UbahPasswordPage extends StatefulWidget {
  const UbahPasswordPage({super.key});

  @override
  State<UbahPasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<UbahPasswordPage> {
  // --- Logika State (Semua sudah ada) ---
  final ApiService _apiService = ApiService();
  bool _saving = false;
  String? _errorMessage;

  final TextEditingController lastController = TextEditingController();
  final TextEditingController newController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool obscureLast = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  final _formKey = GlobalKey<FormState>();
  final Color primaryRed = const Color.fromARGB(255, 215, 43, 28);
  
  // Password Strength State
  String _passwordStrength = '';
  Color _strengthColor = Colors.grey;
  double _strengthValue = 0.0;

  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = '';
        _strengthValue = 0.0;
        _strengthColor = Colors.grey;
      });
      return;
    }

    double strength = 0;
    if (password.length >= 8) strength += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;

    setState(() {
      _strengthValue = strength;
      if (strength <= 0.25) {
        _passwordStrength = 'Lemah';
        _strengthColor = Colors.red;
      } else if (strength <= 0.5) {
        _passwordStrength = 'Sedang';
        _strengthColor = Colors.orange;
      } else if (strength <= 0.75) {
        _passwordStrength = 'Kuat';
        _strengthColor = Colors.lightGreen;
      } else {
        _passwordStrength = 'Sangat Kuat';
        _strengthColor = Colors.green;
      }
    });
  }

  // --- Fungsi _save (Logika dari file Anda) ---
  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      await _apiService.changePassword(
        currentPassword: lastController.text,
        newPassword: newController.text,
        confirmPassword: confirmController.text,
      );

      if (!mounted) return;
      context.read<AuthProvider>().clearMustChangePassword();

      // Show Custom Success Alert
      CustomAlert.show(
        context,
        title: 'Berhasil',
        message: 'Password berhasil diubah. Silakan login kembali jika diperlukan.',
        type: AlertType.success,
      );

      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      
      // Go to main page or logout depending on flow, usually main if inside app
      Navigator.of(context).pushReplacementNamed('/main');
    } catch (e) {
      if (mounted) {
        // Show Custom Error Alert
        final msg = e.toString().replaceFirst("Exception: ", "");
        CustomAlert.show(
          context,
          title: 'Gagal Mengubah Password',
          message: msg,
          type: AlertType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  // --- Helper untuk InputDecoration (Disederhanakan) ---
  InputDecoration _buildInputDecoration({
    required String label,
    required String hint,
    required IconData icon, // Menggunakan IconData lebih fleksibel
    required bool obscure,
    required VoidCallback toggle,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        color: primaryRed,
        fontWeight: FontWeight.w500,
        fontSize: 14, // Standar font size
      ),
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
      prefixIcon: Icon(icon, color: primaryRed, size: 22),
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: primaryRed,
        ),
        onPressed: toggle,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryRed.withAlpha(128), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryRed, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade800, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade800, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHeader(
        title: "Ubah Password",
        onBack: () {
          Navigator.pop(context);
        },
      ),
      backgroundColor: Colors.white,

      // 1. Menggunakan SingleChildScrollView agar tidak overflow saat keyboard muncul
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 2. Ornamen / Header Visual
              CircleAvatar(
                radius: 40,
                backgroundColor: primaryRed.withAlpha(26),
                child: Icon(
                  Icons.lock_reset_rounded,
                  color: primaryRed,
                  size: 44,
                ),
              ),
              const SizedBox(height: 16),

              // 3. Judul dan Subjudul
              Text(
                "Buat Password Baru",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 22, // Ukuran standar judul
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Password baru Anda harus berbeda dari password yang digunakan sebelumnya.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14, // Ukuran standar sub-judul
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),

              // 4. Form Fields
              // 🔹 Last Password
              TextFormField(
                controller: lastController,
                obscureText: obscureLast,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: _buildInputDecoration(
                  label: "Password Lama",
                  hint: "Masukkan password lama",
                  icon: Icons.lock_outline_rounded,
                  obscure: obscureLast,
                  toggle: () => setState(() => obscureLast = !obscureLast),
                ),
                validator: (v) =>
                v == null || v.isEmpty ? "Isi password lama" : null,
              ),
              const SizedBox(height: 18),

              // 🔹 New Password
              TextFormField(
                controller: newController,
                obscureText: obscureNew,
                onChanged: _checkPasswordStrength,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: _buildInputDecoration(
                  label: "Password Baru",
                  hint: "Masukkan password baru",
                  icon: Icons.lock_open_rounded,
                  obscure: obscureNew,
                  toggle: () => setState(() => obscureNew = !obscureNew),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Isi password baru";
                  if (v.length < 8) return "Minimal 8 karakter";
                  return null;
                },
              ),
              const SizedBox(height: 8),
              
              // 🔹 Password Strength Indicator
              if (newController.text.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kekuatan Password:',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          _passwordStrength,
                          style: GoogleFonts.poppins(
                            fontSize: 12, 
                            fontWeight: FontWeight.bold,
                            color: _strengthColor
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: _strengthValue,
                        backgroundColor: Colors.grey.shade200,
                        color: _strengthColor,
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              
              const SizedBox(height: 18),

              // 🔹 Confirm Password
              TextFormField(
                controller: confirmController,
                obscureText: obscureConfirm,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: _buildInputDecoration(
                  label: "Konfirmasi Password",
                  hint: "Konfirmasi password baru",
                  icon: Icons.check_circle_outline_rounded,
                  obscure: obscureConfirm,
                  toggle: () =>
                      setState(() => obscureConfirm = !obscureConfirm),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Konfirmasi password";
                  if (v != newController.text) return "Password tidak sama";
                  return null;
                },
              ),

              // 5. Error Message Display (Secondary fallback if alert misses)
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 24.0, left: 8, right: 8),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.red.shade800,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),

      // 6. Tombol 'SAVE' di bawah layar (Modern UX)
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: SizedBox(
            height: 52, // Tinggi standar tombol
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Sesuaikan radius
                ),
                elevation: 4,
                shadowColor: primaryRed.withAlpha(102),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _saving
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : Text(
                  'SAVE PASSWORD',
                  key: const ValueKey('save_text'),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
