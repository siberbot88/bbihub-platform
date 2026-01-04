import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/report/report_charts.dart';
import '../widgets/report/report_data.dart';
import '../widgets/report/report_health_matrix.dart';
import '../widgets/report/report_kpi_card.dart';
import '../../../core/services/report_pdf_service.dart';
import '../../../core/repositories/analytics_repository.dart';
import '../../../core/widgets/premium_feature_lock.dart';
import '../../../core/services/auth_provider.dart';
import 'package:provider/provider.dart';

// --- Colors ---
const Color kPrimaryRed = Color(0xFFB70F0F); // Darker red to match Staff Management
const Color kPrimaryRedDark = Color(0xFF9B0D0D); // Even darker for gradient
const Color kBackground = Color(0xFFF5F5F5); // Light Gray Background

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String _periodType = 'monthly'; // 'monthly' or 'yearly'
  DateTime _selectedDate = DateTime.now();
  ReportData? _data;
  bool _isLoading = true;
  final _analyticsRepo = AnalyticsRepository();
  
  // Check if user has premium membership (using robust getter)
  bool get _isPremium {
    final auth = context.read<AuthProvider>();
    return auth.user?.isPremium ?? false;
  }

  @override
  void initState() {
    super.initState();
    // Use light status bar icons when on red header
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _loadAnalytics();
  }

  @override
  void dispose() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    // 1. Cek premium access sebelum fetch
    if (!_isPremium) {
      setState(() {
        _isLoading = false;
        _data = null; 
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dateString = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
      
      final data = await _analyticsRepo.getAnalyticsWithAuth(periodType: _periodType, date: dateString);
      
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _data = null;
      });

      // Force refresh login status if we hit a permission error (stale state)
      if (e.toString().contains('403') || e.toString().contains('Unauthorized')) {
         context.read<AuthProvider>().checkLoginStatus();
      }
      
      // Suppress 403 errors (Premium access required)
      if (e.toString().contains('403')) {
        return;
      }
      
      // Show error snackbar for other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data: ${e.toString()}'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Coba Lagi',
            textColor: Colors.white,
            onPressed: _loadAnalytics,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to AuthProvider changes
    final auth = context.watch<AuthProvider>();
    final isPremium = auth.user?.isPremium ?? false;

    // Auto-fetch if we just became premium and have no data
    if (isPremium && _data == null && !_isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadAnalytics();
      });
    }

    // 1. Check Premium Lock first
    if (!isPremium) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Laporan',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: kPrimaryRed,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        body: const PremiumFeatureLock(
           featureName: 'Laporan & Analitik',
           featureDescription: 'Dapatkan wawasan bisnis mendalam, grafik tren pendapatan, dan efisiensi bengkel dengan BBI HUB Premium.',
           child: Center(child: Icon(Icons.analytics_outlined, size: 80, color: Colors.black12)),
        ),
      );
    }

    // 2. Loading State
    if (_isLoading) {
      return Scaffold(
        backgroundColor: kPrimaryRed,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: kBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(kPrimaryRed),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 3. Error / Empty State (Safety fallback)
    if (_data == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Laporan'), backgroundColor: kPrimaryRed),
          body: const Center(child: Text("Gagal memuat data.")),
        );
    }

    final d = _data!;
    debugPrint('ReportPage: forecastRevenue length: ${d.forecastRevenue.length}');
    debugPrint('ReportPage: forecastRevenue: ${d.forecastRevenue}');
    
    return Scaffold(
      backgroundColor: kPrimaryRed, // Background fallback
      body: Column( // Removed SafeArea to let Header go behind status bar
        children: [
          // 1. Header (Gradient + Segmented Control)
          _buildHeader(context),

          // 2. Scrollable Body
          Expanded(
            child: Container(
              width: double.infinity,
                decoration: const BoxDecoration(
                  color: kBackground,
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
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    physics: const BouncingScrollPhysics(),
                    children: [
                            // KPI GRid
                            _buildKpiSection(d),
                            const SizedBox(height: 24),

                            // Trend Chart
                            _buildTrendChart(d),
                            const SizedBox(height: 20),

                            // FORECAST CHART
                            // Always show if we have forecast data (even if all zeros)
                            // This ensures historical periods show a flat line instead of hiding
                            if (d.forecastRevenue.isNotEmpty) ...[
                              _buildForecastChart(d),
                              const SizedBox(height: 20),
                            ],

                            // TOP TECHNICIANS
                            if (d.topMechanics.isNotEmpty) ...[
                              _buildTechnicianLeaderboard(d),
                              const SizedBox(height: 20),
                            ],

                            // Breakdown & Queue
                            _buildBreakdownRow(d),
                            const SizedBox(height: 20),

                            // Peak Hour
                            _buildPeakHour(d),
                            const SizedBox(height: 20),

                      // Operational Health
                      ReportHealthMatrix(
                        avgQueue: '${d.avgQueue} kendaraan',
                        occupancy: '${d.occupancy}%',
                        peakRange: d.peakRange,
                        efficiency: '${d.efficiency}%',
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // CTA Button (now at bottom of scrollable content)
                      _buildCtaButton(),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }

  // --- Header Section ---
  Widget _buildHeader(BuildContext context) {
    final bool canPop = Navigator.of(context).canPop();
    final double topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 10, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryRed, kPrimaryRedDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Nav Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              canPop 
                  ? _buildCircleButton(
                      icon: Icons.chevron_left_rounded,
                      onTap: () => Navigator.maybePop(context),
                    )
                  : const SizedBox(width: 44, height: 44),
              const SizedBox(width: 44, height: 44), 
            ],
          ),
          const SizedBox(height: 16),
          
          // Title
          Center(
            child: Column(
              children: [
                 Text(
                  'Laporan',
                  style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dashboard Analitik',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // --- NEW FILTER CONTROLS ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                // 1. Period Type Toggle (Bulanan | Tahunan)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPeriodToggle('Bulanan', 'monthly'),
                    const SizedBox(width: 12),
                    _buildPeriodToggle('Tahunan', 'yearly'),
                  ],
                ),
                const Divider(color: Colors.white24, height: 24),
                
                // 2. Date Navigation (< Jan 2025 >)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
                      onPressed: _prevDate,
                    ),
                    Text(
                      _formatDateFilter(),
                      style: GoogleFonts.poppins(
                        fontSize: 16, 
                        fontWeight: FontWeight.w600, 
                        color: Colors.white
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
                      onPressed: _nextDate,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodToggle(String label, String value) {
    final isSelected = _periodType == value;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
            setState(() { 
                _periodType = value; 
                if (value == 'yearly') {
                   // When switching to yearly, defaulting to current year usually makes sense
                   // but keeping selectedDate is fine too
                }
            });
            _loadAnalytics();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6.0), // Reduced vertical padding
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? kPrimaryRed : Colors.white70,
          ),
        ),
      ),
    );
  }

  void _prevDate() {
    setState(() {
      if (_periodType == 'monthly') {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
      } else {
        _selectedDate = DateTime(_selectedDate.year - 1, 1, 1);
      }
    });
    _loadAnalytics();
  }

  void _nextDate() {
    setState(() {
      if (_periodType == 'monthly') {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
      } else {
        _selectedDate = DateTime(_selectedDate.year + 1, 1, 1);
      }
    });
    _loadAnalytics();
  }

  String _formatDateFilter() {
    if (_periodType == 'yearly') {
      return '${_selectedDate.year}';
    } else {
      const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
      return '${months[_selectedDate.month - 1]} ${_selectedDate.year}';
    }
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



  // --- KPI Section ---
  Widget _buildKpiSection(ReportData d) {
    return Column(
      children: [
        Row(
          children: [
            ReportKpiCard(
              icon: Icons.attach_money_rounded,
              title: 'Rp. ${(d.revenueThisPeriod / 1000000).toStringAsFixed(1)}Jt', // Short format (64.7Jt)
              subtitle: 'Pendapatan bulan ini',
              growthText: d.revenueGrowthText,
              onTap: () {},
            ),
            const SizedBox(width: 14),
            ReportKpiCard(
              icon: Icons.assignment_turned_in_rounded,
              title: '${d.jobsDone} Order',
              subtitle: 'Pekerjaan Selesai',
              growthText: d.jobsGrowthText,
              iconBgColor: const Color(0xFFE3F2FD), // Blue bg
              iconColor: const Color(0xFF1976D2),
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
             ReportKpiCard(
              icon: Icons.groups_rounded,
              title: '${d.occupancy}%',
              subtitle: 'Occupancy Rate',
              growthText: d.occupancyGrowthText, // e.g -3%
              iconBgColor: const Color(0xFFF3E5F5), // Purple bg
              iconColor: const Color(0xFF7B1FA2),
              onTap: () {},
            ),
            const SizedBox(width: 14),
             ReportKpiCard(
              icon: Icons.star_rounded,
              title: '${d.avgRating}',
              subtitle: 'Rating Rata-rata',
              growthText: d.ratingGrowthText,
              iconBgColor: const Color(0xFFFFF8E1), // Amber bg
              iconColor: const Color(0xFFFFA000),
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  // --- Chart Sections ---
  
  Widget _buildTrendChart(ReportData d) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(24),
         boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 4)),
         ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text('Grafik Tren', style: _titleStyle),
                   Text('Pendapatan & Pekerjaan', style: _subtitleStyle),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.more_horiz, size: 16, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: () {
              // Check if data is empty (all zeros)
              final hasData = d.revenueTrend.any((v) => v > 0) || d.jobsTrend.any((v) => v > 0);
              
              if (!hasData) {
                // Show empty state placeholder
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.insert_chart_outlined, size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada data transaksi',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Grafik akan muncul setelah ada transaksi',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                );
              }
              
              // Show chart if data exists
              return LineChart(
                ReportCharts.lineChartData(
                  labels: d.labels,
                  seriesA: d.revenueTrend, // Pendapatan
                  colorA: const Color(0xFF7C3AED), // Purple
                  seriesB: d.jobsTrend, // Pekerjaan
                  colorB: const Color(0xFF3B82F6), // Blue
                ),
                duration: const Duration(milliseconds: 400),
              );
            }(),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastChart(ReportData d) {
    // Check if forecast has any meaningful data (non-zero values)
    final hasData = d.forecastRevenue.any((item) => (item['value'] as num) > 0);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(24),
         boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 4)),
         ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             children: [
               Container(
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(
                   color: const Color(0xFFE8F5E9),
                   borderRadius: BorderRadius.circular(8),
                 ),
                 child: const Icon(Icons.show_chart_rounded, size: 18, color: Color(0xFF2E7D32)),
               ),
               const SizedBox(width: 12),
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text('Forecast Pendapatan', style: _titleStyle),
                   Text('Prediksi 7 hari kedepan (ML)', style: _subtitleStyle),
                 ],
               ),
             ],
           ),
           const SizedBox(height: 24),
           SizedBox(
             height: 180,
             child: hasData 
               ? LineChart(
                   LineChartData(
                     gridData: FlGridData(show: false),
                     titlesData: FlTitlesData(show: false),
                     borderData: FlBorderData(show: false),
                     lineBarsData: [
                       LineChartBarData(
                         spots: d.forecastRevenue.asMap().entries.map((e) {
                           return FlSpot(e.key.toDouble(), (e.value['value'] as num).toDouble());
                         }).toList(),
                         isCurved: true,
                         color: const Color(0xFF2E7D32),
                         barWidth: 3,
                         isStrokeCapRound: true,
                         dotData: FlDotData(show: false),
                         belowBarData: BarAreaData(
                           show: true,
                           color: const Color(0xFF2E7D32).withOpacity(0.1),
                         ),
                       ),
                     ],
                   ),
                 )
               : Center(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Icon(Icons.insights_outlined, size: 48, color: Colors.grey[300]),
                       const SizedBox(height: 12),
                       Text(
                         'Belum ada prediksi',
                         style: TextStyle(color: Colors.grey[600], fontSize: 14),
                       ),
                       const SizedBox(height: 4),
                       Text(
                         'ML memerlukan data historis untuk prediksi',
                         style: TextStyle(color: Colors.grey[400], fontSize: 12),
                       ),
                     ],
                   ),
                 ),
           ),
           const SizedBox(height: 16),
           Text(
             hasData 
               ? "Estimasi berdasarkan tren data historis. Akurasi tergantung pada kelengkapan data."
               : "Prediksi akan muncul setelah ada cukup data transaksi historis.",
             style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
           )
        ],
      ),
    );
  }



  Widget _buildTechnicianLeaderboard(ReportData d) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(24),
         boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 4)),
         ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text('Teknisi Terbaik', style: _titleStyle),
                   Text('Performa penyelesaian service', style: _subtitleStyle),
                 ],
               ),
               Container(
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(
                   color: Colors.orange.withValues(alpha: 0.1),
                   borderRadius: BorderRadius.circular(8),
                 ),
                 child: const Icon(Icons.workspace_premium_outlined, size: 18, color: Colors.orange),
               ),
             ],
           ),
           const SizedBox(height: 24),
           ...d.topMechanics.asMap().entries.map((entry) {
             final index = entry.key;
             final mech = entry.value;
             final isLast = index == d.topMechanics.length - 1;
             
             return Container(
               margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
               child: Row(
                 children: [
                   // Minimal Rank Text
                    SizedBox(
                      width: 24, 
                      child: Text(
                        '#${index + 1}',
                        style: GoogleFonts.poppins(
                          fontSize: 14, 
                          fontWeight: index < 3 ? FontWeight.bold : FontWeight.w500,
                          color: index < 3 ? kPrimaryRed : Colors.grey[400]
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Avatar (Standard)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                        image: (mech['photo_url'] != null && (mech['photo_url'] as String).isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(mech['photo_url']),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: (mech['photo_url'] == null || (mech['photo_url'] as String).isEmpty)
                          ? Icon(Icons.person_outline_rounded, size: 20, color: Colors.grey[400])
                          : null,
                    ),
                    const SizedBox(width: 16),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(mech['name'] ?? 'Teknisi', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: const Color(0xFF212121))),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                               Icon(Icons.check_circle_outline_rounded, size: 12, color: Colors.grey[500]),
                               const SizedBox(width: 4),
                               Text('${mech['jobs_count']} Pekerjaan', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600])),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Rating (Clean)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_border_rounded, size: 14, color: Color(0xFFFFA000)),
                          const SizedBox(width: 4),
                          Text('${mech['rating']}', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF212121))),
                        ],
                      ),
                    )
                 ],
               ),
             );
           }).toList(),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(ReportData d) {
    return Column( // Use Column on small screens if needed, but spec says Row
       children: [
          _buildServiceTypeCard(d),
          const SizedBox(height: 20),
          _buildAvgQueueCard(d),
       ],
    );
  }

  Widget _buildServiceTypeCard(ReportData d) {
    // Check if breakdown is empty
    if (d.serviceBreakdown.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
             BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 4)),
          ],
        ),
         child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text('Jenis Service', style: _titleStyle),
             const SizedBox(height: 20),
             Center(child: Text("Belum ada data service", style: _subtitleStyle)),
          ],
         ),
      );
    }

    // Colors for dynamic legend (cycle through)
    final colors = [
      const Color(0xFF7C3AED), // Purple
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF22C55E), // Green
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEC4899), // Pink
      const Color(0xFF6366F1), // Indigo
    ];

    int colorIndex = 0;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(24),
         boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 4)),
         ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text('Jenis Service', style: _titleStyle),
           const SizedBox(height: 20),
           Row(
             children: [
               // Donut
               SizedBox(
                 height: 120,
                 width: 120,
                 child: PieChart(ReportCharts.donutData(d.serviceBreakdown)),
               ),
               const SizedBox(width: 20),
               // Legend Dynamic
               Expanded(
                 child: Column(
                   children: d.serviceBreakdown.entries.map((entry) {
                      final color = colors[colorIndex % colors.length];
                      colorIndex++;
                      return _buildLegendRow(entry.key, '${entry.value.toStringAsFixed(1)}%', color);
                   }).toList(),
                 ),
               )
             ],
           )
        ],
      ),
    );
  }

  Widget _buildAvgQueueCard(ReportData d) {
     return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(24),
         boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 4)),
         ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Text('Avg. Antrian', style: _titleStyle),
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                 decoration: BoxDecoration(
                   color: const Color(0xFFE8F5E9),
                   borderRadius: BorderRadius.circular(6),
                 ),
                 child: Text('+2.4%', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32))),
               )
             ],
           ),
           const SizedBox(height: 20),
           SizedBox(
             height: 150,
             child: BarChart(
               ReportCharts.barsData(
                 values: d.avgQueueBars,
                 labels: const ['Sn', 'Sl', 'Rb', 'Km', 'Jm', 'Sb', 'Mn'],
                 color: const Color(0xFFA855F7), // Light Purple
               )
             ),
           )
        ],
      ),
    );
  }

  Widget _buildPeakHour(ReportData d) {
    // Check if peak hour data is empty (all zeros)
    final hasData = d.peakHourBars.any((v) => v > 0);

     return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(24),
         boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 4)),
         ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text('Peak Hour', style: _titleStyle),
                   Text(hasData ? 'Jam Sibuk bengkel' : 'Belum ada data', style: _subtitleStyle),
                 ],
               ),
               Container(
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(
                   color: const Color(0xFFE3F2FD),
                   borderRadius: BorderRadius.circular(8),
                 ),
                 child: const Icon(Icons.schedule_rounded, size: 18, color: Color(0xFF1976D2)),
               ),
             ],
           ),
           const SizedBox(height: 24),
           SizedBox(
             height: 160,
             child: hasData 
               ? BarChart(
                   ReportCharts.barsData(
                     values: d.peakHourBars.map((v) => v.toDouble()).toList(),
                     labels: d.peakHourLabels,
                     color: const Color(0xFF3B82F6), // Blue
                   )
                 )
               : Center(
                   child: Text(
                     "Grafik muncul saat ada transaksi",
                     style: TextStyle(color: Colors.grey[400], fontSize: 12),
                   ),
                 ),
           )
        ],
      ),
    );
  }

  Widget _buildCtaButton() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
           BoxShadow(
             color: kPrimaryRed.withValues(alpha: 0.4),
             blurRadius: 12,
             offset: const Offset(0, 6)
           )
        ]
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: () async {
          // Generate and show PDF
          // Generate and show PDF
           if (_data != null) {
            await ReportPdfService.generate(
              data: _data!,
              periodType: _periodType,
              dateLabel: _formatDateFilter(),
            );
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             const Icon(Icons.print_rounded, size: 20),
             const SizedBox(width: 8),
             Text(
               'Cetak Laporan',
               style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
             ),
          ],
        ),
      ),
    );
  }

  // --- Styles & Helpers ---
  TextStyle get _titleStyle => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: const Color(0xFF212121),
  );
  
  TextStyle get _subtitleStyle => GoogleFonts.poppins(
    fontSize: 12,
    color: const Color(0xFF9E9E9E),
  );

  Widget _buildLegendRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Container(
                   margin: const EdgeInsets.only(top: 3),
                   width: 8, 
                   height: 8, 
                   decoration: BoxDecoration(color: color, shape: BoxShape.circle)
                 ),
                 const SizedBox(width: 8),
                 Expanded(
                   child: Text(
                     label, 
                     style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF757575)),
                   ),
                 ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF212121))),
        ],
      ),
    );
  }

  String formatCurrency(int v) {
    // simplified
    return v.toString();
  }
}
