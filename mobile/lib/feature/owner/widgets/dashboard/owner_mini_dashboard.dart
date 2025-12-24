import 'package:flutter/material.dart';

import 'dashboard_helpers.dart';

/// Mini dashboard widget with summary stats and range selector
class OwnerMiniDashboard extends StatelessWidget {
  final SummaryRange range;
  final ValueChanged<SummaryRange> onRangeChanged;
  final num pendapatan;
  final int totalJob;
  final int totalSelesai;

  const OwnerMiniDashboard({
    super.key,
    required this.range,
    required this.onRangeChanged,
    required this.pendapatan,
    required this.totalJob,
    required this.totalSelesai,
  });

  @override
  Widget build(BuildContext context) {
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF510707),
            Color(0xFF9B0D0D),
            Color(0xFFB70F0F),
          ],
          begin: Alignment.topCenter,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _RangeTab(
                label: 'Hari ini',
                selected: range == SummaryRange.today,
                onTap: () => onRangeChanged(SummaryRange.today),
              ),
              _RangeTab(
                label: 'Minggu ini',
                selected: range == SummaryRange.week,
                onTap: () => onRangeChanged(SummaryRange.week),
              ),
              _RangeTab(
                label: 'Bulan ini',
                selected: range == SummaryRange.month,
                onTap: () => onRangeChanged(SummaryRange.month),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryCard(
                value: 'Rp ${rupiah(pendapatan)}',
                label: 'Pendapatan',
                growth: '-',
              ),
              const SizedBox(width: 8),
              _SummaryCard(
                value: '$totalJob',
                label: 'Total job',
                growth: '-',
              ),
              const SizedBox(width: 8),
              _SummaryCard(
                value: '$totalSelesai',
                label: 'Total Selesai',
                growth: '-',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Range tab selector (Today/Week/Month)
class _RangeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RangeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryRed = Color(0xFFB70F0F);
    final bg = selected ? Colors.white : const Color(0xFF9B0D0D);
    final fg = selected ? primaryRed : Colors.white;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// Summary card showing metric value, label, and growth
class _SummaryCard extends StatelessWidget {
  final String value, label, growth;

  const _SummaryCard({
    required this.value,
    required this.label,
    required this.growth,
  });

  @override
  Widget build(BuildContext context) {
    const primaryRed = Color(0xFFB70F0F);
    
    return Expanded(
      child: SizedBox(
        height: 100,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryRed,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                growth.isNotEmpty ? growth : '-',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
