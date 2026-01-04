import 'package:bengkel_online_flutter/core/models/voucher.dart';
import 'package:bengkel_online_flutter/core/services/api_service.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/voucher_editpage.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/voucher_addpage.dart';
import 'package:bengkel_online_flutter/feature/owner/widgets/custom_header.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart'; // ✅ Pastikan import intl

class VoucherPage extends StatefulWidget {
  final bool showSuccess;

  const VoucherPage({super.key, this.showSuccess = false});

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  final ApiService _apiService = ApiService();
  late Future<List<Voucher>> _vouchersFuture;

  final Color _primaryColor = const Color(0xFFDC2626);
  final Color _backgroundColor = Colors.white;
  final TextStyle _fontStyle = GoogleFonts.poppins(fontSize: 12);

  @override
  void initState() {
    super.initState();

    // ✅ Inisialisasi format tanggal (untuk jaga-jaga jika main.dart belum reload)
    initializeDateFormatting('id_ID', null).then((_) {
      _loadData();
    });

    if (widget.showSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Voucher berhasil disimpan 🎉", style: GoogleFonts.poppins(color: Colors.white)),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(20),
          ),
        );
      });
    }
  }

  void _loadData() {
    setState(() {
      _vouchersFuture = _apiService.fetchVouchers(isAdmin: true);
    });
  }

  Future<void> _handleDelete(String id) async {
    try {
      await _apiService.deleteVoucher(id, isAdmin: true);
      if (!mounted) return;
      Navigator.pop(context);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Voucher berhasil dihapus", style: GoogleFonts.poppins()), backgroundColor: Colors.green),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menghapus: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text("Hapus Voucher?", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text("Tindakan ini tidak dapat dibatalkan.", style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Batal", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
            onPressed: () => _handleDelete(id),
            child: Text("Hapus", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,

      // ✅ CUSTOM HEADER DENGAN LOGIKA NAVIGASI
      appBar: CustomHeader(
        title: "Voucher",
        onBack: () {
          // Hapus semua route di stack, buka /main, dan kirim argument 3 (Profile)
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/main',
                (route) => false,
            arguments: 3, // 3 adalah index tab Profile pada Owner
          );
        },
      ),

      body: RefreshIndicator(
        color: _primaryColor,
        onRefresh: () async => _loadData(),
        child: FutureBuilder<List<Voucher>>(
          future: _vouchersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: _primaryColor));
            }
            if (snapshot.hasError) {
              return Center(child: Text("Gagal memuat data", style: _fontStyle));
            }

            final allVouchers = snapshot.data ?? [];
            final activeVouchers = allVouchers.where((v) => !v.isExpired && v.isActive).toList();
            final expiredVouchers = allVouchers.where((v) => v.isExpired).toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader("Voucher Aktif"),
                if (activeVouchers.isEmpty)
                  _buildEmptyState("Belum ada voucher aktif"),
                ...activeVouchers.map((v) => _buildVoucherCard(voucher: v, isExpired: false)),

                const SizedBox(height: 24),

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
        backgroundColor: _primaryColor,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddVoucherPage(isAdmin: true)));
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
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(child: Text(message, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic))),
    );
  }

  Widget _buildVoucherCard({required Voucher voucher, required bool isExpired}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isExpired ? Colors.grey.shade300 : _primaryColor,
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
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  isExpired ? "Kadaluarsa ${voucher.formattedUntilDate}" : "Berlaku sampai ${voucher.formattedUntilDate}",
                  style: GoogleFonts.poppins(fontSize: 12, color: isExpired ? Colors.red : Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  "Slot: ${voucher.quota} • Min Belanja: Rp ${voucher.minTransaction.toStringAsFixed(0)}",
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          if (!isExpired)
            Row(
              children: [
                _buildActionButton(Icons.delete_outline, Colors.red, () => _confirmDelete(voucher.id)),
                const SizedBox(width: 4),
                _buildActionButton(Icons.edit_outlined, Colors.orange, () async {
                  final bool? result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => VoucherEditPage(voucher: voucher, isAdmin: true)),
                  );
                  if (result == true) {
                    _loadData();
                  }
                }),
              ],
            )
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}