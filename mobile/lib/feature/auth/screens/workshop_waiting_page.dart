import 'package:bengkel_online_flutter/core/theme/app_colors.dart';
import 'package:bengkel_online_flutter/core/theme/app_text_styles.dart';
import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import 'package:bengkel_online_flutter/core/widgets/custom_alert.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bengkel_online_flutter/core/widgets/hourglass_animation.dart';

class WorkshopWaitingPage extends StatefulWidget {
  const WorkshopWaitingPage({super.key});

  @override
  State<WorkshopWaitingPage> createState() => _WorkshopWaitingPageState();
}

class _WorkshopWaitingPageState extends State<WorkshopWaitingPage> {
  bool _isLoading = false;

  Future<void> _checkStatus() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.checkLoginStatus();

    if (!mounted) return;
    setState(() => _isLoading = false);

    final workshops = auth.user?.workshops;
    if (workshops != null && workshops.isNotEmpty) {
      final workshop = workshops.first;
      final status = workshop.status;
      
      if (status == 'active' || status == 'verified') {
         Navigator.pushNamedAndRemoveUntil(context, '/main', (_) => false);
      } else if (status == 'rejected') {
          CustomAlert.show(
          context,
          title: "Ditolak",
          message: "Pengajuan bengkel Anda ditolak. Silakan hubungi admin.",
          type: AlertType.error,
        );
      } else {
         CustomAlert.show(
          context,
          title: "Masih Menunggu",
          message: "Status bengkel masih dalam proses verifikasi ($status).",
          type: AlertType.info,
        );
      }
    } else {
         CustomAlert.show(
          context,
          title: "Info",
          message: "Data bengkel belum tersedia. Silakan cek kembali nanti.",
          type: AlertType.warning,
        );
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
            // Image.asset("assets/icons/pending_verification.png", height: 180, errorBuilder: (_,__,___) => const Icon(Icons.hourglass_top, size: 80, color: AppColors.primaryRed)),
            const HourglassAnimation(size: 100, color: AppColors.primaryRed),
            const SizedBox(height: 32),
            Text(
              "Menunggu Verifikasi",
              style: AppTextStyles.heading2(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Data bengkel Anda sedang ditinjau oleh tim kami. Proses ini biasanya memakan waktu 1x24 jam.",
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
                  : Text("Cek Status", style: AppTextStyles.button()),
              ),
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
