import 'dart:io';
import 'package:bengkel_online_flutter/feature/owner/screens/voucher_previewpage.dart';
import 'package:bengkel_online_flutter/feature/owner/widgets/custom_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddVoucherPage extends StatefulWidget {
  final bool isAdmin;

  const AddVoucherPage({super.key, this.isAdmin = false});

  @override
  State<AddVoucherPage> createState() => _AddVoucherPageState();
}

class _AddVoucherPageState extends State<AddVoucherPage> {
  final _formKey = GlobalKey<FormState>();
  final Color _primaryColor = const Color(0xFFDC2626);

  // Controllers
  final _namaController = TextEditingController();
  final _diskonController = TextEditingController();
  final _kuotaController = TextEditingController();
  final _minTransaksiController = TextEditingController();
  final _kodeController = TextEditingController();
  final _waktuMulaiController = TextEditingController();
  final _waktuBerakhirController = TextEditingController();
  File? _voucherImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) setState(() => _voucherImage = File(pickedFile.path));
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
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
      appBar: CustomHeader(title: "Tambah Voucher", onBack: () => Navigator.pop(context)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildLabel("Nama Voucher"),
              _buildInput(_namaController, "Contoh: Diskon Lebaran", Icons.local_offer_outlined),

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
              _buildInput(_minTransaksiController, "Contoh: 50000", Icons.attach_money, isNumber: true),

              _buildLabel("Kode Voucher"),
              _buildInput(_kodeController, "Contoh: DISKON50", Icons.vpn_key_outlined),

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
                  child: _voucherImage != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_voucherImage!, fit: BoxFit.cover))
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined, size: 40, color: _primaryColor),
                      Text("Upload Gambar", style: GoogleFonts.poppins(fontSize: 12, color: _primaryColor)),
                    ],
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
          onPressed: _validateAndSubmit,
          child: Text("LANJUT KE PREVIEW", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
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

  void _validateAndSubmit() {
    if (_formKey.currentState!.validate()) {
      // Logic validasi tanggal sederhana
      final start = DateTime.parse(_waktuMulaiController.text);
      final end = DateTime.parse(_waktuBerakhirController.text);

      if (end.isBefore(start)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tanggal berakhir tidak valid")));
        return;
      }

      // Navigasi ke Preview
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VoucherPreviewPage(
            nama: _namaController.text,
            diskon: _diskonController.text,
            kuota: _kuotaController.text,
            minBeli: _minTransaksiController.text,
            kode: _kodeController.text,
            mulai: _waktuMulaiController.text,
            akhir: _waktuBerakhirController.text,
            gambar: _voucherImage,
            isAdmin: widget.isAdmin,
          ),
        ),
      );
    }
  }
}