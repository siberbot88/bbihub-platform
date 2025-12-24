// 📄 lib/feature/admin/screens/tabs/technician_tab.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TechnicianTab extends StatelessWidget {
  final String selectedRange; // ex: "Hari ini" / "Today"
  final ValueChanged<String> onRangeChange;

  const TechnicianTab({
    super.key,
    required this.selectedRange,
    required this.onRangeChange,
  });

  static const _cardRadius = 16.0;

  @override
  Widget build(BuildContext context) {
    // dummy data persis seperti layout
    final techs = <_Tech>[
      _Tech(
        name: 'James Hariyanto',
        id: 'T0001',
        role: 'Senior Technician',
        rating: 4.9,
        jobsToday: 18,
        avgHours: 2.5,
        avatar:
            'https://i.pravatar.cc/150?img=12', // ganti ke assets jika perlu
      ),
      _Tech(
        name: 'Nanda Santoso',
        id: 'T0001',
        role: 'Lead Technician',
        rating: 4.5,
        jobsToday: 15,
        avgHours: 1.9,
        avatar: 'https://i.pravatar.cc/150?img=32',
      ),
      _Tech(
        name: 'Dimas Doniansyah',
        id: 'T0001',
        role: 'Junior Technician',
        rating: 4.2,
        jobsToday: 10,
        avgHours: 1.7,
        avatar: 'https://i.pravatar.cc/150?img=14',
      ),
      _Tech(
        name: 'Sandy Kanara',
        id: 'T0001',
        role: 'Senior Technician',
        rating: 5.0,
        jobsToday: 9,
        avgHours: 2.8,
        avatar: 'https://i.pravatar.cc/150?img=57',
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title + pill dropdown + link kanan
          Row(
            children: [
              Expanded(
                child: Text(
                  'Performa Mekanik',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              _rangePill(context),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {},
              child: Text(
                'Lihat Semua',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  color: Colors.black87,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // list cards
          ...techs
              .map((t) => _techCard(t))
              .expand((w) => [w, const SizedBox(height: 12)]),
        ],
      ),
    );
  }

  // ---------- Widgets ----------
  Widget _rangePill(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 6),
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626), // Merah sesuai desain
        borderRadius: BorderRadius.circular(24), // Bentuk pill
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: 'Hari ini', // Pilihan default sesuai gambar
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          dropdownColor: Colors.white, // Warna dropdown tetap merah
          style: GoogleFonts.poppins(
              color: Colors.white, fontSize: 13), // Teks putih di tombol
          items: const ['Hari ini', 'Minggu ini', 'Bulan ini']
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: GoogleFonts.poppins(
                          color: Colors.black), // Teks item dropdown putih
                    ),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) {
              // Memanggil fungsi onRangeChange untuk update
              onRangeChange(v);
            }
          },
        ),
      ),
    );
  }

  Widget _techCard(_Tech t) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        children: [
          // row atas: avatar + nama / id / role + jobs today di kanan
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(t.avatar),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                            color: Colors.black87, fontSize: 13.5),
                        children: [
                          TextSpan(
                              text: t.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                          TextSpan(
                              text: '\nID:${t.id} ${t.role}',
                              style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStars(t.rating),
                        const SizedBox(width: 8),
                        Text('${t.rating} Rating',
                            style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${t.jobsToday}',
                      style: GoogleFonts.poppins(
                          color: const Color(0xFFDC2626),
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                  Text('Jobs Today',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // bottom right: avg time + arrow up
          Row(
            children: [
              const Spacer(),
              Icon(Icons.arrow_upward,
                  size: 14, color: const Color(0xFF16A34A)),
              const SizedBox(width: 4),
              Text(
                'Avg: ${t.avgHours}h per service',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF16A34A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStars(double rating) {
    // bikin baris bintang 5 sesuai screenshot
    final full = rating.floor();
    final half = (rating - full) >= 0.25 && (rating - full) < 0.75;
    final total = 5;

    final stars = <Widget>[];
    for (int i = 0; i < full; i++) {
      stars.add(const Icon(Icons.star, size: 18, color: Color(0xFFFFB300)));
    }
    if (half) {
      stars
          .add(const Icon(Icons.star_half, size: 18, color: Color(0xFFFFB300)));
    }
    while (stars.length < total) {
      stars.add(
          const Icon(Icons.star_border, size: 18, color: Color(0xFFFFB300)));
    }
    return Row(children: stars);
  }
}

class _Tech {
  final String name;
  final String id;
  final String role;
  final double rating;
  final int jobsToday;
  final double avgHours;
  final String avatar;

  const _Tech({
    required this.name,
    required this.id,
    required this.role,
    required this.rating,
    required this.jobsToday,
    required this.avgHours,
    required this.avatar,
  });
}
