import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/staff_performance.dart';
// import 'dart:math' as math; // Unused
import '../../admin/repositories/staff_performance_repository.dart'; // Point to existing repo
import 'package:provider/provider.dart';
import '../../../core/services/auth_provider.dart';
import '../../../core/widgets/premium_feature_lock.dart';
import 'staff_performance_detail_screen.dart';

// --- App Theme Constants (Local for portability) ---
class AppTheme {
  static const Color primaryRed = Color(0xFFB70F0F); // Darker red to match Staff Management
  static const Color primaryRedDark = Color(0xFF9B0D0D); // Even darker for gradient 
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  
  static const Color successBg = Color(0xFFE8F5E9);
  static const Color successText = Color(0xFF388E3C); // Darker green for text
  static const Color progressBg = Color(0xFFFFF3E0);
  static const Color progressText = Color(0xFFF57C00); // Darker orange
  
  static const Color revenueBg = Color(0xFFFFEBEE);
  static const Color revenueText = primaryRed;

  static TextStyle get headingTitle => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle get headingSubtitle => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white.withValues(alpha: 0.9),
  );

  static TextStyle get sectionTitle => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static TextStyle get staffName => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static TextStyle get staffRole => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static TextStyle get statLabel => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    letterSpacing: 0.5,
  );

  static TextStyle get statValue => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static TextStyle get revenueLabel => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static TextStyle get revenueValue => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: primaryRed,
  );
}

class StaffPerformanceScreen extends StatefulWidget {
  const StaffPerformanceScreen({Key? key}) : super(key: key);

  @override
  State<StaffPerformanceScreen> createState() => _StaffPerformanceScreenState();
}

class _StaffPerformanceScreenState extends State<StaffPerformanceScreen> {
  DateRange _selectedRange = DateRange.today; // Ensure DateRange is accessible
  final StaffPerformanceRepository _repository = StaffPerformanceRepository();
  
