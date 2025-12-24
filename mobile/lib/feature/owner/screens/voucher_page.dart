import 'package:bengkel_online_flutter/core/models/voucher.dart';
import 'package:bengkel_online_flutter/core/services/api_service.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/voucher_addpage.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/voucher_detail_page.dart';
import 'package:bengkel_online_flutter/feature/owner/widgets/custom_header.dart';
import 'package:bengkel_online_flutter/core/widgets/custom_alert.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import 'list_voucher_page.dart';

class VoucherPage extends StatefulWidget {
  final bool showSuccess;

  const VoucherPage({super.key, this.showSuccess = false});

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  final ApiService _apiService = ApiService();
  late Future<List<Voucher>> _vouchersFuture;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) {
      _loadData();
    });

    if (widget.showSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomAlert.show(
          context,
          title: "Berhasil",
          message: "Voucher berhasil disimpan 🎉",
          type: AlertType.success,
        );
      });
    }
  }

  void _loadData() {
    setState(() {
      _vouchersFuture = _apiService.fetchVouchers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomHeader(
        title: "Voucher",
        onBack: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/main',
            (route) => false,
            arguments: 3,
          );
        },
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ListVoucherPage()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryRed,
        onRefresh: () async => _loadData(),
        child: FutureBuilder<List<Voucher>>(
          future: _vouchersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryRed));
            }
            if (snapshot.hasError) {
              return Center(child: Text("Gagal memuat data", style: AppTextStyles.bodyMedium()));
            }

            final allVouchers = snapshot.data ?? [];
            final activeVouchers = allVouchers.where((v) => !v.isExpired && v.isActive).toList();
            final expiredVouchers = allVouchers.where((v) => v.isExpired).toList();

            return ListView(
              padding: AppSpacing.screenPadding,
              children: [
                _buildSectionHeader("Voucher Aktif"),
                if (activeVouchers.isEmpty)
                  _buildEmptyState("Belum ada voucher aktif"),
                ...activeVouchers.map((v) => _buildVoucherCard(voucher: v, isExpired: false)),

                AppSpacing.verticalSpaceXL,

                _buildSectionHeader("Voucher Kadaluarsa"),
                if (expiredVouchers.isEmpty)
                  _buildEmptyState("Tidak ada voucher kadaluarsa"),
                ...expiredVouchers.map((v) => _buildVoucherCard(voucher: v, isExpired: true)),

                const SizedBox(height: 80),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryRed,
        shape: const CircleBorder(),
        elevation: 4,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddVoucherPage()));
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTextStyles.heading4(color: Colors.black87),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          message,
          style: AppTextStyles.bodyMedium(color: AppColors.textSecondary).copyWith(fontStyle: FontStyle.italic),
        ),
      ),
    );
  }

  Widget _buildVoucherCard({required Voucher voucher, required bool isExpired}) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VoucherDetailPage(voucher: voucher)),
        );
        if (result != null) {
          _loadData();
          
          if (!mounted) return;

          if (result == 'deleted') {
            CustomAlert.show(
              context,
              title: "Berhasil",
              message: "Voucher berhasil dihapus",
              type: AlertType.success,
            );
          } else if (result == 'updated') {
            CustomAlert.show(
              context,
              title: "Berhasil",
              message: "Voucher berhasil diperbarui",
              type: AlertType.success,
            );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.radiusLG,
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isExpired ? Colors.grey.shade300 : AppColors.primaryRed,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.confirmation_number_outlined, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    voucher.title,
                    style: AppTextStyles.heading5(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isExpired ? "Kadaluarsa ${voucher.formattedUntilDate}" : "Berlaku sampai ${voucher.formattedUntilDate}",
                    style: AppTextStyles.caption(
                      color: isExpired ? AppColors.error : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Slot: ${voucher.quota} • Min: Rp ${voucher.minTransaction.toStringAsFixed(0)}",
                    style: AppTextStyles.caption(color: AppColors.textHint),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}