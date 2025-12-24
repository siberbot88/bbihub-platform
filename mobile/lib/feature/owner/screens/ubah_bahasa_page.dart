import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/custom_alert.dart';

class UbahBahasaPage extends StatefulWidget {
  const UbahBahasaPage({super.key});

  @override
  State<UbahBahasaPage> createState() => _UbahBahasaPageState();
}

class _UbahBahasaPageState extends State<UbahBahasaPage> with SingleTickerProviderStateMixin {
  String _selectedLanguage = "Bahasa Indonesia";
  late AnimationController _animController;

  final List<String> languages = [
    "English",
    "Bahasa Indonesia",
    "Bahasa Melayu",
    "한국어 (Korean)",
    "日本語 (Japanese)",
    "中文 (Mandarin)",
    "Français",
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _selectLanguage(String lang) {
    setState(() => _selectedLanguage = lang);
    CustomAlert.show(
      context,
      title: "Berhasil",
      message: "Bahasa diubah ke $lang",
      type: AlertType.success,
    );
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
          "Ubah Bahasa",
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
      body: ListView.builder(
        padding: AppSpacing.screenPadding,
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final lang = languages[index];
          final isSelected = _selectedLanguage == lang;

          // Animation
          final animation = Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _animController,
              curve: Interval(
                (index * 0.1).clamp(0.0, 1.0),
                1.0,
                curve: Curves.easeOutQuint,
              ),
            ),
          );

          final fadeAnimation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: _animController,
              curve: Interval(
                (index * 0.1).clamp(0.0, 1.0),
                1.0,
                curve: Curves.easeOut,
              ),
            ),
          );

          return AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return FadeTransition(
                opacity: fadeAnimation,
                child: SlideTransition(
                  position: animation,
                  child: child,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.radiusLG,
                border: Border.all(
                  color: isSelected ? AppColors.primaryRed : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                onTap: () => _selectLanguage(lang),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryRed.withAlpha(26) : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.language_rounded,
                    color: isSelected ? AppColors.primaryRed : Colors.grey,
                    size: 24,
                  ),
                ),
                title: Text(
                  lang,
                  style: isSelected
                      ? AppTextStyles.heading5(color: AppColors.primaryRed)
                      : AppTextStyles.bodyLarge(color: AppColors.textPrimary),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryRed)
                    : const Icon(Icons.circle_outlined, color: Colors.grey),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLG),
              ),
            ),
          );
        },
      ),
    );
  }
}
