// 📄 lib/feature/admin/screens/tabs/technician_tab.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_service_provider.dart';

class TechnicianTab extends StatefulWidget {
  final String selectedRange; // ex: "Hari ini" / "Today"
  final ValueChanged<String> onRangeChange;

  const TechnicianTab({
    super.key,
    required this.selectedRange,
    required this.onRangeChange,
  });

  @override
  State<TechnicianTab> createState() => _TechnicianTabState();
}

class _TechnicianTabState extends State<TechnicianTab> {
  static const _cardRadius = 16.0;
  List<Map<String, dynamic>> _mechanics = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didUpdateWidget(covariant TechnicianTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedRange != widget.selectedRange) {
      _fetchData();
    }
  }

  String _mapRangeToApi(String uiRange) {
    if (uiRange == 'Minggu ini') return 'week';
    if (uiRange == 'Bulan ini') return 'month';
    return 'today';
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final range = _mapRangeToApi(widget.selectedRange);
    final data = await context
        .read<AdminServiceProvider>()
        .fetchMechanicPerformance(range: range);
    if (mounted) {
      setState(() {
        _mechanics = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title + pill dropdown
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
              onTap: _fetchData,
              child: Text(
                'Segarkan', // Refresh
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

          if (_isLoading)
            const Center(child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ))
          else if (_mechanics.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Belum ada data performa.',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
            )
          else
            // list cards
            ..._mechanics
                .map((m) => _techCard(m))
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
          value: widget.selectedRange,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          dropdownColor: Colors.white,
          style: GoogleFonts.poppins(
              color: Colors.black, fontSize: 13), // Black text in dropdown
          selectedItemBuilder: (BuildContext context) {
            return ['Hari ini', 'Minggu ini', 'Bulan ini'].map((String value) {
              return Center(
                child: Text(
                  value,
                  style: GoogleFonts.poppins(color: Colors.white), // White in button
                ),
              );
            }).toList();
          },
          items: const ['Hari ini', 'Minggu ini', 'Bulan ini']
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) {
              widget.onRangeChange(v);
            }
          },
        ),
      ),
    );
  }

  Widget _techCard(Map<String, dynamic> data) {
    final name = data['name'] ?? '-';
    final id = data['display_id'] ?? 'ID';
    final role = data['role'] ?? 'Technician';
    final jobs = data['jobs_today'] ?? 0;
    final avgHours = (data['avg_hours'] as num?)?.toDouble() ?? 0.0;
    
    // Avatar logic
    final avatarUrl = data['avatar'];
    final bool hasAvatar = avatarUrl != null && 
                          avatarUrl.toString().isNotEmpty && 
                          !avatarUrl.toString().contains('ui-avatars.com');

    String jobsLabel = 'Jobs Today';
    if (widget.selectedRange == 'Minggu ini') jobsLabel = 'Jobs This Week';
    if (widget.selectedRange == 'Bulan ini') jobsLabel = 'Jobs This Month';
    
    // Initials generator
    String initials = '';
    if (name.isNotEmpty) {
      final parts = name.split(' ');
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        initials = '${name[0]}${name.length > 1 ? name[1] : ''}'.toUpperCase();
      }
    }

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFFEE2E2), // Light Red
            backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
            onBackgroundImageError: hasAvatar ? (_, __) {} : null,
            child: !hasAvatar
                ? Text(
                    initials,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFDC2626), // Primary Red
                      fontSize: 16,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          
          // Info (Name, Role, Avg Time)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$id • $role',
                  style: GoogleFonts.poppins(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                // Avg Time (Replaces Rating)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5), // Light Green
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, 
                        size: 14, color: Color(0xFF059669)
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Avg: ${avgHours}h / service',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF059669), // Green
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Jobs Count
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$jobs',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFDC2626),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                jobsLabel,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.black45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
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
