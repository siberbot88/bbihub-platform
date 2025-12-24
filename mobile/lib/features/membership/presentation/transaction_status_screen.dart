import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/auth_provider.dart';

class TransactionStatusScreen extends StatelessWidget {
  final bool isSuccess;

  const TransactionStatusScreen({super.key, required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              isSuccess ? Icons.check_circle_outline : Icons.access_time,
              size: 100,
              color: isSuccess ? Colors.green : Colors.orange,
            ),
            AppSpacing.verticalSpaceLG,
            Text(
              isSuccess ? 'Pembayaran Berhasil!' : 'Menunggu Pembayaran',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading3(),
            ),
            AppSpacing.verticalSpaceMD,
            Text(
              isSuccess
                  ? 'Terima kasih, pembayaran Anda telah kami terima. Paket langganan Anda aktif sekarang.'
                  : 'Selesaikan pembayaran Anda segera untuk mengaktifkan paket.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(color: Colors.grey[600]),
            ),
            AppSpacing.verticalSpaceXL,
            ElevatedButton(
              onPressed: () async {
                // Refresh User Data to get new subscription status
                await context.read<AuthProvider>().checkLoginStatus();
                if (context.mounted) {
                  // Navigate back to Home/Dashboard and clear stack
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Kembali ke Beranda',
                style: AppTextStyles.button(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
