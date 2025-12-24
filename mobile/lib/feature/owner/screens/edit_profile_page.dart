import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/custom_alert.dart';
import '../../../../core/models/workshop.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  final Workshop workshop;
  
  const EditProfilePage({super.key, required this.workshop});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Workshop Fields
  late TextEditingController _nameC;
  late TextEditingController _phoneC;
  late TextEditingController _emailC;
  late TextEditingController _addressC;
  late TextEditingController _mapsUrlC;
  late TextEditingController _descriptionC;
  late TextEditingController _openingTimeC;
  late TextEditingController _closingTimeC;
  
  bool _isActive = true;
  bool _isLoading = false;

  File? _pickedImageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final w = widget.workshop;
    _nameC = TextEditingController(text: w.name);
    _phoneC = TextEditingController(text: w.phone);
    _emailC = TextEditingController(text: w.email);
    _addressC = TextEditingController(text: w.address);
    _mapsUrlC = TextEditingController(text: w.mapsUrl ?? '');
    _descriptionC = TextEditingController(text: w.description ?? '');
    _openingTimeC = TextEditingController(text: w.openingTime);
    _closingTimeC = TextEditingController(text: w.closingTime);
    _isActive = w.isActive;
  }

  @override
  void dispose() {
    _nameC.dispose();
    _phoneC.dispose();
    _emailC.dispose();
    _addressC.dispose();
    _mapsUrlC.dispose();
    _descriptionC.dispose();
    _openingTimeC.dispose();
    _closingTimeC.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _pickedImageFile = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar: $e')),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      
      await apiService.updateWorkshop(
        id: widget.workshop.id,
        name: _nameC.text.trim(),
        description: _descriptionC.text.trim(),
        address: _addressC.text.trim(),
        phone: _phoneC.text.trim(),
        email: _emailC.text.trim(),
        mapsUrl: _mapsUrlC.text.trim(),
        openingTime: _openingTimeC.text.trim(),
        closingTime: _closingTimeC.text.trim(),
        operationalDays: widget.workshop.operationalDays, // Preserve logic for now, or add UI later
        isActive: _isActive,
        photo: _pickedImageFile,
        // Optional fields preserved if user didn't edit them
        city: widget.workshop.city, 
        province: widget.workshop.province,
        country: widget.workshop.country,
        postalCode: widget.workshop.postalCode,
      );

      if (!mounted) return;

      // Reflex UI update via AuthProvider
      await context.read<AuthProvider>().checkLoginStatus();

      if (!mounted) return;
      
      CustomAlert.show(
        context,
        title: "Berhasil",
        message: "Data workshop berhasil diperbarui",
        type: AlertType.success,
      );
      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;
      CustomAlert.show(
        context,
        title: "Gagal",
        message: e.toString(),
        type: AlertType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Edit Workshop",
          style: AppTextStyles.heading4(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
               // Workshop Photo (Optional)
              _buildImagePicker(),
              AppSpacing.verticalSpaceXL,
              
              // Workshop Info Card
              Container(
                padding: AppSpacing.paddingLG,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.radiusXL,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _LabeledField(
                      label: "Nama Bengkel",
                      controller: _nameC,
                      prefixIcon: Icons.store_mall_directory_outlined,
                    ),
                    AppSpacing.verticalSpaceLG,
                    _LabeledField(
                      label: "Email Workshop",
                      controller: _emailC,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      readOnly: true, // Typically email is hard to change or managed elsewhere
                    ),
                    AppSpacing.verticalSpaceLG,
                    _LabeledField(
                      label: "Nomor Telepon",
                      controller: _phoneC,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                    ),
                    AppSpacing.verticalSpaceLG,
                     _LabeledField(
                      label: "Alamat Lengkap",
                      controller: _addressC,
                      prefixIcon: Icons.location_on_outlined,
                      maxLines: 2,
                    ),
                    AppSpacing.verticalSpaceLG,
                    _LabeledField(
                      label: "Google Maps URL",
                      controller: _mapsUrlC,
                      keyboardType: TextInputType.url,
                      prefixIcon: Icons.map_outlined,
                      maxLines: 1,
                    ),
                    AppSpacing.verticalSpaceLG,
                     _LabeledField(
                      label: "Deskripsi",
                      controller: _descriptionC,
                      prefixIcon: Icons.description_outlined,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              AppSpacing.verticalSpaceLG,

              // Operational Card
              Container(
                padding: AppSpacing.paddingLG,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.radiusXL,
                  boxShadow: [
                     BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Jam Operasional", style: AppTextStyles.label(color: AppColors.textPrimary)),
                    AppSpacing.verticalSpaceMD,
                    Row(
                      children: [
                        Expanded(child: _LabeledField(label: "Buka", controller: _openingTimeC, prefixIcon: Icons.access_time)),
                        const SizedBox(width: 16),
                        Expanded(child: _LabeledField(label: "Tutup", controller: _closingTimeC, prefixIcon: Icons.access_time_filled)),
                      ],
                    ),
                    AppSpacing.verticalSpaceLG,
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text("Status Bengkel (Buka)", style: AppTextStyles.bodyMedium(color: AppColors.textPrimary)),
                      subtitle: Text("Matikan jika bengkel sedang libur/tutup sementara", style: AppTextStyles.bodySmall(color: AppColors.textHint)),
                      value: _isActive, 
                      activeColor: AppColors.primaryRed,
                      onChanged: (val) {
                        setState(() => _isActive = val);
                      },
                    )
                  ],
                ),
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusXL,
                    ),
                    elevation: 4,
                    shadowColor: AppColors.primaryRed.withAlpha(100),
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : Text(
                    "SIMPAN PERUBAHAN",
                    style: AppTextStyles.button(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryRed, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                image: _pickedImageFile != null
                    ? DecorationImage(image: FileImage(_pickedImageFile!), fit: BoxFit.cover)
                    : (widget.workshop.photo != null)
                      ? DecorationImage(image: NetworkImage(widget.workshop.photo!), fit: BoxFit.cover)
                      : null,
              ),
              child: (_pickedImageFile == null && widget.workshop.photo == null)
                  ? const Icon(Icons.store_rounded, size: 60, color: Colors.grey)
                  : null,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final int maxLines;
  final bool readOnly;

  const _LabeledField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.prefixIcon,
    this.maxLines = 1,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label(color: AppColors.textSecondary)),
        AppSpacing.verticalSpaceXS,
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          validator: (v) => (v == null || v.isEmpty) ? "Tidak boleh kosong" : null,
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.primaryRed)
                : null,
            filled: true,
            fillColor: readOnly ? Colors.grey[100] : AppColors.backgroundLight,
            hintText: "Masukkan $label",
            hintStyle: AppTextStyles.bodyMedium(color: AppColors.textHint),
            contentPadding: AppSpacing.paddingMD,
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusMD,
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusMD,
              borderSide: const BorderSide(color: AppColors.primaryRed, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusMD,
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusMD,
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
          style: AppTextStyles.bodyMedium(color: readOnly ? Colors.grey[600] : null),
        ),
      ],
    );
  }
}
