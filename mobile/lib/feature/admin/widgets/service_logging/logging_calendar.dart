import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class LoggingCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const LoggingCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Current visualized month
    final displayedYear = selectedDate.year;
    final displayedMonth = selectedDate.month;
    final daysInMonth = DateUtils.getDaysInMonth(displayedYear, displayedMonth);

    return Column(
      children: [
        // Month Navigation Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(selectedDate),
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 24),
                    onPressed: () {
                      final newDate = DateTime(displayedYear, displayedMonth - 1, 1);
                      onDateSelected(newDate); // Default to 1st of prev month or keep day? 
                      // Better: keep day if possible, or clamp.
                      // For simplicity, let's just go to same day of prev month or clamp
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 24),
                    onPressed: () {
                       final newDate = DateTime(displayedYear, displayedMonth + 1, 1);
                       onDateSelected(newDate);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Days Strip
        SizedBox(
          height: 85,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: daysInMonth,
            itemBuilder: (context, index) {
              final day = index + 1;
              final date = DateTime(displayedYear, displayedMonth, day);
              final isSelected = day == selectedDate.day;
              
              return GestureDetector(
                onTap: () => onDateSelected(date),
                child: Container(
                  width: 60,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFFEAEA) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: isSelected ? const Color(0xFFD92C1C) : Colors.transparent,
                        width: 1.5),
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(date), // Short day name
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, 
                            fontSize: 12,
                            color: isSelected ? const Color(0xFFD92C1C) : Colors.grey[600]
                          )
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$day",
                          style: GoogleFonts.poppins(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            color: isSelected ? const Color(0xFFD92C1C) : Colors.black87
                          )
                        ),
                      ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
