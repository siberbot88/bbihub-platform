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

class ListVoucherPage extends StatefulWidget {
  const ListVoucherPage({super.key});

  @override
  State<ListVoucherPage> createState() => _ListVoucherPageState();
}

class _ListVoucherPageState extends State<ListVoucherPage> {
  final ApiService _apiService = ApiService();
  late Future<List<Voucher>> _vouchersFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _filterStatus = "Semua"; // Semua, Aktif, Kadaluarsa

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: "Cari Voucher",
        onBack: () => Navigator.pop(context),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryRed,
        onRefresh: () async => _loadData(),
        child: Column(
          children: [
            _buildSearchBar(),
            _buildFilterChips(),
            Expanded(
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
                  final filteredVouchers = allVouchers.where((v) {
                    final query = _searchQuery.toLowerCase();
                    final matchesSearch = v.title.toLowerCase().contains(query) ||
                                          v.codeVoucher.toLowerCase().contains(query);
                    
                    if (!matchesSearch) return false;

                    if (_filterStatus == "Aktif") return !v.isExpired && v.isActive;
                    if (_filterStatus == "Kadaluarsa") return v.isExpired;
                    return true; // "Semua"
                  }).toList();

                  if (filteredVouchers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 60, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            "Tidak ada voucher ditemukan",
                            style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: AppSpacing.screenPadding,
                    itemCount: filteredVouchers.length,
                    itemBuilder: (context, index) {
                      final voucher = filteredVouchers[index];
                      return _buildVoucherCard(voucher: voucher, isExpired: voucher.isExpired);
                    },
                  );
                },
              ),
            ),
          ],
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: "Cari voucher...",
          prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
          filled: true,
          fillColor: AppColors.backgroundLight,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: AppRadius.radiusLG,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusLG,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusLG,
            borderSide: const BorderSide(color: AppColors.primaryRed, width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ["Semua", "Aktif", "Kadaluarsa"];
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _filterStatus == filter;
          return ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) setState(() => _filterStatus = filter);
            },
            selectedColor: AppColors.primaryRed,
            backgroundColor: Colors.grey.shade100,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? Colors.transparent : Colors.grey.shade300,
              ),
            ),
          );
        },
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
        if (result == true) {
          _loadData();
          // Show success alert after deletion
          if (!mounted) return;
          CustomAlert.show(
            context,
            title: "Berhasil",
            message: "Voucher berhasil dihapus",
            type: AlertType.success,
          );
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
