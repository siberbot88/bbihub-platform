import 'package:flutter/material.dart';
import 'package:bengkel_online_flutter/core/screens/offline_screen.dart';
import 'package:bengkel_online_flutter/core/theme/app_colors.dart';

/// Example page demonstrating different ways to show offline screen
///
/// This is a demo page you can navigate to for testing the offline screen.
/// In production, you would integrate this with actual connectivity checking.
class OfflineScreenDemo extends StatelessWidget {
  const OfflineScreenDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Screen Demo'),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Pilih cara menampilkan offline screen:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Full Screen Route
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OfflineScreen(
                      onRetry: () {
                        Navigator.pop(context);
                        _showSnackBar(context, 'Retry button pressed!');
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.open_in_full),
              label: const Text('Full Screen (Recommended)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Bottom Sheet
            OutlinedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: OfflineScreen(
                      onRetry: () {
                        Navigator.pop(context);
                        _showSnackBar(context, 'Retry from bottom sheet!');
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.expand_less),
              label: const Text('Bottom Sheet'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryRed,
                padding: const EdgeInsets.all(16),
                side: const BorderSide(color: AppColors.primaryRed, width: 2),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Dialog
            OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 500),
                      child: OfflineScreen(
                        onRetry: () {
                          Navigator.pop(context);
                          _showSnackBar(context, 'Retry from dialog!');
                        },
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Dialog'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.info,
                padding: const EdgeInsets.all(16),
                side: const BorderSide(color: AppColors.info, width: 2),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Custom Message
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OfflineScreen(
                      title: 'Server Maintenance',
                      message: 'Kami sedang melakukan maintenance.\nMohon coba lagi dalam beberapa saat.',
                      onRetry: () => Navigator.pop(context),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.construction),
              label: const Text('Custom Message'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warning,
                padding: const EdgeInsets.all(16),
                side: const BorderSide(color: AppColors.warning, width: 2),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
