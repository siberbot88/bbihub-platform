import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../data/models/membership_plan_model.dart';
import 'webview_payment_screen.dart';
import 'transaction_status_screen.dart';

class PaymentScreen extends StatefulWidget {
  final MembershipPlanModel plan;
  final BillingCycle billingCycle;
  final int totalAmount;

  const PaymentScreen({
    super.key,
    required this.plan,
    required this.billingCycle,
    required this.totalAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;

  Future<void> _processPayment() async {
    setState(() => _isLoading = true);

    try {
      final api = ApiService();
      // Call Backend to get Snap URL
      final result = await api.checkoutSubscription(
        planId: widget.plan.id,
        billingCycle: widget.billingCycle.name,
      );

      if (!mounted) return;

      final paymentUrl = result['payment_url'];
      if (paymentUrl != null && paymentUrl.isNotEmpty) {
        // Debug URL
        debugPrint('Opening WebView: $paymentUrl');
        
        if (!mounted) return;
        
        // Navigate to In-App WebView and wait for result
        final paymentResult = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => WebviewPaymentScreen(
              paymentUrl: paymentUrl,
              title: 'Selesaikan Pembayaran',
            ),
          ),
        );

        if (paymentResult == true && mounted) {
           Navigator.pushReplacement(
             context, 
             MaterialPageRoute(builder: (context) => const TransactionStatusScreen(isSuccess: true))
           );
        }
      } else {
        throw Exception('Link pembayaran tidak ditemukan.');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memproses pembayaran: ${e.toString().replaceAll("Exception: ", "")}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        titleTextStyle: AppTextStyles.heading4(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ringkasan Pesanan', style: AppTextStyles.heading5()),
                  AppSpacing.verticalSpaceMD,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Paket', style: AppTextStyles.bodyMedium(color: Colors.grey)),
                      Text(widget.plan.name, style: AppTextStyles.labelBold()),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Siklus Tagihan', style: AppTextStyles.bodyMedium(color: Colors.grey)),
                      Text(
                        widget.billingCycle == BillingCycle.monthly ? 'Bulanan' : 'Tahunan',
                        style: AppTextStyles.labelBold(),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Pembayaran', style: AppTextStyles.heading5()),
                      Text(
                        currencyFormat.format(widget.totalAmount),
                        style: AppTextStyles.heading4(color: AppColors.primaryRed),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: AppColors.primaryRed.withAlpha(100),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'Bayar Sekarang',
                        style: AppTextStyles.button(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
