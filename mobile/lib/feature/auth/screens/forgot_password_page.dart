import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import 'package:bengkel_online_flutter/core/widgets/custom_alert.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bengkel_online_flutter/core/theme/app_colors.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      CustomAlert.show(
        context,
        title: "Error",
        message: "Email tidak boleh kosong",
        type: AlertType.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
        // Direct call or use ApiService. Ideally use ApiService/AuthProvider
        // For speed, implementing direct http first, then refactor can move to service
        // But better to use consistent http client.
        // Assuming AuthProvider or ApiService exposes client? No, let's just use http for now 
        // using localhost definition
        
        // BETTER: Use ApiService if available. Checking later.
        // For now, raw implementations to ensure it works.
        const baseUrl = 'http://10.0.2.2:8000/api/v1/auth/forgot-password';
        
        final response = await http.post(
            Uri.parse(baseUrl),
            headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
            body: json.encode({'email': email}),
        );

        if (!mounted) return;

        final data = json.decode(response.body);

        if (response.statusCode == 200) {
             CustomAlert.show(
                context,
                title: "Sukses",
                message: "Kode OTP telah dikirim ke email Anda.",
                type: AlertType.success,
             );
             
             // Navigate to Reset Page
             Navigator.pushNamed(context, '/reset-password', arguments: email);

        } else {
             CustomAlert.show(
                context,
                title: "Gagal",
                message: data['message'] ?? 'Terjadi kesalahan.',
                type: AlertType.error,
             );
        }

    } catch (e) {
        if (mounted) {
             CustomAlert.show(
                context,
                title: "Error",
                message: "Gagal terhubung ke server: $e",
                type: AlertType.error,
             );
        }
    } finally {
        if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Lupa Password", style: GoogleFonts.poppins(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
         padding: const EdgeInsets.all(24.0),
         child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(
                    "Reset Password",
                    style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                    "Masukkan email yang terdaftar. Kami akan mengirimkan kode OTP untuk mereset password Anda.",
                    style: GoogleFonts.poppins(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isLoading ? null : _sendOtp,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text("Kirim Kode OTP", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                ),
            ],
         ),
      ),
    );
  }
}
