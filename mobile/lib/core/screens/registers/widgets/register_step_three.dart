import 'package:flutter/material.dart';
import 'register_text_field.dart';

class RegisterStepThree extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nibController;
  final TextEditingController npwpController;

  const RegisterStepThree({
    super.key,
    required this.formKey,
    required this.nibController,
    required this.npwpController,
  });

  String? _validateNotEmpty(String? v, String name) => (v == null || v.trim().isEmpty) ? '$name tidak boleh kosong.' : null;
  String? _validateOptional(String? v, String name) => null;

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
                    child: const Icon(Icons.badge_outlined, color: Colors.red, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Dokumen Pendukung", style: TextStyle(fontSize: 14, color: Colors.black)),
                        SizedBox(height: 4),
                        Text("Lengkapi dokumen legalitas", style: TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              RegisterTextField(
                controller: nibController,
                label: "NIB (Nomor Induk Berusaha)",
                hint: "Masukkan NIB (Wajib)",
                iconPath: "assets/svg/nib.svg",
                keyboardType: TextInputType.number,
                validator: (v) => _validateNotEmpty(v, 'NIB'),
              ),
              const SizedBox(height: 22),
              RegisterTextField(
                controller: npwpController,
                label: "NPWP (Nomor Pokok Wajib Pajak)",
                hint: "Masukkan NPWP (Opsional)",
                iconPath: "assets/svg/npwp.svg",
                keyboardType: TextInputType.text,
                maxLines: 1,
                validator: (v) => _validateOptional(v, 'NPWP'),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur upload belum diimplementasikan.')),
                  );
                },
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red.withAlpha(128)),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined, size: 36, color: Colors.grey.shade600),
                        const SizedBox(height: 8),
                        Text(
                          "Upload Dokumen Legalitas (Opsional)\n(.pdf, .jpg, .png maks 10MB)",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Informasi Tambahan:\n"
                    "1. Dokumen Anda aman dan hanya digunakan untuk verifikasi.\n"
                    "2. Proses verifikasi dapat memakan waktu 1-2 hari kerja.",
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
