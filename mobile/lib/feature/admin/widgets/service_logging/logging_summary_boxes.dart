import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoggingSummaryBoxes extends StatelessWidget {
  final int pending;
  final int inProgress;
  final int completed;

  const LoggingSummaryBoxes({
    super.key,
    required this.pending,
    required this.inProgress,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    // Owner Dashboard Style: Gradient Red Background with White Cards
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF510707),
            Color(0xFF9B0D0D),
            Color(0xFFB70F0F),
          ],
          begin: Alignment.topCenter,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB70F0F).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildBox("Pending", pending),
          const SizedBox(width: 8),
          _buildBox("In Progress", inProgress),
          const SizedBox(width: 8),
          _buildBox("Completed", completed),
        ],
      ),
    );
  }

  Widget _buildBox(String label, int count) {
    return Expanded(
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$count",
              style: GoogleFonts.poppins(
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                color: const Color(0xFFB70F0F), // Primary Red
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11, 
                fontWeight: FontWeight.w600, 
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
