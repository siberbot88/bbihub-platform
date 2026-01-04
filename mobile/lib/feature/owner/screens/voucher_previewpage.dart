import 'dart:io';
import 'package:bengkel_online_flutter/core/models/user.dart';
import 'package:bengkel_online_flutter/core/services/api_service.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/voucher_page.dart';
import 'package:bengkel_online_flutter/feature/owner/widgets/custom_header.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VoucherPreviewPage extends StatefulWidget {
  final String nama, diskon, kuota, minBeli, kode, mulai, akhir;
  final File? gambar;

  const VoucherPreviewPage({
    super.key,
    required this.nama,
    required this.diskon,
    required this.kuota,
    required this.minBeli,
    required this.kode,
    required this.mulai,
    required this.akhir,
    this.gambar,
    this.isAdmin = false,
  });

  final bool isAdmin;

  @override
  State<VoucherPreviewPage> createState() => _VoucherPreviewPageState();
}

class _VoucherPreviewPageState extends State<VoucherPreviewPage> {
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  Future<void> _submitToApi() async {
    setState(() => _isLoading = true);
    try {
      // 1. Ambil Data User
      User user = await _apiService.fetchUser();

      // 2. Ambil Workshop ID
      String? workshopId = user.workshopUuid;

      // ✅ PERBAIKAN UTAMA: Cek apakah workshopId ada atau null
      if (workshopId == null) {
        throw Exception("Data Bengkel tidak ditemukan. Pastikan Anda sudah mendaftarkan bengkel.");
      }

      // 3. Kirim ke API (workshopId sekarang dijamin tidak null)
      await _apiService.createVoucher(
          workshopUuid: workshopId,
          title: widget.nama,
          codeVoucher: widget.kode,
          discountValue: widget.diskon,
          quota: widget.kuota,
          minTransaction: widget.minBeli,
          validFrom: widget.mulai,
          validUntil: widget.akhir,
          image: widget.gambar,
          isAdmin: widget.isAdmin
      );

      if (!mounted) return;

      // 4. Navigasi Sukses
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const VoucherPage(showSuccess: true)),
            (route) => false,
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Gagal: ${e.toString().replaceAll('Exception: ', '')}"),
            backgroundColor: Colors.red
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFDC2626);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomHeader(title: "Preview Voucher", onBack: () => Navigator.pop(context)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tampilan Voucher Anda", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),

            // Card Preview
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.gambar != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.file(widget.gambar!, height: 180, width: double.infinity, fit: BoxFit.cover),
                    )
                  else
                    Container(
                      height: 100, width: double.infinity,
                      decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16))
                      ),
                      child: const Icon(Icons.confirmation_number, size: 40, color: Colors.white),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.nama, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("Diskon ${widget.diskon}%", style: GoogleFonts.poppins(fontSize: 14, color: primaryColor, fontWeight: FontWeight.w600)),
                        const Divider(height: 24),
                        _infoRow("Kode", widget.kode),
                        _infoRow("Min. Belanja", "Rp ${widget.minBeli}"),
                        _infoRow("Kuota", "${widget.kuota} Pcs"),
                        _infoRow("Berlaku", "${widget.mulai} s/d ${widget.akhir}"),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primaryColor),
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text("EDIT", style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _submitToApi,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text("SELESAIKAN", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
          Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}