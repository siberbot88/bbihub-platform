import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final bool showBack; // flag untuk tampilkan tombol back
  final double roundedBottomRadius;
  final List<Widget>? actions;

  const CustomHeader(
      {super.key,
      required this.title,
      this.onBack,
      this.showBack = true,
      this.roundedBottomRadius = 28,
      this.actions});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    double fontSize = 18;
    if (screenWidth < 360) {
      fontSize = 16; // HP kecil
    } else if (screenWidth > 600) {
      fontSize = 20; // Tablet
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: AppBar(
        centerTitle: true,
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        leading: showBack
            ? IconButton(
                icon: SvgPicture.asset(
                  "assets/icons/back.svg",
                  width: 24,
                  height: 24,
                ),
                onPressed: onBack ?? () => Navigator.pop(context),
              )
            : null,
        actions: actions,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF510707),
                Color(0xFF9B0D0D),
                Color(0xFFB70F0F),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
