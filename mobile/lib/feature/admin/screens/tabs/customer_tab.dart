import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_analytics_provider.dart';

class CustomerTab extends StatefulWidget {
  final String selectedRange; // "Hari ini" | "Minggu ini" | "Bulan ini"
  final String chartFilter; // "Week" | "Month"
  final ValueChanged<String> onRangeChange;
  final ValueChanged<String> onChartFilterChange;

  const CustomerTab({
    super.key,
    required this.selectedRange,
    required this.chartFilter,
    required this.onRangeChange,
    required this.onChartFilterChange,
  });

  @override
  State<CustomerTab> createState() => _CustomerTabState();
}

class _CustomerTabState extends State<CustomerTab> {
  static const _redDark = Color(0xFF9B0D0D);

  // dummy data
  final List<_Pt> _week = const [
    _Pt('Jan', 3),
    _Pt('Feb', 2),
    _Pt('Mar', 4),
    _Pt('Apr', 5.5),
    _Pt('May', 4.6),
    _Pt('Jun', 5),
  ];
  final List<_Pt> _month = const [
    _Pt('Jan', 2.2),
    _Pt('Feb', 3.1),
    _Pt('Mar', 3.8),
    _Pt('Apr', 4.2),
    _Pt('May', 4.0),
    _Pt('Jun', 4.9),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminAnalyticsProvider>(
      builder: (context, provider, child) {
        final isLoading = provider.isLoading && provider.quickStats == null;
        
        // Data for cards
        final totalFn = isLoading ? '...' : provider.totalCustomers.toString();
        final activeFn = isLoading ? '...' : provider.activeCustomers.toString();
        final newFn = isLoading ? '...' : provider.newCustomers.toString();

        // Data for Chart
        // Convert Provider's _ChartPt to local _Pt or just use it directly if we refactor.
        // Let's map it locally to simpler structure for now or reuse existing
        final trendData = provider.customerTrend.map((e) {
             // Parse date for label (e.g. "2024-01-01") -> "01 Jan" or just "01"
             // For simplicity, just take day part or short format
             try {
                final dt = DateTime.parse(e.date);
                return _Pt("${dt.day}/${dt.month}", e.value); 
             } catch (_) {
                return _Pt(e.label, e.value);
             }
        }).toList();

        // If no data, show empty placeholder or keep empty list
        final chartSource = trendData.isNotEmpty ? trendData : <_Pt>[];

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul + pill
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pelanggan',
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
              const SizedBox(height: 16),

              // Kartu Total Pelanggan (besar)
              _bigTotalCard(count: totalFn, title: 'Total Pelanggan'),
              const SizedBox(height: 14),

              // Dua kartu kecil
              Row(
                children: [
                  Expanded(
                      child: _smallCard(title: 'Pelanggan Aktif', value: activeFn)),
                  const SizedBox(width: 12),
                  Expanded(child: _smallCard(title: 'Pelanggan Baru', value: newFn)),
                ],
              ),

              const SizedBox(height: 20),
              Text('Analisis',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
              const SizedBox(height: 10),

              // Card Chart
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + filter Week/Month
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Customer Growth Trend',
                            style: GoogleFonts.poppins(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF9B0D0D))),
                        Row(
                          children: ['Week', 'Month'].map((f) {
                            final selected = widget.chartFilter == f;
                            return GestureDetector(
                              onTap: () => widget.onChartFilterChange(f),
                              child: Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      selected ? _redDark : const Color(0xFFEDEDED),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  f,
                                  style: GoogleFonts.poppins(
                                    color: selected ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Chart
                    if (isLoading)
                       const SizedBox(height:180, child: Center(child: CircularProgressIndicator()))
                    else if (chartSource.isEmpty)
                       SizedBox(
                         height: 180, 
                         child: Center(child: Text("Belum ada data", style: GoogleFonts.poppins(color: Colors.grey)))
                       )
                    else 
                    SizedBox(
                      height: 180,
                      child: SfCartesianChart(
                        plotAreaBorderWidth: 0,
                        primaryXAxis: CategoryAxis(
                          majorGridLines: const MajorGridLines(width: 0.25),
                          labelStyle: GoogleFonts.poppins(fontSize: 11),
                        ),
                        primaryYAxis: NumericAxis(
                          majorGridLines: const MajorGridLines(width: 0.25),
                          axisLine: const AxisLine(width: 0),
                          labelStyle: GoogleFonts.poppins(fontSize: 10),
                          decimalPlaces: 0,
                          interval: 1, 
                        ),
                        tooltipBehavior: TooltipBehavior(enable: true, header: 'Pelanggan'),
                        series: <CartesianSeries<_Pt, String>>[
                          LineSeries<_Pt, String>(
                            dataSource: chartSource,
                            xValueMapper: (d, _) => d.label,
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  // ----------------- Widgets Kecil -----------------

  Widget _rangePill(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 6),
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626), 
        borderRadius: BorderRadius.circular(24), 
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
          value: 'Hari ini', 
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          dropdownColor: Colors.white, 
          style: GoogleFonts.poppins(
              color: const Color(0xFFDC2626), fontSize: 13, fontWeight: FontWeight.w600),
          selectedItemBuilder: (BuildContext context) {
            return ['Hari ini', 'Minggu ini', 'Bulan ini'].map<Widget>((String item) {
              return Center(child: Text(item, style: const TextStyle(color: Colors.white)));
            }).toList();
          },
          items: const ['Hari ini', 'Minggu ini', 'Bulan ini']
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: GoogleFonts.poppins(color: Colors.black), 
                    ),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) {
              widget.onRangeChange(v); 

              // Fetch detailed stats based on selection
              final now = DateTime.now();
              String dateFrom;
              String dateTo = now.toIso8601String().split('T')[0];

              if (v == 'Minggu ini') {
                dateFrom = now.subtract(const Duration(days: 7)).toIso8601String().split('T')[0];
              } else if (v == 'Bulan ini') {
                dateFrom = now.subtract(const Duration(days: 30)).toIso8601String().split('T')[0];
              } else {
                // Hari ini
                dateFrom = dateTo; 
              }
              
              context.read<AdminAnalyticsProvider>().fetchDetailedStats(
                dateFrom: dateFrom,
                dateTo: dateTo,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _bigTotalCard({required String count, required String title}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(
            count,
            style: GoogleFonts.poppins(
                fontSize: 28,
                color: const Color(0xFFDC2626),
                fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _smallCard({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  color: const Color(0xFFDC2626),
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Pt {
  final String label;
  final double value;
  const _Pt(this.label, this.value);
}
