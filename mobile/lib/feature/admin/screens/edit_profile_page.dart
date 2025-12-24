import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_header.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _emailC = TextEditingController(text: "");
  final _usernameC = TextEditingController(text: "");
  final _fullNameC = TextEditingController(text: "");

  ImageProvider? _pickedImage;

  @override
  void dispose() {
    _emailC.dispose();
    _usernameC.dispose();
    _fullNameC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const redDark = Color(0xFF9B0D0D);
    const red = Color(0xFFDC2626);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomHeader(
        title: "Edit Profil", // ⬅️ hanya ganti title sesuai permintaan
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _LabeledField(
                  label: "Email",
                  controller: _emailC,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 14),
                _LabeledField(
                  label: "Username",
                  controller: _usernameC,
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 14),
                _LabeledField(
                  label: "Nama Lengkap",
                  controller: _fullNameC,
                  prefixIcon: Icons.badge_outlined,
                ),
                const SizedBox(height: 18),

                // Upload foto
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Upload Foto Anda",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                GestureDetector(
                  onTap:
                      _pickImageMock, // ganti dengan image picker jika diperlukan
                  child: Container(
                    height: 170,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.shade200,
                        width: 1.2,
                        // (mockup menampilkan border titik2; untuk simple pakai solid)
                      ),
                    ),
                    child: _pickedImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_upload_outlined,
                                  size: 44, color: redDark),
                              const SizedBox(height: 10),
                              Text(
                                "Click to upload or drag & drop",
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "PNG, JPG up to 10MB",
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image(
                              image: _pickedImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 28),

                // Tombol simpan
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 1.5,
                    ),
                    child: Text(
                      "SIMPAN",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Placeholder pemilihan gambar (tanpa dependency).
  void _pickImageMock() {
    // Demo: pakai gambar mockup yang kamu punya
    setState(() {
      _pickedImage = const AssetImage("assets/image/profil_image.png");
      // kalau mau benar2 pilih dari gallery/camera, tinggal ganti
      // dengan image_picker / file_picker.
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Profil disimpan",
            style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: const Color(0xFFDC2626),
      ),
    );
    Navigator.pop(context);
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;

  const _LabeledField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: (v) =>
              (v == null || v.isEmpty) ? "Tidak boleh kosong" : null,
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: const Color(0xFF9B0D0D))
                : null,
            filled: true,
            fillColor: Colors.white,
            hintText: label,
            hintStyle:
                GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFDC2626), width: 1.5),
            ),
          ),
          style: GoogleFonts.poppins(fontSize: 14),
        ),
      ],
    );
  }
}
