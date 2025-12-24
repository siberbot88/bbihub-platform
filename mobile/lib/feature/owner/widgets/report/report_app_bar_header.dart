import 'package:flutter/material.dart';
import 'report_data.dart';
import 'report_helpers.dart';

const Color kRedStart = Color(0xFF9B0D0D);
const Color kRedEnd = Color(0xFFB70F0F);

class ReportAppBarHeader extends StatelessWidget {
  final TimeRange selectedRange;
  final Function(TimeRange) onRangeChanged;

  const ReportAppBarHeader({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kRedStart, kRedEnd],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              const Text(
                'Laporan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Dashboard Analitik',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  ReportRangeChip(
                    text: 'Harian',
                    selected: selectedRange == TimeRange.daily,
                    onTap: () => onRangeChanged(TimeRange.daily),
                  ),
                  const SizedBox(width: 12),
                  ReportRangeChip(
                    text: 'Mingguan',
                    selected: selectedRange == TimeRange.weekly,
                    onTap: () => onRangeChanged(TimeRange.weekly),
                  ),
                  const SizedBox(width: 12),
                  ReportRangeChip(
                    text: 'Bulanan',
                    selected: selectedRange == TimeRange.monthly,
                    highlight: true,
                    onTap: () => onRangeChanged(TimeRange.monthly),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
