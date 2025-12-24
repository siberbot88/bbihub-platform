import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _primaryRed = Color(0xFFD72B1C);

class WorkSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onFilterTap;
  final bool hasActiveFilter;
  final Function(String) onChanged;

  const WorkSearchBar({
    super.key,
    required this.controller,
    required this.onFilterTap,
    required this.hasActiveFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1c2630) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Icon(
              Icons.search,
              size: 24,
              color: const Color(0xFF9dabb9),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Cari kendaraan, customer, atau plat',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF9dabb9),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              onChanged: onChanged,
            ),
          ),
          if (hasActiveFilter)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: _primaryRed,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
