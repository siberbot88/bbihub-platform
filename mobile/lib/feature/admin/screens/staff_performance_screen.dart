import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/staff_performance.dart';
import '../repositories/staff_performance_repository.dart';

// --- Date Range Enum ---
enum DateRange { today, week, month }

// --- App Theme Constants (Local for portability) ---
class AppTheme {
  static const Color primaryRed = Color(0xFFE53935);
  static const Color primaryRedDark = Color(0xFFD32F2F); 
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
  const StaffPerformanceScreen({super.key});

  @override
  State<StaffPerformanceScreen> createState() => _StaffPerformanceScreenState();
}

class _StaffPerformanceScreenState extends State<StaffPerformanceScreen> {
  DateRange _selectedRange = DateRange.today;
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


  // Reload when tab changes
  void _onRangeChanged(DateRange range) {
    if (_selectedRange != range) {
      setState(() {
        _selectedRange = range;
      });
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.primaryRed,
        elevation: 4,
        child: const Icon(Icons.add_rounded, size: 32),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Belum ada data staff',
              style: AppTheme.sectionTitle.copyWith(color: AppTheme.textSecondary),
            ),
          ],
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
              _buildCircleButton(
                icon: Icons.more_horiz_rounded, 
                onTap: () {}
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
            Text('${_staffList.length} Staff Aktif', style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
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
            // Navigate to Detail
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
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: NetworkImage(staff.avatarUrl),
                          onBackgroundImageError: (_, __) {},
                          child: const Icon(Icons.person, color: Colors.grey),
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
}
