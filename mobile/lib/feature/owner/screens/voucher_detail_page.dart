import 'package:bengkel_online_flutter/core/models/voucher.dart';
import 'package:bengkel_online_flutter/core/services/api_service.dart';
import 'package:bengkel_online_flutter/core/widgets/custom_alert.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/voucher_editpage.dart';
import 'package:bengkel_online_flutter/feature/owner/widgets/custom_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';

class VoucherDetailPage extends StatefulWidget {
  final Voucher voucher;

  const VoucherDetailPage({super.key, required this.voucher});

  @override
  State<VoucherDetailPage> createState() => _VoucherDetailPageState();
}

class _VoucherDetailPageState extends State<VoucherDetailPage> {
  final ApiService _apiService = ApiService();
  late Voucher _voucher;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _voucher = widget.voucher;
  }

  Future<void> _handleDelete() async {
    setState(() => _isLoading = true);
    try {
      await _apiService.deleteVoucher(_voucher.id);
      if (!mounted) return;
      
      // Return specific action string
      Navigator.pop(context, 'deleted');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      CustomAlert.show(
        context,
        title: "Gagal",
        message: "Gagal menghapus: $e",
        type: AlertType.error,
      );
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLG),
        title: Text("Hapus Voucher?", style: AppTextStyles.heading4()),
        content: Text("Tindakan ini tidak dapat dibatalkan.", style: AppTextStyles.bodyMedium()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Batal", style: AppTextStyles.buttonSmall(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMD),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _handleDelete();
            },
            child: Text("Hapus", style: AppTextStyles.buttonSmall(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VoucherEditPage(voucher: _voucher)),
    );

    if (result == true) {
      if (!mounted) return;
      // Return specific action string
      Navigator.pop(context, 'updated');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = _voucher.isExpired;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomHeader(
        title: "Detail Voucher",
        onBack: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageHeader(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _voucher.title,
                          style: AppTextStyles.heading3(),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isExpired ? Colors.grey.shade100 : AppColors.success.withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isExpired ? Colors.grey : AppColors.success,
                          ),
                        ),
                        child: Text(
                          isExpired ? "Kadaluarsa" : "Aktif",
                          style: AppTextStyles.caption(
                            color: isExpired ? Colors.grey : AppColors.success,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoCard(),
                  const SizedBox(height: 24),
                  Text("Deskripsi", style: AppTextStyles.heading4()),
                  const SizedBox(height: 8),
                  Text(
                    "Gunakan kode voucher ini untuk mendapatkan potongan harga pada transaksi di bengkel.",
                    style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : _confirmDelete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMD),
                ),
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text("Hapus"),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMD),
                ),
                child: const Text("Edit Voucher", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        width: double.infinity,
        color: Colors.grey.shade100,
        child: _voucher.imageUrl != null
            ? Image.network(
                _voucher.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text("No Image", style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow("Kode Voucher", _voucher.codeVoucher, isCopyable: true),
          const Divider(height: 24),
          _buildDetailRow("Diskon", "${_voucher.discountValue}%"),
          const Divider(height: 24),
          _buildDetailRow("Min. Transaksi", "Rp ${_voucher.minTransaction.toStringAsFixed(0)}"),
          const Divider(height: 24),
          _buildDetailRow("Kuota", "${_voucher.quota} tersisa"),
          const Divider(height: 24),
          _buildDetailRow("Berlaku Sampai", _voucher.formattedUntilDate),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isCopyable = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium(color: AppColors.textSecondary)),
        Row(
          children: [
            Text(value, style: AppTextStyles.heading5()),
            if (isCopyable) ...[
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  CustomAlert.show(context, title: "Disalin", message: "Kode voucher disalin", type: AlertType.info);
                },
                child: const Icon(Icons.copy, size: 18, color: AppColors.primaryRed),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
