import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/custom_header.dart'; // Reuse existing header if possible

class AddServiceOnSitePage extends StatefulWidget {
  const AddServiceOnSitePage({super.key});

  @override
  State<AddServiceOnSitePage> createState() => _AddServiceOnSitePageState();
}

class _AddServiceOnSitePageState extends State<AddServiceOnSitePage> {
  // Controllers
  final _customerNameController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _policeNumberController = TextEditingController();
  final _modelController = TextEditingController();
  final _complaintController = TextEditingController();

  // State
  String _selectedVehicleType = 'Motor'; // Motor, Mobil
  String? _selectedService; // Single selection

  final List<String> _serviceAvailable = [
    'Service Ringan',
    'Service Sedang',
    'Service Berat',
    'Maintenance',
    'Lainnya'
  ];

  @override
  void dispose() {
    _customerNameController.dispose();
    _whatsappController.dispose();
    _policeNumberController.dispose();
    _modelController.dispose();
    _complaintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          "Tambah Servis On-Site",
          style: AppTextStyles.heading4(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSection(
              title: "Data Pelanggan",
              icon: Icons.person_outline,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextFieldLabel("Nama Lengkap", isRequired: true),
                  _buildTextField(
                    controller: _customerNameController,
                    hint: "Masukkan nama pelanggan",
                  ),
                  const SizedBox(height: 16),
                  _buildTextFieldLabel("No. WhatsApp", isRequired: true),
                  _buildTextField(
                    controller: _whatsappController,
                    hint: "0812...",
                    prefixIcon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: "Data Kendaraan",
              icon: Icons.directions_car_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextFieldLabel("Jenis Kendaraan"),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildVehicleTypeSelector(
                          label: "Motor",
                          icon: Icons.motorcycle,
                          isSelected: _selectedVehicleType == 'Motor',
                          onTap: () => setState(() => _selectedVehicleType = 'Motor'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildVehicleTypeSelector(
                          label: "Mobil",
                          icon: Icons.directions_car,
                          isSelected: _selectedVehicleType == 'Mobil',
                          onTap: () => setState(() => _selectedVehicleType = 'Mobil'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextFieldLabel("Nomor Polisi", isRequired: true),
                            _buildTextField(
                              controller: _policeNumberController,
                              hint: "B 1234 XYZ",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextFieldLabel("Tipe/Model"),
                            _buildTextField(
                              controller: _modelController,
                              hint: "Cth: Vario 150",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: "Detail Layanan",
              icon: Icons.build_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextFieldLabel("Jenis Layanan"),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _serviceAvailable.map((service) {
                      final isSelected = _selectedService == service;
                      return ChoiceChip(
                        label: Text(service),
                        selected: isSelected,
                        selectedColor: const Color(0xFFFFEBEE), // Light red
                        backgroundColor: Colors.white,
                        labelStyle: AppTextStyles.bodyMedium(
                          color: isSelected ? AppColors.primaryRed : AppColors.textPrimary,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.primaryRed : AppColors.border,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedService = service;
                            } else {
                              _selectedService = null; // Optional: allow deselect
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  _buildTextFieldLabel("Keluhan / Catatan"),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _complaintController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Jelaskan keluhan pada kendaraan...",
                      hintStyle: AppTextStyles.bodyMedium(color: AppColors.textHint),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primaryRed),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),
      bottomSheet: Container(
        padding: EdgeInsets.only(
          left: 16, 
          right: 16, 
          top: 16, 
          bottom: MediaQuery.of(context).padding.bottom + 16
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement save logic
              Navigator.pop(context);
            },
            icon: const Icon(Icons.save, color: Colors.white),
            label: Text(
              "Simpan Data Servis",
              style: AppTextStyles.heading5(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
         boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primaryRed, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTextStyles.heading4(),
              ),
            ],
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildTextFieldLabel(String label, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: AppTextStyles.bodyMedium(color: AppColors.textPrimary)
            .copyWith(fontWeight: FontWeight.w600),
        children: [
          if (isRequired)
            const TextSpan(
              text: " *",
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium(color: AppColors.textHint),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.textSecondary) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primaryRed),
          ),
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
        ),
      ),
    );
  }

  Widget _buildVehicleTypeSelector({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.textPrimary : Colors.transparent,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.black : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.bodyMedium(
                color: isSelected ? Colors.black : Colors.grey,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
