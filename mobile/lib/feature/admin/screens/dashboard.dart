import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:provider/provider.dart';

// Reuse widgets from Owner feature to ensure exact design match
import '../../owner/widgets/report/report_kpi_card.dart';
import '../providers/admin_analytics_provider.dart';
import 'tabs/technician_tab.dart';
import 'tabs/customer_tab.dart';

// --- Colors ---
const Color kPrimaryRed = Color(0xFFB70F0F);
const Color kPrimaryRedDark = Color(0xFF9B0D0D);
const Color kBackground = Color(0xFFF5F5F5);

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _selectedTab = "Servis"; // Acts as the "Segmented Control" selection
  String _selectedRange = "Hari ini"; // Dropdown/Filter inside tabs if needed
  String _chartFilter = "Week";

  // Dummy Data for Admin
  final List<Map<String, dynamic>> mostFrequent = const [
    {'name': 'Ganti Oli', 'count': 18},
    {'name': 'Servis Rem', 'count': 12},
    {'name': 'Rotasi Ban', 'count': 8},
  ];

  final List<_ChartData> chartData = const [
    _ChartData('Jan', 3),
    _ChartData('Feb', 2),
    _ChartData('Mar', 4),
    _ChartData('Apr', 5.5),
    _ChartData('May', 4.5),
    _ChartData('Jun', 5),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    
    // Fetch stats
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminAnalyticsProvider>().fetchQuickStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Structure strictly follows ReportPage: Red Background behind header, White rounded body
    final topPadding = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // iOS
      ),
      child: Scaffold(
        backgroundColor: kPrimaryRed,
        body: Stack(
          children: [
            // 0. Background Extension (Ensures red behind status bar)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 200, // Sufficient coverage
              child: Container(color: kPrimaryRed),
            ),
            
            // 1. Main Content
            Column(
              children: [
                // Header (Gradient + Title + Segmented Control)
                Container(
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
                      // Nav Bar Placeholder / Title
                      const SizedBox(height: 10),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Dashboard Admin',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Monitor Layanan & Kinerja',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Segmented Control (Servis | Mekanik | Pelanggan)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            _buildSegmentTab('Servis'),
                            _buildSegmentTab('Mekanik'),
                            _buildSegmentTab('Pelanggan'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

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
                      child: _buildBodyContent(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentTab(String label) {
    final bool isSelected = _selectedTab == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? kPrimaryRed : Colors.white.withOpacity(0.9),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    switch (_selectedTab) {
      case "Servis":
        return _buildServisTab();
      case "Mekanik":
        return TechnicianTab(
          selectedRange: _selectedRange,
          onRangeChange: (v) => setState(() => _selectedRange = v),
        );
      case "Pelanggan":
        return CustomerTab(
          selectedRange: _selectedRange,
          chartFilter: _chartFilter,
          onRangeChange: (v) => setState(() => _selectedRange = v),
          onChartFilterChange: (f) => setState(() => _chartFilter = f),
        );
      default:
        return const Center(child: Text("Tab not found"));
    }
  }

  Widget _buildServisTab() {
    // 2x2 Grid of KPIs + Charts
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      physics: const BouncingScrollPhysics(),
      children: [
        Consumer<AdminAnalyticsProvider>(
          builder: (context, provider, child) {
            final isLoading = provider.isLoading && provider.quickStats == null;
            
            return Column(
              children: [
                Row(
                  children: [
                    ReportKpiCard(
                      icon: Icons.car_repair_rounded,
                      title: isLoading ? '...' : '${provider.serviceToday}',
                      subtitle: 'Servis Hari Ini',
                      growthText: '-', // Dynamic growth not yet available
                      iconSize: 26,
                      onTap: () {},
                    ),
                    const SizedBox(width: 14),
                    ReportKpiCard(
                      icon: Icons.person_search_rounded,
                      title: isLoading ? '...' : '${provider.needsAssign}',
                      subtitle: 'Perlu di Assign',
                      growthText: '!', 
                      iconBgColor: const Color(0xFFFFF8E1), 
                      iconColor: const Color(0xFFFFA000),
                      iconSize: 26,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    ReportKpiCard(
                      icon: Icons.star_rounded,
                      title: isLoading ? '...' : '${provider.feedbackCount}', // Use dynamic count
                      subtitle: 'Feedback',
                      growthText: '-',
                      iconBgColor: const Color(0xFFE3F2FD), 
                      iconColor: const Color(0xFF1976D2),
                      iconSize: 26,
                      onTap: () {},
                    ),
                    const SizedBox(width: 14),
                    ReportKpiCard(
                      icon: Icons.task_alt_rounded,
                      title: isLoading ? '...' : '${provider.completedToday}',
                      subtitle: 'Selesai',
                      growthText: '-',
                      iconBgColor: const Color(0xFFE8F5E9), 
                      iconColor: const Color(0xFF2E7D32),
                      iconSize: 26,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 24),

        // Most Frequent Services (Card Style)
        _buildSectionCard(
          title: "Most Frequent Services",
          actionText: "View Details",
          child: Column(
            children: mostFrequent
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item['name'] as String,
                            style: GoogleFonts.poppins(fontSize: 14)),
                        Text("${item['count']}",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),

        const SizedBox(height: 24),

        // Analysis Chart (Card Style)
        _buildSectionCard(
          title: "Services Trend",
          child: Column(
            children: [
              // Chart Filter
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: ["Week", "Month"].map((f) {
                  final isSelected = _chartFilter == f;
                  return GestureDetector(
                    onTap: () => setState(() => _chartFilter = f),
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? kPrimaryRed
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        f,
                        style: GoogleFonts.poppins(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SfCartesianChart(
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  majorGridLines: const MajorGridLines(width: 0.3),
                  labelStyle: GoogleFonts.poppins(fontSize: 11),
                ),
                primaryYAxis: NumericAxis(
                  majorGridLines: const MajorGridLines(width: 0.25),
                  axisLine: const AxisLine(width: 0),
                  labelStyle: GoogleFonts.poppins(fontSize: 10),
                ),
                series: <CartesianSeries<_ChartData, String>>[
                  LineSeries<_ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (d, _) => d.month,
                    yValueMapper: (d, _) => d.value,
                    color: const Color(0xFFB388FF),
                    width: 2,
                    markerSettings: const MarkerSettings(
                      isVisible: true,
                      shape: DataMarkerType.circle,
                      borderColor: Colors.black,
                      borderWidth: 1,
                      width: 7,
                      height: 7,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    String? actionText,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF212121),
                ),
              ),
              if (actionText != null)
                Text(
                  actionText,
                  style: GoogleFonts.poppins(
                    color: kPrimaryRed,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ChartData {
  final String month;
  final double value;
  const _ChartData(this.month, this.value);
}
