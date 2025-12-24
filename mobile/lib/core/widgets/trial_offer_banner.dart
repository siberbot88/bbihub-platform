import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import 'package:bengkel_online_flutter/core/services/api_service.dart';
import 'package:bengkel_online_flutter/core/widgets/midtrans_payment_webview.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Trial Offer Banner Widget
/// Shows prominently on owner dashboard if eligible for trial
class TrialOfferBanner extends StatelessWidget {
  const TrialOfferBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    // Only show if user is NOT premium (no active membership, trial, or used trial)
    if (user == null || user.isPremium || user.trialUsed) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
             Color(0xFF9B0D0D), // Dark Red
             Color(0xFFB70F0F), // Primary Red
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB70F0F).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_user_outlined, // More professional icon
                color: Colors.white,
                size: 36,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Coba Premium Gratis', // No emoji
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins', // Ensure font consistency
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Akses fitur lengkap 7 hari, lalu Rp 99K/bulan',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _startTrial(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFB70F0F), // Red text
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Slightly less rounded for "official" look
                ),
                elevation: 0,
              ),
              child: const Text(
                'Mulai Trial Sekarang',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Batal kapan saja. Tidak ada tagihan jika batal sebelum trial berakhir.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _startTrial(BuildContext context) async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );

      // Call API
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/v1/owner/subscription/start-trial'),
        headers: {
          'Authorization': 'Bearer ${auth.token}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      // Close loading
      if (context.mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final snapToken = data['snap_token'];
        final paymentUrl = data['payment_url'];

        // Open Midtrans payment in webview
        if (context.mounted) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MidtransPaymentWebView(
                paymentUrl: paymentUrl,
                snapToken: snapToken,
              ),
            ),
          );

          // Handle payment result
          if (result == 'success') {
            try {
              // Force backend to check Midtrans status (Crucial for localhost where webhooks fail)
              await ApiService().checkSubscriptionStatus();
            } catch (e) {
              debugPrint("Warning: Failed to sync sub status: $e");
            }

            // Refresh user data
            await auth.checkLoginStatus();
            if (context.mounted) {
              _showTrialActivatedSuccess(context);
            }
          } else if (result == 'error') {
            if (context.mounted) {
              _showError(context, 'Pembayaran gagal atau dibatalkan');
            }
          }
        }
      } else {
        final message = json.decode(response.body)['message'];
        if (context.mounted) {
          _showError(context, message);
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        _showError(context, 'Gagal memulai trial: $e');
      }
    }
  }

  void _showTrialActivatedSuccess(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: const BoxDecoration(
                color: Color(0xFFB70F0F), // Primary Red
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: const Column(
                children: [
                   Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 56),
                   SizedBox(height: 12),
                   Text(
                     'Trial Berhasil Diaktifkan',
                     style: TextStyle(
                       color: Colors.white,
                       fontSize: 18,
                       fontWeight: FontWeight.bold,
                       fontFamily: 'Poppins',
                     ),
                     textAlign: TextAlign.center,
                   ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Text(
                    'Akun Premium aktif selama 7 hari ke depan.',
                    style: TextStyle(fontSize: 14, height: 1.5, fontFamily: 'Poppins'),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Akses Premium Anda:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            color: Color(0xFFB70F0F)
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureItem('Laporan & Analytics Bisnis'),
                        const SizedBox(height: 8),
                        _buildFeatureItem('Export Laporan Keuangan'),
                        const SizedBox(height: 8),
                        _buildFeatureItem('Manajemen Staff Unlimited'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB70F0F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Mulai Gunakan Fitur',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 18),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 13, fontFamily: 'Poppins'),
        ),
      ],
    );
  }

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
