// 📄 lib/feature/admin/screens/dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// tab lain
import 'tabs/technician_tab.dart';
import 'tabs/customer_tab.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedTab = "Servis";
  String selectedRange = "Hari ini";
  String chartFilter = "Week";

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
    );
  }

  // ---------- HEADER ----------
  Widget _buildHeader() {
    final tabs = ["Servis", "Mekanik", "Pelanggan"];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9B0D0D), Color(0xFFDC2626)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Dashboard",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Memantau layanan, teknisi, pendapatan, dan pelanggan",
            style: GoogleFonts.poppins(
              color: Colors.white.withAlpha(230),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: tabs.map((tab) {
              final selected = selectedTab == tab;
              return GestureDetector(
                onTap: () => setState(() => selectedTab = tab),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tab,
                    style: GoogleFonts.poppins(
                      color: selected ? const Color(0xFF9B0D0D) : Colors.white,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ---------- TAB SWITCHER ----------
  Widget _buildTabContent() {
    switch (selectedTab) {
      case "Servis":
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildServisSection(),
              const SizedBox(height: 24),
              _buildMostFrequentServices(),
              const SizedBox(height: 24),
              _buildAnalysisChart(),
            ],
          ),
        );
      case "Mekanik":
        return TechnicianTab(
          selectedRange: selectedRange,
          onRangeChange: (v) => setState(() => selectedRange = v),
        );
      case "Pelanggan":
        return CustomerTab(
          selectedRange: selectedRange,
          chartFilter: chartFilter,
          onRangeChange: (v) => setState(() => selectedRange = v),
          onChartFilterChange: (f) => setState(() => chartFilter = f),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // ---------- SERVIS SECTION ----------
  Widget _buildServisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // title + dropdown
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Servis",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            _buildDropdown(),
          ],
        ),
        const SizedBox(height: 16),

        // grid 2x2
        GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.9,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _summaryCardPrimary(
              title: "Servis Hari Ini",
              value: "12",
              icon: 'assets/icons/servis.svg',
            ),
            _summaryCardWhite(
              title: "Perlu di Assign",
              value: "8",
              icon: 'assets/icons/assign.svg',
            ),
            _summaryCardWhite(
              title: "Feedback",
              value: "4",
              icon: 'assets/icons/pelanggan.svg',
            ),
            _summaryCardWhite(
              title: "Selesai",
              value: "2",
              icon: 'assets/icons/completed.svg',
            ),
          ],
        ),
      ],
    );
  }

  // ---------- KARTU MERAH ----------
  Widget _summaryCardPrimary({
    required String title,
    required String value,
    required String icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9B0D0D), Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildIcon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- KARTU PUTIH ----------
  Widget _summaryCardWhite({
    required String title,
    required String value,
    required String icon,
  }) {
    const red = Color(0xFFDC2626);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildIcon(icon, color: red, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: red,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- HELPER ICON ----------
  Widget _buildIcon(String path, {Color? color, double size = 24}) {
    final colorFilter = color != null 
        ? ColorFilter.mode(color, BlendMode.srcIn) 
        : null;
    
    if (path.endsWith('.svg')) {
      return SvgPicture.asset(path, width: size, height: size, colorFilter: colorFilter);
    } else {
      return Image.asset(path, width: size, height: size, color: color);
    }
  }

  // ---------- DROPDOWN ----------
  Widget _buildDropdown() {
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
          value: 'Hari ini', // Pilihan default
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          dropdownColor: Colors.white, // Warna merah untuk dropdown
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
              // Update the selected value
              setState(() {
                selectedRange = v;
              });
            }
          },
        ),
      ),
    );
  }

  // ---------- MOST FREQUENT ----------
  Widget _buildMostFrequentServices() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              "Most Frequent Services",
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "View Details",
              style: GoogleFonts.poppins(
                color: const Color(0xFF9B0D0D),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ]),
          const SizedBox(height: 10),
          ...mostFrequent.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
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
          ),
        ],
      ),
    );
  }

  // ---------- CHART ----------
  Widget _buildAnalysisChart() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              "Services",
              style: GoogleFonts.poppins(
                color: const Color(0xFF9B0D0D),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: ["Week", "Month"].map((f) {
                final isSelected = chartFilter == f;
                return GestureDetector(
                  onTap: () => setState(() => chartFilter = f),
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF9B0D0D)
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
          ]),
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
    );
  }
}

class _ChartData {
  final String month;
  final double value;
  const _ChartData(this.month, this.value);
}
