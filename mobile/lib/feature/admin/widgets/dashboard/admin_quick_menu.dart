import 'package:flutter/material.dart';

const Color primaryRed = Color(0xFFDC2626);

/// Admin Quick Menu - matches owner design with red square buttons
class AdminQuickMenu extends StatelessWidget {
  final VoidCallback onTapRiwayat;
  final VoidCallback onTapTerimaJadwal;
  final VoidCallback onTapFeedback;

  const AdminQuickMenu({
    super.key,
    required this.onTapRiwayat,
    required this.onTapTerimaJadwal,
    required this.onTapFeedback,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AdminQuickMenuItem(
          icon: Icons.history_rounded,
          label: 'Riwayat Servis',
          onTap: onTapRiwayat,
        ),
        AdminQuickMenuItem(
          icon: Icons.calendar_today_rounded,
          label: 'Terima Jadwal',
          onTap: onTapTerimaJadwal,
        ),
        AdminQuickMenuItem(
          icon: Icons.chat_bubble_rounded,
          label: 'Umpan Balik',
          onTap: onTapFeedback,
        ),
      ],
    );
  }
}

/// Individual quick menu item - red square button with icon and label
class AdminQuickMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const AdminQuickMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.08),
                blurRadius: 22,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryRed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
