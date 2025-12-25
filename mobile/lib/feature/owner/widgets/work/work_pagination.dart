import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _primaryRed = Color(0xFFD72B1C);

class WorkPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool loading;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const WorkPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.loading,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canGoPrev = currentPage > 1 && !loading;
    final canGoNext = currentPage < totalPages && !loading;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous Button
        IconButton(
          onPressed: canGoPrev ? onPrev : null,
          style: IconButton.styleFrom(
            backgroundColor: isDark 
                ? const Color(0xFF374151)
                : const Color(0xFFF3F4F6),
            disabledBackgroundColor: isDark
                ? const Color(0xFF374151).withValues(alpha: 0.5)
                : const Color(0xFFF3F4F6).withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            fixedSize: const Size(40, 40),
          ),
          icon: Icon(
            Icons.chevron_left,
            color: canGoPrev
                ? (isDark ? const Color(0xFF9dabb9) : const Color(0xFF6B7280))
                : (isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB)),
          ),
        ),

        // Page Info
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Page ',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark 
                      ? const Color(0xFF9dabb9)
                      : const Color(0xFF6B7280),
                ),
              ),
              TextSpan(
                text: '$currentPage',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              TextSpan(
                text: ' of ',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark 
                      ? const Color(0xFF9dabb9)
                      : const Color(0xFF6B7280),
                ),
              ),
              TextSpan(
                text: '$totalPages',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),

        // Next Button
        IconButton(
          onPressed: canGoNext ? onNext : null,
          style: IconButton.styleFrom(
            backgroundColor: canGoNext 
                ? _primaryRed 
                : (isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
            disabledBackgroundColor: isDark
                ? const Color(0xFF374151).withValues(alpha: 0.5)
                : const Color(0xFFF3F4F6).withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            fixedSize: const Size(40, 40),
          ),
          icon: Icon(
            Icons.chevron_right,
            color: canGoNext
                ? Colors.white
                : (isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB)),
          ),
        ),
      ],
    );
  }
}
