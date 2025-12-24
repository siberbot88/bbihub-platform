import 'package:flutter/material.dart';
import 'register_text_field.dart';

class RegisterStepTwo extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController workshopController;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController provinceController;
  final TextEditingController postalCodeController;
  final TextEditingController phoneController;
  final TextEditingController wemailController;
  final TextEditingController urlController;
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final TextEditingController openingTimeController;
  final TextEditingController closingTimeController;
  final TextEditingController operationalDaysController;
  final TextEditingController decsController;

  const RegisterStepTwo({
    super.key,
    required this.formKey,
    required this.workshopController,
    required this.addressController,
    required this.cityController,
    required this.provinceController,
    required this.postalCodeController,
    required this.phoneController,
    required this.wemailController,
    required this.urlController,
    required this.latitudeController,
    required this.longitudeController,
    required this.openingTimeController,
    required this.closingTimeController,
    required this.operationalDaysController,
    required this.decsController,
  });

  String? _validateNotEmpty(String? v, String name) => (v == null || v.trim().isEmpty) ? '$name tidak boleh kosong.' : null;
  
  String? _validateEmailOptional(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final r = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return r.hasMatch(v.trim()) ? null : 'Format email tidak valid.';
  }

  String? _validateTimeFormat(String? v, String name) {
    if (v == null || v.trim().isEmpty) return '$name tidak boleh kosong.';
    final r = RegExp(r'^\d{2}:\d{2}$');
    return r.hasMatch(v.trim()) ? null : 'Format $name harus HH:MM (08:00).';
  }

  String? _validateNumber(String? v, String name) {
    if (v == null || v.trim().isEmpty) return '$name tidak boleh kosong.';
    return double.tryParse(v.trim().replaceAll(',', '.')) == null ? '$name harus berupa angka.' : null;
  }

  String? _validateUrl(String? v, String name) {
    if (v == null || v.trim().isEmpty) return '$name tidak boleh kosong.';
    final s = v.trim().toLowerCase();
    return (s.startsWith('http://') || s.startsWith('https://')) ? null : 'Format $name tidak valid (http/https).';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), offset: const Offset(0, 0), blurRadius: 22)],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 41,
                    height: 41,
                    decoration: BoxDecoration(color: const Color.fromRGBO(220, 38, 38, 0.21), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.store, color: Colors.red, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Isi Data Bengkel", style: TextStyle(fontSize: 14, color: Colors.black)),
                        SizedBox(height: 4),
                        Text("Daftarkan bengkelmu sekarang...", style: TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              RegisterTextField(
                controller: workshopController,
                label: "Nama bengkel",
                hint: "Masukkan Nama bengkel",
                iconPath: "assets/svg/workshop.svg",
                textCapitalization: TextCapitalization.words,
                validator: (v) => _validateNotEmpty(v, 'Nama bengkel'),
              ),
              const SizedBox(height: 22),
              RegisterTextField(
                controller: addressController,
                label: "Alamat Lengkap Bengkel",
                hint: "Contoh: Jl. Merdeka No. 17",
                iconPath: "assets/svg/address.svg",
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                validator: (v) => _validateNotEmpty(v, 'Alamat'),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: RegisterTextField(
                      controller: cityController,
                      label: "Kota",
                      hint: "Masukkan kota",
                      iconPath: "assets/svg/address.svg",
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => _validateNotEmpty(v, 'Kota'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: RegisterTextField(
                      controller: provinceController,
                      label: "Provinsi",
                      hint: "Contoh: Jawa Barat",
                      iconPath: "assets/svg/address.svg",
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => _validateNotEmpty(v, 'Provinsi'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              RegisterTextField(
                controller: postalCodeController,
                label: "Kode Pos",
                hint: "Contoh: 40123",
                iconPath: "assets/svg/address.svg",
                keyboardType: TextInputType.number,
                validator: (v) => _validateNotEmpty(v, 'Kode Pos'),
              ),
              const SizedBox(height: 22),
              RegisterTextField(
                controller: phoneController,
                label: "Telepon Bengkel",
                hint: "Contoh: 081234567890",
                iconPath: "assets/svg/phone.svg",
                keyboardType: TextInputType.phone,
                validator: (v) => _validateNotEmpty(v, 'Telepon'),
              ),
              const SizedBox(height: 22),
              RegisterTextField(
                controller: wemailController,
                label: "Email Bengkel (Opsional)",
                hint: "Contoh: info@bengkeljaya.com",
                iconPath: "assets/svg/email.svg",
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmailOptional,
              ),
              const SizedBox(height: 22),
              RegisterTextField(
                controller: urlController,
                label: "URL Google Maps",
                hint: "Salin dari Google Maps",
                iconPath: "assets/svg/url.svg",
                keyboardType: TextInputType.url,
                validator: (v) => _validateUrl(v, 'URL Google Maps'),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: RegisterTextField(
                      controller: latitudeController,
                      label: "Latitude",
                      hint: "Contoh: -6.9175",
                      iconPath: "assets/svg/url.svg",
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      validator: (v) => _validateNumber(v, 'Latitude'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: RegisterTextField(
                      controller: longitudeController,
                      label: "Longitude",
                      hint: "Contoh: 107.6191",
                      iconPath: "assets/svg/url.svg",
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      validator: (v) => _validateNumber(v, 'Longitude'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: RegisterTextField(
                      controller: openingTimeController,
                      label: "Jam Buka",
                      hint: "HH:MM (Contoh: 08:00)",
                      iconPath: "assets/svg/user.svg",
                      keyboardType: TextInputType.datetime,
                      validator: (v) => _validateTimeFormat(v, 'Jam Buka'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: RegisterTextField(
                      controller: closingTimeController,
                      label: "Jam Tutup",
                      hint: "HH:MM (Contoh: 17:00)",
                      iconPath: "assets/svg/user.svg",
                      keyboardType: TextInputType.datetime,
                      validator: (v) => _validateTimeFormat(v, 'Jam Tutup'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              RegisterTextField(
                controller: operationalDaysController,
                label: "Hari Operasional",
                hint: "Contoh: Senin - Sabtu",
                iconPath: "assets/svg/user.svg",
                textCapitalization: TextCapitalization.words,
                validator: (v) => _validateNotEmpty(v, 'Hari Operasional'),
              ),
              const SizedBox(height: 22),
              RegisterTextField(
                controller: decsController,
                label: "Deskripsi Bengkel",
                hint: "Jelaskan layanan, keunggulan, dll.",
                iconPath: "assets/svg/laporan_tebal.svg",
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                validator: (v) => _validateNotEmpty(v, 'Deskripsi Bengkel'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
