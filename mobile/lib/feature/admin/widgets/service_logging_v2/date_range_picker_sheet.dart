import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_colors.dart';

class DateRangePickerSheet extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  
  const DateRangePickerSheet({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<DateRangePickerSheet> createState() => _DateRangePickerSheetState();
}

class _DateRangePickerSheetState extends State<DateRangePickerSheet> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  String _selectedQuickFilter = 'Today';

  @override
  void initState() {
    super.initState();
    _rangeStart = widget.initialStartDate;
    _rangeEnd = widget.initialEndDate;
  }

  void _handleQuickFilter(String filter) {
    final now = DateTime.now();
    setState(() {
      _selectedQuickFilter = filter;
      
      switch (filter) {
        case 'Today':
          _rangeStart = DateTime(now.year, now.month, now.day);
          _rangeEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'Yesterday':
          final yesterday = now.subtract(const Duration(days: 1));
          _rangeStart = DateTime(yesterday.year, yesterday.month, yesterday.day);
          _rangeEnd = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
          break;
        case 'Last 7 Days':
          _rangeStart = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
          _rangeEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'This Month':
          _rangeStart = DateTime(now.year, now.month, 1);
          _rangeEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
          break;
      }
      _focusedDay = _rangeStart ?? now;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Select Date Range',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Quick Select Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: ['Today', 'Yesterday', 'Last 7 Days', 'This Month'].map((filter) {
                final isSelected = _selectedQuickFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) => _handleQuickFilter(filter),
                    selectedColor: AppColors.primaryRed.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primaryRed : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppColors.primaryRed.withOpacity(0.3) : Colors.grey[300]!,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Calendar
          Expanded(
            child: TableCalendar(
              firstDay: DateTime(2023, 1, 1),
              lastDay: DateTime(2030, 12, 31),
              focusedDay: _focusedDay,
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              rangeSelectionMode: RangeSelectionMode.toggledOn,
              calendarFormat: CalendarFormat.month,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                  if (_rangeStart == null || _rangeEnd != null) {
                    _rangeStart = selectedDay;
                    _rangeEnd = null;
                    _selectedQuickFilter = '';
                  } else {
                    if (selectedDay.isBefore(_rangeStart!)) {
                      _rangeEnd = _rangeStart;
                      _rangeStart = selectedDay;
                    } else {
                      _rangeEnd = selectedDay;
                    }
                  }
                });
              },
              calendarStyle: CalendarStyle(
                rangeStartDecoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  shape: BoxShape.circle,
                ),
                rangeEndDecoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  shape: BoxShape.circle,
                ),
                rangeHighlightColor: AppColors.primaryRed.withOpacity(0.1),
                todayDecoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
          ),
          
          // Footer Actions
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'start': _rangeStart,
                        'end': _rangeEnd,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Apply Filter',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
