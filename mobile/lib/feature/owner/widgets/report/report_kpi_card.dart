import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportKpiCard extends StatelessWidget {
  final IconData icon;
  final String title; // The large value (Rp 64.7jt)
  final String subtitle; // e.g., "Pendapatan bulan ini"
  final String growthText; // "+12.5%"
  final VoidCallback onTap;
  final Color? iconBgColor; // Optional custom color for icon bg
  final Color? iconColor;
  final double iconSize;

  const ReportKpiCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.growthText,
    required this.onTap,
    this.iconBgColor,
    this.iconColor,
    this.iconSize = 24, // Increased default from 18
  });

  @override
  Widget build(BuildContext context) {
    // Check if growth is positive or negative for color
    final bool isPositive = !growthText.contains('−') && !growthText.contains('-');
    final Color badgeColor = isPositive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final Color badgeText = isPositive ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icon + Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10), // Increased from 8
                    decoration: BoxDecoration(
                      color: iconBgColor ?? const Color(0xFFFFF0F1), // Default soft red
                      borderRadius: BorderRadius.circular(12), // Changed from circle to rounded rect for better look with larger icons? Or stick to circle. User said "agak di besarkan". Let's stick to circle but larger.
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: iconSize,
                      color: iconColor ?? const Color(0xFFE53935), // Default primary red
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      growthText,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: badgeText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Value
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18, // Slightly smaller to fit grid
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF212121),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              // Subtitle
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF757575),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
