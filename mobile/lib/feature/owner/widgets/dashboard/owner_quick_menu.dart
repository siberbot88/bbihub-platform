import 'package:flutter/material.dart';

/// Quick menu row with action buttons for owner dashboard
class OwnerQuickMenuRow extends StatelessWidget {
  final VoidCallback onTapPekerjaan;
  final VoidCallback onTapKaryawan;
  final VoidCallback onTapLaporan;

  const OwnerQuickMenuRow({
    super.key,
    required this.onTapPekerjaan,
    required this.onTapKaryawan,
    required this.onTapLaporan,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OwnerQuickMenuItem(
          icon: Icons.build,
          label: 'Pekerjaan',
          onTap: onTapPekerjaan,
        ),
        OwnerQuickMenuItem(
          icon: Icons.people,
          label: 'Karyawan',
          onTap: onTapKaryawan,
        ),
        OwnerQuickMenuItem(
          icon: Icons.pie_chart,
          label: 'Laporan',
          onTap: onTapLaporan,
        ),
      ],
    );
  }
}

/// Individual quick menu item button
class OwnerQuickMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const OwnerQuickMenuItem({
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
                  color: const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
