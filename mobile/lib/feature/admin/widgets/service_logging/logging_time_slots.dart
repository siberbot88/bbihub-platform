import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoggingTimeSlots extends StatelessWidget {
  final List<Map<String, dynamic>> timeSlots;
  final String? selectedTimeSlot;
  final Function(String?) onTimeSlotSelected;

  const LoggingTimeSlots({
    super.key,
    required this.timeSlots,
    required this.selectedTimeSlot,
    required this.onTimeSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13), // 0.05 * 255
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Waktu tersedia",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...timeSlots.map((slot) => _TimeSlotCard(
                  slot: slot,
                  isSelected: selectedTimeSlot == slot['time'],
                  onTap: () {
                    if (selectedTimeSlot == slot['time']) {
                      onTimeSlotSelected(null);
                    } else {
                      onTimeSlotSelected(slot['time'] as String);
                    }
                  },
                )),
          ],
        ),
      ),
    );
  }
}

class _TimeSlotCard extends StatelessWidget {
  final Map<String, dynamic> slot;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeSlotCard({
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String status = slot['status'];
    Color dotColor, statusColor, bgColor, borderColor;

    switch (status) {
      case 'Aktif':
        dotColor = const Color(0xFF007BFF);
        statusColor = const Color(0xFF007BFF);
        bgColor = isSelected
            ? const Color(0xFF007BFF).withAlpha(51) // 0.2 * 255
            : const Color(0xFF007BFF).withAlpha(26); // 0.1 * 255
        break;
      case 'Akan Datang':
        dotColor = Colors.orange;
        statusColor = Colors.orange;
        bgColor = isSelected ? Colors.orange.withAlpha(51) : Colors.grey.shade100;
        break;
      case 'Penjadwalaan':
      default:
        dotColor = Colors.grey.shade600;
        statusColor = Colors.black87;
        bgColor = isSelected ? Colors.grey.shade300 : Colors.grey.shade100;
        break;
    }

    borderColor = isSelected ? dotColor : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot['time'],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "${slot['tasks']} tasks scheduled",
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              status,
              style: GoogleFonts.poppins(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            )
          ],
        ),
      ),
    );
  }
}
