import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/staff_performance.dart';
import 'staff_performance_screen.dart' show AppTheme;

class StaffPerformanceDetailScreen extends StatelessWidget {
  final StaffPerformance staff;

  const StaffPerformanceDetailScreen({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Slightly off-white background
      appBar: AppBar(
        backgroundColor: AppTheme.primaryRed,
        title: Text(
          'Detail Kinerja Staff',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Profile Header
            _buildProfileHeader(),

            // 2. Main Stats Grid
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Statistik Utama', style: AppTheme.sectionTitle),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildInfoCard('Total Job', '${staff.jobsDone}', Icons.work_outline, Colors.blue)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildInfoCard('Pendapatan', _formatRupiah(staff.estimatedRevenue), Icons.attach_money, Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildInfoCard('Rating', '4.9/5.0', Icons.star_border, Colors.orange)), // Dummy rating
                      const SizedBox(width: 12),
                      Expanded(child: _buildInfoCard('Tepat Waktu', '95%', Icons.timer_outlined, Colors.purple)), // Dummy on-time rate
                    ],
                  ),
                ],
              ),
            ),

            const Divider(thickness: 1, height: 32),

            // 3. Recent Activity (Placeholder)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Riwayat Pekerjaan', style: AppTheme.sectionTitle),
                  const SizedBox(height: 12),
                  _buildEmptyActivity(),
                ],
              ),
            ),
             const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 32, top: 20),
      decoration: const BoxDecoration(
        color: AppTheme.primaryRed,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Hero(
            tag: 'avatar_${staff.staffId}',
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                backgroundImage: (staff.avatarUrl.isNotEmpty && !staff.avatarUrl.contains('ui-avatars'))
                    ? NetworkImage(staff.avatarUrl)
                    : null,
                child: (staff.avatarUrl.isEmpty || staff.avatarUrl.contains('ui-avatars'))
                    ? Text(
                        _getInitials(staff.name),
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryRed,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            staff.name,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              staff.roleDisplayName,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivity() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(Icons.history_edu, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'Belum ada riwayat pekerjaan terbaru',
            style: GoogleFonts.poppins(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  
  String _formatRupiah(int amount) {
    final str = amount.toString().split('').reversed.join();
    String result = '';
    for (int i = 0; i < str.length; i++) {
        if (i % 3 == 0 && i != 0) result += '.';
        result += str[i];
    }
    return 'Rp ${result.split('').reversed.join()}';
  }
}
