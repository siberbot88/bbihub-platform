import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ReportCharts {
  static LineChartData lineChartData({
    required List<String> labels,
    required List<double> seriesA,
    required Color colorA,
    required List<double> seriesB,
    required Color colorB,
  }) {
    // Ensure maxY is never zero to prevent interval errors
    final allValues = [...seriesA, ...seriesB];
    final maxValue = allValues.isEmpty ? 0 : allValues.reduce(max);
    final maxY = maxValue == 0 ? 10.0 : maxValue * 1.2; // Minimum 10 if no data

    SideTitles bottomTitles() => SideTitles(
          showTitles: true,
          reservedSize: 28,
          getTitlesWidget: (value, meta) {
            final i = value.toInt();
            if (i < 0 || i >= labels.length) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                labels[i],
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF9E9E9E), // Lighter grey for V2
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
          interval: 1,
        );

    // Helper for Area Gradient
    LineChartBarData lineData(List<double> data, Color color) {
      return LineChartBarData(
        spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i])),
        isCurved: true,
        color: color,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
            radius: 4,
            color: Colors.white,
            strokeWidth: 2,
            strokeColor: color,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.2), // Start transparent
              color.withValues(alpha: 0.0), // Fade out
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );
    }

    return LineChartData(
      minY: 0,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        verticalInterval: 1, // Draw vertical lines for each point
        horizontalInterval: max(1.0, maxY / 4), // Ensure minimum interval of 1
        getDrawingVerticalLine: (value) => FlLine(
          color: const Color(0xFFEEEEEE),
          strokeWidth: 1,
          dashArray: [5, 5],
        ),
        getDrawingHorizontalLine: (value) => FlLine(
          color: const Color(0xFFEEEEEE),
          strokeWidth: 1,
          dashArray: [5, 5],
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // Clean look
        bottomTitles: AxisTitles(sideTitles: bottomTitles()),
      ),
      lineBarsData: [
        lineData(seriesA, colorA), // Pendapatan (Purple)
        lineData(seriesB, colorB), // Pekerjaan (Blue)
      ],
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          // tooltipBgColor: Colors.black87, // Removed in newer versions or use decoration
           getTooltipColor: (touchedSpot) => Colors.black87,
           tooltipRoundedRadius: 8,
           tooltipPadding: const EdgeInsets.all(8),
        ),
      ),
    );
  }

  static PieChartData donutData(Map<String, double> breakdown) {
    final entries = breakdown.entries.toList();
    final colors = [
      const Color(0xFF7C3AED), // Purple (Rutin)
      const Color(0xFF3B82F6), // Blue (Perbaikan)
      const Color(0xFF22C55E), // Green (Onderdil)
      const Color(0xFFF59E0B), // Orange (Body)
    ];

    return PieChartData(
      centerSpaceRadius: 40,
      sectionsSpace: 4,
      startDegreeOffset: -90,
      sections: List.generate(entries.length, (i) {
        return PieChartSectionData(
          value: entries[i].value,
          color: colors[i % colors.length],
          radius: 18, // Thinner ring for modern look
          showTitle: false,
        );
      }),
    );
  }

  static BarChartData barsData({
    required List<double> values,
    required List<String> labels,
    required Color color,
  }) {
    // Ensure maxY is never zero to prevent interval errors
    final allValues = values.isEmpty ? [0.0] : values;
    final maxValue = allValues.reduce(max);
    final maxY = maxValue == 0 ? 10.0 : maxValue * 1.2; // Minimum 10 if no data

    return BarChartData(
      maxY: maxY,
      minY: 0,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: max(1.0, maxY / 4), // Ensure minimum interval of 1
        getDrawingHorizontalLine: (value) => FlLine(
          color: const Color(0xFFF5F5F5),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 26,
            getTitlesWidget: (value, meta) {
              final i = value.toInt();
              if (i < 0 || i >= labels.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  labels[i],
                  style: const TextStyle(
                    fontSize: 9, // Small labels
                    color: Color(0xFF9E9E9E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
            interval: 1,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(values.length, (i) {
        return BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: values[i],
              color: color,
              width: 16, // Slightly wider bars
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
              backDrawRodData: BackgroundBarChartRodData(
                 show: true,
                 toY: maxY, // Full height background
                 color: const Color(0xFFF5F5F5), // Light grey track
              ),
            ),
          ],
        );
      }),
    );
  }
}
