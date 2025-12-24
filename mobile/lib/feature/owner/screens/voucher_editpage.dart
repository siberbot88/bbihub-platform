import 'dart:io';
import 'package:bengkel_online_flutter/core/models/voucher.dart'; // ✅ Pastikan Import Model Voucher
import 'package:bengkel_online_flutter/core/services/api_service.dart';
import 'package:bengkel_online_flutter/feature/owner/widgets/custom_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class VoucherEditPage extends StatefulWidget {
  final Voucher voucher;

  const VoucherEditPage({super.key, required this.voucher});

  @override
  State<VoucherEditPage> createState() => _VoucherEditPageState();
}

class _VoucherEditPageState extends State<VoucherEditPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  final Color _primaryColor = const Color(0xFFDC2626);

  // Controllers
  late TextEditingController _namaController;
  late TextEditingController _diskonController;
  late TextEditingController _kuotaController;
  late TextEditingController _minTransaksiController;
  late TextEditingController _kodeController;
  late TextEditingController _waktuMulaiController;
  late TextEditingController _waktuBerakhirController;

  File? _newImage;

  @override
  void initState() {
    super.initState();
    // ✅ Mengisi form dengan data voucher yang diterima
    final v = widget.voucher;
    _namaController = TextEditingController(text: v.title);

    // convert double ke string, hilangkan .0 jika bulat
    _diskonController = TextEditingController(text: v.discountValue.toStringAsFixed(0));
    _kuotaController = TextEditingController(text: v.quota.toString());
    _minTransaksiController = TextEditingController(text: v.minTransaction.toStringAsFixed(0));

    _kodeController = TextEditingController(text: v.codeVoucher);

    // Format Tanggal: yyyy-MM-dd
    _waktuMulaiController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(v.validFrom));
    _waktuBerakhirController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(v.validUntil));
  }

  @override
  void dispose() {
    _namaController.dispose();
    _diskonController.dispose();
    _kuotaController.dispose();
    _minTransaksiController.dispose();
    _kodeController.dispose();
    _waktuMulaiController.dispose();
    _waktuBerakhirController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _newImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final start = DateTime.parse(_waktuMulaiController.text);
    final end = DateTime.parse(_waktuBerakhirController.text);
    if (end.isBefore(start)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tanggal berakhir salah")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _apiService.updateVoucher(
        id: widget.voucher.id,
        title: _namaController.text,
        codeVoucher: _kodeController.text,
        discountValue: _diskonController.text,
        quota: _kuotaController.text,
        minTransaction: _minTransaksiController.text,
        validFrom: _waktuMulaiController.text,
        validUntil: _waktuBerakhirController.text,
        image: _newImage,
      );

      if (!mounted) return;

      // Kembali ke halaman list dengan flag 'true' untuk refresh
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Voucher berhasil diupdate"), backgroundColor: Colors.green),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: _primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => controller.text = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomHeader(title: "Edit Voucher", onBack: () => Navigator.pop(context)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildLabel("Nama Voucher"),
              _buildInput(_namaController, "Nama Voucher", Icons.card_giftcard),

              Row(
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _buildLabel("Diskon (%)"),
                    _buildInput(_diskonController, "0-100", Icons.percent, isNumber: true),
                  ])),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _buildLabel("Kuota"),
                    _buildInput(_kuotaController, "Jumlah", Icons.people_outline, isNumber: true),
                  ])),
                ],
              ),

              _buildLabel("Minimal Pembelian (Rp)"),
              _buildInput(_minTransaksiController, "Min Belanja", Icons.attach_money, isNumber: true),

              _buildLabel("Kode Voucher"),
              _buildInput(_kodeController, "Kode", Icons.vpn_key_outlined),

              _buildLabel("Periode Berlaku"),
              Row(
                children: [
                  Expanded(child: _buildDateInput("Mulai", _waktuMulaiController)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDateInput("Berakhir", _waktuBerakhirController)),
                ],
              ),

              const SizedBox(height: 20),
              _buildLabel("Gambar Voucher"),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: _primaryColor.withAlpha(128)),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.red.shade50,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _newImage != null
                        ? Image.file(_newImage!, fit: BoxFit.cover)
                        : (widget.voucher.imageUrl != null)
                        ? Image.network(
                      widget.voucher.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, __) => const Icon(Icons.broken_image, color: Colors.grey),
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined, size: 40, color: _primaryColor),
                        Text("Ganti Gambar", style: GoogleFonts.poppins(fontSize: 12, color: _primaryColor)),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _isLoading ? null : _handleUpdate,
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text("SIMPAN PERUBAHAN", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 12),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 12, color: _primaryColor, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
      style: GoogleFonts.poppins(fontSize: 14),
      validator: (val) => (val == null || val.isEmpty) ? "Wajib diisi" : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
        prefixIcon: Icon(icon, color: _primaryColor, size: 20),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _primaryColor.withAlpha(128))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _primaryColor, width: 1.5)),
      ),
    );
  }

  Widget _buildDateInput(String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => _selectDate(controller),
      style: GoogleFonts.poppins(fontSize: 12),
      validator: (val) => (val == null || val.isEmpty) ? "Isi tgl" : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(Icons.calendar_today, size: 18, color: _primaryColor),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _primaryColor.withAlpha(128))),
      ),
    );
  }
}