import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'logging_helpers.dart';

class LoggingCalendar extends StatelessWidget {
  final int displayedMonth;
  final int displayedYear;
  final int selectedDay;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final Function(int) onDaySelected;

  const LoggingCalendar({
    super.key,
    required this.displayedMonth,
    required this.displayedYear,
    required this.selectedDay,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final selectedDate = DateTime(displayedYear, displayedMonth, selectedDay);

    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          Text("${LoggingHelpers.monthName(displayedMonth)} $displayedYear",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          const Spacer(),
          IconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: onPrevMonth),
          IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: onNextMonth),
        ]),
      ),
      SizedBox(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: LoggingHelpers.daysInMonth(displayedYear, displayedMonth),
          itemBuilder: (context, index) {
            final day = index + 1;
            final dt = DateTime(displayedYear, displayedMonth, day);
            final isSelected = LoggingHelpers.isSameDate(dt, selectedDate);
            return GestureDetector(
              onTap: () => onDaySelected(day),
              child: Container(
                width: 60,
                margin:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.red[100] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isSelected ? Colors.red : Colors.transparent,
                      width: 2),
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(LoggingHelpers.weekdayShort(dt.weekday),
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 6),
                      Text("$day",
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ]),
              ),
            );
          },
        ),
      ),
    ]);
  }
}