  List<StaffPerformance> _staffList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final rangeStr = _selectedRange.name; // 'today', 'week', 'month'
      final data = await _repository.getStaffPerformance(range: rangeStr);
      if (mounted) {
        setState(() {
          _staffList = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    // 0. Check Premium Locked
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isPremium = auth.user?.isPremium ?? false;

    if (!isPremium) {
       return Scaffold(
         backgroundColor: AppTheme.background,
         appBar: AppBar(
            title: Text('Kinerja Staff', style: AppTheme.headingTitle.copyWith(fontSize: 20)),
             backgroundColor: AppTheme.primaryRed,
             elevation: 0,
         ),
         body: const PremiumFeatureLock(
           featureName: 'Kinerja Staff',
           featureDescription: 'Pantau performa mekanik, jumlah pekerjaan, dan estimasi pendapatan mereka secara real-time.',
           child: Center(child: Icon(Icons.people_outline, size: 80, color: Colors.black12)),
         ),
       );
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryRed, 
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Header & Segmented Control
            _buildHeader(),

            // 2. White "Sheet" Content
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: _buildBody(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data',
              style: AppTheme.sectionTitle.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: AppTheme.staffRole,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_staffList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.people_outline_rounded,
                  size: 64,
                  color: AppTheme.primaryRed,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Belum Ada Data Kinerja',
                style: AppTheme.sectionTitle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 12),
              Text(
                'Anda belum memiliki staff atau belum ada aktivitas.\nTambahkan staff di menu Kelola Staff untuk melihat kinerja mereka.',
                style: AppTheme.staffRole.copyWith(height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryRed,
                  side: const BorderSide(color: AppTheme.primaryRed),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      color: AppTheme.primaryRed,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // Overview Section Header
          _buildOverviewHeader(),
          const SizedBox(height: 16),

          // Staff List
          ..._staffList.map((staff) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: StaffPerformanceCard(staff: staff),
          )),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryRed, AppTheme.primaryRedDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Bar Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCircleButton(
                icon: Icons.chevron_left_rounded, 
                onTap: () => Navigator.maybePop(context)
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Title
          Center(
            child: Column(
              children: [
                Text('Kinerja Staff', style: AppTheme.headingTitle),
                const SizedBox(height: 4),
                Text('Pantau performa tim Anda', style: AppTheme.headingSubtitle),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Segmented Control
          Container(
            height: 48,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2), // Dark transparent background
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                _buildSegmentTab('Hari ini', DateRange.today),
                _buildSegmentTab('Minggu', DateRange.week),
                _buildSegmentTab('Bulan', DateRange.month),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overview Tim', style: AppTheme.sectionTitle),
            // Text('${_staffList.length} Staff Aktif', style: AppTheme.textSecondary.hasColor ? GoogleFonts.poppins(color: AppTheme.textSecondary) : null), // Fix color null safety if needed
             Text('${_staffList.length} Staff Aktif', style: AppTheme.staffRole),
          ],
        ),
        TextButton.icon(
          onPressed: () {
            // Placeholder: Show filter modal
          },
          style: TextButton.styleFrom(
            backgroundColor: AppTheme.revenueBg,
            foregroundColor: AppTheme.primaryRed,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          icon: const Icon(Icons.filter_list_rounded, size: 18),
          label: Text('Filter', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        )
      ],
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildSegmentTab(String label, DateRange range) {
    final bool isSelected = _selectedRange == range;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRange = range),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected ? [
              BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
              ) 
            ] : [],
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? AppTheme.primaryRed : Colors.white.withValues(alpha: 0.8),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

// Ensure DateRange enum is available if not filtered from repo import
// Assuming DateRange is in repository file or needs to be defined
enum DateRange { today, week, month }

class StaffPerformanceCard extends StatelessWidget {
  final StaffPerformance staff;

  const StaffPerformanceCard({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 15,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StaffPerformanceDetailScreen(staff: staff),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Top Row: Avatar + Info
                    Row(
                      children: [
                        Hero(
                          tag: 'avatar_${staff.staffId}',
                          child: _buildAvatar(staff.name, staff.avatarUrl),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(staff.name, style: AppTheme.staffName),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  staff.roleDisplayName,
                                  style: AppTheme.staffRole,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Stats Row
                    Row(
                      children: [
                        _buildStatCard(
                          context,
                          label: 'SELESAI',
                          value: '${staff.jobsDone} Jobs',
                          icon: Icons.check_circle_rounded,
                          bgColor: AppTheme.successBg,
                          textColor: AppTheme.successText,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          context,
                          label: 'PROSES',
                          value: '${staff.jobsInProgress} ${staff.jobsInProgress == 1 ? 'Job' : 'Jobs'}',
                          icon: Icons.timelapse_rounded,
                          bgColor: AppTheme.progressBg,
                          textColor: AppTheme.progressText,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bottom Revenue Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFFAFAFA), // Slightly different from white
                  border: Border(
                    top: BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Estimasi Pendapatan', style: AppTheme.revenueLabel),
                    Text(
                      _formatRupiah(staff.estimatedRevenue),
                      style: AppTheme.revenueValue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: textColor.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: textColor),
                const SizedBox(width: 6),
                Text(label, style: AppTheme.statLabel.copyWith(color: textColor)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: AppTheme.statValue.copyWith(color: Color(0xFF2C2C2C))),
          ],
        ),
      ),
    );
  }

  String _formatRupiah(int amount) {
    // Simple formatter without dependence on intl
    final str = amount.toString().split('').reversed.join();
    String result = '';
    for (int i = 0; i < str.length; i++) {
        if (i % 3 == 0 && i != 0) result += '.';
        result += str[i];
    }
    return 'Rp ${result.split('').reversed.join()}';
  }

  Widget _buildAvatar(String name, String url) {
    // Logic: Use initials if URL is empty or is a default placeholder
    // If you have a specific way to detect valid URLs vs default avatars, use it here.
    // For now, let's assume if it fails to load or empty, we use initials.
    
    // Helper to get initials
    String getInitials(String n) {
      final parts = n.trim().split(' ');
      if (parts.isEmpty) return '';
      if (parts.length == 1) return parts[0][0].toUpperCase();
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    final hasValidUrl = url.isNotEmpty && !url.contains('ui-avatars.com');

    return CircleAvatar(
      radius: 26,
      backgroundColor: AppTheme.primaryRed.withOpacity(0.1),
      backgroundImage: hasValidUrl ? NetworkImage(url) : null,
      onBackgroundImageError: hasValidUrl ? (_, __) {} : null, // Fix: Only provide handler if image is present
      child: !hasValidUrl 
          ? Text(
              getInitials(name),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryRed,
                fontSize: 18,
              ),
            )
          : null, // Image covers child if valid
    );
  }
}
