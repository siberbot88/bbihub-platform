import 'package:flutter/material.dart';
import 'package:bengkel_online_flutter/core/theme/app_colors.dart';
import 'package:bengkel_online_flutter/core/theme/app_text_styles.dart';
import '../premium_membership_screen.dart';

class PremiumLimitDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onUpgrade;

  const PremiumLimitDialog({
    super.key,
    this.title = 'Batas Akses Tercapai',
    this.message = 'Anda telah mencapai batas maksimal fitur paket Gratis. Upgrade ke Premium untuk akses tanpa batas!',
    this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium,
                size: 48,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 16),
             Text(
              title,
              style: AppTextStyles.heading3(color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.bodyMedium(color: Colors.grey[600]!),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog first
                  if (onUpgrade != null) {
                    onUpgrade!();
                  } else {
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PremiumMembershipScreen(
                          onViewMembershipPackages: null, // Open default view
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                child: Text('Upgrade Sekarang', style: AppTextStyles.button(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Nanti Saja', style: AppTextStyles.bodyMedium(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}
