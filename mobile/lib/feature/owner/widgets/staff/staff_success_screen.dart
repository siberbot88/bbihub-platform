import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class StaffSuccessScreen extends StatelessWidget {
  final Animation<double> scaleAnimation;

  const StaffSuccessScreen({
    super.key,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('success'),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 160),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Selamat, Staff Anda telah resmi terdaftar di aplikasi.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF232323),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: SvgPicture.asset(
                    'assets/svg/bg-successreg.svg',
                    fit: BoxFit.fitWidth,
                  ),
                ),
                AnimatedBuilder(
                  animation: scaleAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: scaleAnimation.value,
                    child: child,
                  ),
                  child: Image.asset(
                    'assets/image/succes-car.png',
                    height: 250,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        color: Colors.green,
                        size: 96,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Kredensial login staff (username & password) "
              "telah dikirim ke email yang terdaftar.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
