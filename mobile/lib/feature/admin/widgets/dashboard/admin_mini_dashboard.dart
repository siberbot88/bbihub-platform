import 'package:flutter/material.dart';

/// Admin Mini Dashboard - Exactly matches OwnerMiniDashboard design
/// No icons in summary cards, straight row layout, red gradient background.
class AdminMiniDashboard extends StatefulWidget {
  final String servisHariIni;
  final String perluAssign;
  final String feedback;
  final String selesai;

  const AdminMiniDashboard({
    super.key,
    required this.servisHariIni,
    required this.perluAssign,
    required this.feedback,
    required this.selesai,
  });

  @override
  State<AdminMiniDashboard> createState() => _AdminMiniDashboardState();
}

class _AdminMiniDashboardState extends State<AdminMiniDashboard> {
  int _selectedRange = 0; // 0=Hari ini, 1=Minggu ini, 2=Bulan ini

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
                selected: _selectedRange == 0,
                onTap: () => setState(() => _selectedRange = 0),
              ),
              _RangeTab(
                label: 'Minggu ini',
                selected: _selectedRange == 1,
                onTap: () => setState(() => _selectedRange = 1),
              ),
              _RangeTab(
                label: 'Bulan ini',
                selected: _selectedRange == 2,
                onTap: () => setState(() => _selectedRange = 2),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryCard(
                value: widget.servisHariIni,
                label: 'Servis Hari Ini',
                growth: '-',
              ),
              const SizedBox(width: 8),
              _SummaryCard(
                value: widget.perluAssign,
                label: 'Perlu Assign',
                growth: '-', // Owner dashboard usually has '-' or growth here.
              ),
              const SizedBox(width: 8),
              _SummaryCard(
                value: widget.selesai,
                label: 'Total Selesai',
                growth: '-',
              ),
             // Note: Owner dashboard has 3 cards. Admin has 4 metrics (feedback was the 4th).
             // But to match "Same Design", I should probably stick to 3 cards or fit 4?
             // User Image 1 had 3 cards (Servis, Perlu Assign, Selesai). Feedback was separate row.
             // User Image 2 (Owner) had 3 cards.
             // I will stick to 3 cards in the row to match Owner design exactly.
             // Feedback is omitted from the mini dashboard to maintain visual parity, or I can add it if needed, but "Same Design" implies 3 col.
            ],
          ),
        ],
      ),
    );
  }
}

/// Range tab selector (Matches OwnerMiniDashboard exactly - Button Style)
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
              // Owner code did not explicitly say Poppins, but user requested it earlier.
              // I will use default TextStyle here to be safe and match OwnerMiniDashboard code 1:1.
              // If Owner uses global font, this will pick it up.
            ),
          ),
        ),
      ),
    );
  }
}

/// Summary card (Matches OwnerMiniDashboard exactly - No Icon)
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
                textAlign: TextAlign.center, // Added textAlign center for better alignment
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
