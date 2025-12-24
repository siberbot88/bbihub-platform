import 'package:bengkel_online_flutter/core/theme/app_colors.dart';
import 'package:bengkel_online_flutter/core/theme/app_text_styles.dart';
import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import 'package:bengkel_online_flutter/core/widgets/custom_alert.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool _isLoading = false;

  Future<void> _checkStatus() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.checkLoginStatus();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (auth.user?.emailVerifiedAt != null) {
      // Verified! Redirect based on workshop status or dashboard
      Navigator.pushNamedAndRemoveUntil(context, '/main', (_) => false);
    } else {
        CustomAlert.show(
        context,
        title: "Belum Terverifikasi",
        message: "Email Anda belum terverifikasi. Silakan cek inbox/spam Anda.",
        type: AlertType.warning,
      );
    }
  }

  Future<void> _resendEmail() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      await auth.sendVerificationEmail();
      if (!mounted) return;
      CustomAlert.show(
        context,
        title: "Sukses",
        message: "Email verifikasi telah dikirim ulang.",
        type: AlertType.success,
      );
    } catch (e) {
      if (!mounted) return;
      CustomAlert.show(
        context,
        title: "Gagal",
        message: e.toString().replaceFirst("Exception: ", ""),
        type: AlertType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mark_email_unread_outlined, color: AppColors.primaryRed, size: 64),
            ),
            const SizedBox(height: 32),
            Text(
              "Verifikasi Email Anda",
              style: AppTextStyles.heading2(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Kami telah mengirimkan link verifikasi ke email Anda. Silakan klik link tersebut untuk mengaktifkan akun.",
              style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: _isLoading ? null : _checkStatus,
                child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text("Saya Sudah Verifikasi", style: AppTextStyles.button()),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _isLoading ? null : _resendEmail,
              child: Text("Kirim Ulang Email", style: AppTextStyles.labelBold(color: AppColors.primaryRed)),
            ),
             const SizedBox(height: 24),
             TextButton(
              onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              },
              child: Text("Logout", style: AppTextStyles.bodyMedium(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}
