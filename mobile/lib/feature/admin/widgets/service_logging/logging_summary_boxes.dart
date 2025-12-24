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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        _buildBox("Pending", pending, Colors.blue),
        _buildBox("In Progress", inProgress, Colors.orange),
        _buildBox("Completed", completed, Colors.green),
      ]),
    );
  }

  Widget _buildBox(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: color.withAlpha(153), width: 1.5), // 0.6 * 255
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 4) // 0.02 * 255
          ],
        ),
        child: Column(
          children: [
            Text("$count",
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 6),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
