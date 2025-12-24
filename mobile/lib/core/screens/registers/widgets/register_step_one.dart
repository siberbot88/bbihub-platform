import 'package:flutter/material.dart';
import 'register_text_field.dart';

class RegisterStepOne extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullnameController;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onToggleObscurePassword;
  final VoidCallback onToggleObscureConfirmPassword;

  const RegisterStepOne({
    super.key,
    required this.formKey,
    required this.fullnameController,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onToggleObscurePassword,
    required this.onToggleObscureConfirmPassword,
  });

  String? _validateNotEmpty(String? v, String name) => (v == null || v.trim().isEmpty) ? '$name tidak boleh kosong.' : null;
  
  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email tidak boleh kosong.';
    final r = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return r.hasMatch(v.trim()) ? null : 'Format email tidak valid.';
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password tidak boleh kosong.';
    if (v.length < 8) return 'Password minimal 8 karakter.';
    return null;
  }

  String? _validateConfirmPassword(String? v) {
    if (v == null || v.isEmpty) return 'Verifikasi password tidak boleh kosong.';
    if (v != passwordController.text) return 'Password tidak cocok.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), offset: const Offset(0, 0), blurRadius: 22)],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 41,
                    height: 41,
                    decoration: BoxDecoration(color: const Color.fromRGBO(220, 38, 38, 0.21), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.person, color: Colors.red, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Isi Data Diri", style: TextStyle(fontSize: 14, color: Colors.black)),
                        SizedBox(height: 4),
                        Text("Buatlah akun pertamamu...", style: TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              RegisterTextField(
                controller: fullnameController,
                label: "Nama Lengkap",
                hint: "Masukkan nama lengkap kamu",
                iconPath: "assets/svg/user.svg",
                textCapitalization: TextCapitalization.words,
                validator: (v) => _validateNotEmpty(v, 'Nama Lengkap'),
              ),
              const SizedBox(height: 22),
              RegisterTextField(
                controller: usernameController,
                label: "Username",
                hint: "Masukkan username",
                iconPath: "assets/svg/user.svg",
                keyboardType: TextInputType.visiblePassword,
                validator: (v) => _validateNotEmpty(v, 'Username'),
              ),
              const SizedBox(height: 22),
              RegisterTextField(
                controller: emailController,
                label: "Email",
                hint: "Masukkan email kamu",
                iconPath: "assets/svg/email.svg",
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 22),
              RegisterTextField(
                controller: passwordController,
                label: "Password",
                hint: "Minimal 8 karakter",
                iconPath: "assets/svg/key.svg",
                isPassword: true,
                obscureState: obscurePassword,
                onToggleObscure: onToggleObscurePassword,
                validator: _validatePassword,
              ),
              const SizedBox(height: 22),
              RegisterTextField(
                controller: confirmPasswordController,
                label: "Verifikasi Password",
                hint: "Ulangi password kamu",
                iconPath: "assets/svg/key.svg",
                isPassword: true,
                obscureState: obscureConfirmPassword,
                onToggleObscure: onToggleObscureConfirmPassword,
                validator: _validateConfirmPassword,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
