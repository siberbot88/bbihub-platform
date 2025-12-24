import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class RevenueTab extends StatelessWidget {
  final String selectedRange;
  final ValueChanged<String> onRangeChange;
  final String chartFilter;
  final ValueChanged<String> onChartFilterChange;

  const RevenueTab({
    super.key,
    required this.selectedRange,
    required this.onRangeChange,
    required this.chartFilter,
    required this.onChartFilterChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // 🔹 Background Gradient
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF6A1B1B), // dark red
            Color(0xFFA12C2C), // medium red
            Color(0xFFE57373), // light red
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Title + Dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Revenue",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.white)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red[900],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButton<String>(
                    value: selectedRange,
                    underline: const SizedBox(),
                    dropdownColor: Colors.red[900],
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    style: GoogleFonts.poppins(color: Colors.white),
                    items: ["Today", "Yesterday", "Week", "Month"]
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e,
                                  style: const TextStyle(color: Colors.white)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) onRangeChange(value);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // 🔹 View All
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  // TODO: arahkan ke detail revenue
                },
                child: Text("View All",
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white)),
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 Revenue Recap + Transactions
            Row(
              children: [
                Expanded(
                  child: _revenueBox("Revenue Recap", "IDR 1,2 M", Colors.red),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _revenueBox("Total Transactions", "356", Colors.red),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔹 Analytics Title
            Text("Analytics",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white)),

            const SizedBox(height: 12),

            // 🔹 Chart Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 6,
                      offset: const Offset(0, 3))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Title + Filter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Revenue Trend",
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.red)),
                      Row(
                        children: ["Week", "Month"].map((f) {
                          final isSelected = chartFilter == f;
                          return GestureDetector(
                            onTap: () => onChartFilterChange(f),
                            child: Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFB70F0F)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(f,
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87)),
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 🔹 Line Chart
                  SizedBox(
                    height: 180,
                    child: LineChart(LineChartData(
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                            sideTitles:
                                SideTitles(showTitles: true, interval: 100)),
                        bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final months = [
                              "Jan",
                              "Feb",
                              "Mar",
                              "Apr",
                              "May",
                              "Jun"
                            ];
                            if (value.toInt() >= 0 &&
                                value.toInt() < months.length) {
                              return Text(months[value.toInt()],
                                  style: const TextStyle(fontSize: 10));
                            }
                            return const Text("");
                          },
                        )),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 120),
                            FlSpot(1, 80),
                            FlSpot(2, 140),
                            FlSpot(3, 200),
                            FlSpot(4, 170),
                            FlSpot(5, 190),
                          ],
                          isCurved: true,
                          color: Colors.purple,
                          barWidth: 2.5,
                          dotData: FlDotData(show: true),
                        ),
                      ],
                    )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Box untuk ringkasan revenue
  Widget _revenueBox(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 6,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: color)),
        ],
      ),
    );
  }
}
