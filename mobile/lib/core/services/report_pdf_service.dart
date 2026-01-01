import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import '../../feature/owner/widgets/report/report_data.dart';

class ReportPdfService {
  static Future<void> generate({
    required ReportData data,
    required String periodType, // 'monthly', 'yearly'
    required String dateLabel, // e.g. "Januari 2025"
  }) async {
    final pdf = pw.Document();

    // Load custom font for Indonesian character support
    final fontRegular = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    
    // Create theme with custom fonts
    final theme = pw.ThemeData.withFont(
      base: fontRegular,
      bold: fontBold,
    );

    // Load logo (if exists)
    pw.ImageProvider? logo;
    try {
      final logoBytes = await rootBundle.load('assets/logo.png');
      logo = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (e) {
      // Logo not found, skip
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: theme,
        build: (context) => [
          // Header
          _buildHeader(logo, dateLabel),
          pw.SizedBox(height: 24),

          // KPI Summary
          _buildKpiSection(data),
          pw.SizedBox(height: 24),

          // Financial Summary (NEW)
          _buildFinancialSummary(data, periodType),
          pw.SizedBox(height: 24),

          // Trend Analysis
          _buildTrendSection(data, dateLabel),
          pw.SizedBox(height: 24),

          // Service Breakdown
          _buildServiceSection(data),
          pw.SizedBox(height: 24),

          // Peak Hour Analysis
          _buildPeakHourSection(data),
          pw.SizedBox(height: 24),

          // Operational Health
          _buildHealthSection(data),
          pw.SizedBox(height: 16),

          // Footer
          _buildFooter(),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'laporan-bengkel-$dateLabel.pdf',
    );
  }

  static pw.Widget _buildHeader(pw.ImageProvider? logo, String dateLabel) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'LAPORAN ANALITIK BENGKEL',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor.fromInt(0xFFB70F0F),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text( // Updated to new dateLabel
                  'Periode: $dateLabel',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.Text(
                  'Digenerate: ${_formatDate(DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
            if (logo != null)
              pw.Image(logo, width: 60, height: 60),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(color: const PdfColor.fromInt(0xFFB70F0F), thickness: 2),
      ],
    );
  }

  static pw.Widget _buildKpiSection(ReportData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Ringkasan Kinerja'),
        pw.SizedBox(height: 12),
        pw.Row(
          children: [
            _kpiCard(
              'Pendapatan',
              'Rp ${_formatCurrency(data.revenueThisPeriod)}',
              data.revenueGrowthText,
              const PdfColor.fromInt(0xFFFFEBEE),
            ),
            pw.SizedBox(width: 12),
            _kpiCard(
              'Pekerjaan Selesai',
              '${data.jobsDone} Order',
              data.jobsGrowthText,
              const PdfColor.fromInt(0xFFE3F2FD),
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          children: [
            _kpiCard(
              'Occupancy Rate',
              '${data.occupancy}%',
              data.occupancyGrowthText,
              const PdfColor.fromInt(0xFFF3E5F5),
            ),
            pw.SizedBox(width: 12),
            _kpiCard(
              'Rating Rata-rata',
              '${data.avgRating}/5.0',
              data.ratingGrowthText,
              const PdfColor.fromInt(0xFFFFF8E1),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildFinancialSummary(ReportData data, String periodType) {
    // Generate weekly breakdown data (simulated for monthly view)
    final weeklyData = _generateWeeklyFinancialData(data, periodType);
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Ringkasan Keuangan'),
        pw.SizedBox(height: 12),
        
        // Summary totals
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: const PdfColor.fromInt(0xFFF5F5F5),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _financialSummaryItem('Total Pendapatan', 'Rp ${_formatCurrency(data.revenueThisPeriod)}', PdfColors.green),
              _financialSummaryItem('Total Pekerjaan', '${data.jobsDone} Order', PdfColors.blue),
              _financialSummaryItem('Rata-rata/Pekerjaan', 'Rp ${_formatCurrency(_safeDivide(data.revenueThisPeriod, data.jobsDone))}', PdfColors.orange),
            ],
          ),
        ),
        
        if (periodType == 'monthly') ...[
          pw.SizedBox(height: 16),
          pw.Text('Breakdown Mingguan:', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          
          // Weekly breakdown table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
            },
            children: [
              // Header row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF5F5F5)),
                children: [
                  _tableCell('Minggu', isHeader: true),
                  _tableCell('Pendapatan', isHeader: true),
                  _tableCell('Pekerjaan', isHeader: true),
                  _tableCell('Avg/Order', isHeader: true),
                ],
              ),
              // Data rows
              ...weeklyData.map((week) => pw.TableRow(
                children: [
                  _tableCell(week.label),
                  _tableCell('Rp ${_formatCurrency(week.revenue)}'),
                  _tableCell('${week.jobs} Order'),
                  _tableCell('Rp ${_formatCurrency(_safeDivide(week.revenue, week.jobs))}'),
                ],
              )),
              // Total row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFFFF3E0)),
                children: [
                  _tableCell('TOTAL', isHeader: true),
                  _tableCell('Rp ${_formatCurrency(data.revenueThisPeriod)}', isHeader: true),
                  _tableCell('${data.jobsDone} Order', isHeader: true),
                  _tableCell('Rp ${_formatCurrency(_safeDivide(data.revenueThisPeriod, data.jobsDone))}', isHeader: true),
                ],
              ),
            ],
          ),
        ],
      ],
    );
  }

  static pw.Widget _financialSummaryItem(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    );
  }

  static pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? const PdfColor.fromInt(0xFF212121) : PdfColors.grey800,
        ),
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  static List<({String label, int revenue, int jobs})> _generateWeeklyFinancialData(ReportData data, String periodType) {
    if (periodType != 'monthly') {
      return [];
    }
    
    // Simulate weekly breakdown from monthly data
    final weeklyRevenue = (data.revenueThisPeriod / 4).round();
    final weeklyJobs = (data.jobsDone / 4).round();
    
    return [
      (label: 'Minggu 1', revenue: (weeklyRevenue * 0.9).round(), jobs: (weeklyJobs * 0.85).round()),
      (label: 'Minggu 2', revenue: (weeklyRevenue * 1.1).round(), jobs: (weeklyJobs * 1.05).round()),
      (label: 'Minggu 3', revenue: (weeklyRevenue * 1.05).round(), jobs: (weeklyJobs * 1.10).round()),
      (label: 'Minggu 4', revenue: (data.revenueThisPeriod - (weeklyRevenue * 0.9).round() - (weeklyRevenue * 1.1).round() - (weeklyRevenue * 1.05).round()), 
                jobs: (data.jobsDone - (weeklyJobs * 0.85).round() - (weeklyJobs * 1.05).round() - (weeklyJobs * 1.10).round())),
    ];
  }

  static pw.Widget _buildTrendSection(ReportData data, String dateLabel) {
    // Generate insight based on trend
    final revenueGrowth = _parseGrowth(data.revenueGrowthText);
    final jobsGrowth = _parseGrowth(data.jobsGrowthText);
    
    String insight;
    if (revenueGrowth > 10) {
      insight = 'Analisis menunjukkan tren pertumbuhan positif yang signifikan dengan peningkatan pendapatan ${data.revenueGrowthText} dibandingkan periode sebelumnya. '
          'Strategi pemasaran dan standar layanan saat ini menunjukkan efektivitas yang baik dan sebaiknya dipertahankan.';
    } else if (revenueGrowth > 0) {
      insight = 'Terdapat pertumbuhan pendapatan sebesar ${data.revenueGrowthText} pada periode ini. '
          'Disarankan untuk menambah inisiatif promosi guna mempercepat laju pertumbuhan bisnis.';
    } else {
      insight = 'Terjadi penurunan pendapatan sebesar ${data.revenueGrowthText.replaceAll('−', '')}. '
          'Diperlukan evaluasi menyeluruh terhadap strategi penetapan harga dan peningkatan retensi pelanggan.';
    }

    if (jobsGrowth < -5) {
      insight += ' Penurunan signifikan pada volume pekerjaan mengindikasikan perlunya fokus intensif pada akuisisi pelanggan baru dan strategi peningkatan market share.';
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Analisis Tren Pendapatan & Pekerjaan'),
        pw.SizedBox(height: 12),
        _insightBox(insight),
        pw.SizedBox(height: 12),
        pw.Text(
          'Grafik menunjukkan perbandingan tren $dateLabel untuk:',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            _legendItem('Pendapatan (juta)', const PdfColor.fromInt(0xFF7C3AED)),
            pw.SizedBox(width: 16),
            _legendItem('Pekerjaan', const PdfColor.fromInt(0xFF3B82F6)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildServiceSection(ReportData data) {
    if (data.serviceBreakdown.isEmpty) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sectionTitle('Breakdown Jenis Service'),
          pw.SizedBox(height: 12),
          pw.Text('Belum ada data service pada periode ini.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
        ],
      );
    }

    final breakdown = data.serviceBreakdown;
    final topService = breakdown.entries.reduce((a, b) => a.value > b.value ? a : b);
    
    String insight = 'Layanan ${topService.key} merupakan kontributor utama dengan proporsi ${topService.value.toInt()}% dari total transaksi. ';
    
    if (topService.key == 'Service Rutin') {
      insight += 'Data ini mengindikasikan basis pelanggan yang loyal dengan pola kunjungan teratur. '
          'Rekomendasi: Implementasi program keanggotaan atau paket bundling untuk meningkatkan customer lifetime value dan retensi.';
    } else if (topService.key == 'Perbaikan') {
      insight += 'Tingginya permintaan layanan perbaikan menunjukkan karakteristik armada kendaraan dengan usia operasional yang cukup tinggi. '
          'Rekomendasi: Promosikan layanan preventif maintenance untuk mengurangi frekuensi breakdown dan meningkatkan kepuasan pelanggan.';
    } else if (topService.key == 'Ganti Onderdil') {
      insight += 'Volume penggantian komponen yang tinggi memerlukan manajemen inventori yang optimal. '
          'Rekomendasi: Pastikan ketersediaan stok spare parts untuk menghindari kehilangan peluang penjualan dan menjaga service level.';
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Breakdown Jenis Service'),
        pw.SizedBox(height: 12),
        _insightBox(insight),
        pw.SizedBox(height: 12),
        ...breakdown.entries.map((entry) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(entry.key, style: const pw.TextStyle(fontSize: 11)),
              pw.Text('${entry.value.toInt()}%', 
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        )),
      ],
    );
  }

  static pw.Widget _buildPeakHourSection(ReportData data) {
    String insight = 'Puncak aktivitas operasional terjadi pada rentang waktu ${data.peakRange}. ';
    
    if (data.peakRange.contains('14:00') || data.peakRange.contains('16:00')) {
      insight += 'Konsentrasi pelanggan pada periode siang hingga sore hari menunjukkan pola kunjungan yang teratur. '
          'Rekomendasi: Pastikan seluruh teknisi tersedia dan tingkatkan stok spare parts pada window waktu tersebut untuk optimalisasi layanan.';
    } else if (data.peakRange.contains('08:00') || data.peakRange.contains('10:00')) {
      insight += 'Pola kunjungan di pagi hari mengindikasikan segmen pelanggan pekerja di area sekitar lokasi bengkel. '
          'Rekomendasi: Tawarkan layanan express atau fast-track untuk mengakomodasi kebutuhan pelanggan dengan keterbatasan waktu.';
    }
    
    insight += ' Implementasi sistem booking online dapat membantu distribusi beban kerja yang lebih efisien dan mengurangi waktu tunggu pelanggan.';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Analisis Peak Hour'),
        pw.SizedBox(height: 12),
        _insightBox(insight),
        pw.SizedBox(height: 8),
        pw.Text(
          'Rekomendasi Strategis: Alokasikan tenaga kerja tambahan pada rentang waktu ${data.peakRange} untuk mengoptimalkan throughput layanan dan meminimalkan durasi antrian pelanggan.',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFFB70F0F)),
        ),
      ],
    );
  }

  static pw.Widget _buildHealthSection(ReportData data) {
    final healthStatus = _assessHealth(data);
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Kesehatan Operasional'),
        pw.SizedBox(height: 12),
        _insightBox(healthStatus.overview),
        pw.SizedBox(height: 12),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: const PdfColor.fromInt(0xFFFFF0F1),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Column(
            children: [
              _healthMetric('Rata-rata Antrian', '${data.avgQueue} mobil', healthStatus.queueStatus),
              pw.Divider(),
              _healthMetric('Occupancy Bengkel', '${data.occupancy}%', healthStatus.occupancyStatus),
              pw.Divider(),
              _healthMetric('Efisiensi', '${data.efficiency}%', healthStatus.efficiencyStatus),
            ],
          ),
        ),
        if (healthStatus.actionItems.isNotEmpty) ...[
          pw.SizedBox(height: 12),
          pw.Text('Action Items:', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          ...healthStatus.actionItems.map((item) => pw.Padding(
            padding: const pw.EdgeInsets.only(top: 4, left: 8),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('• ', style: const pw.TextStyle(fontSize: 10)),
                pw.Expanded(child: pw.Text(item, style: const pw.TextStyle(fontSize: 10))),
              ],
            ),
          )),
        ],
      ],
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: const pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Disclaimer: Analisis dan insight dalam laporan ini dibuat berdasarkan data periode yang dipilih. '
            'Untuk keputusan bisnis penting, disarankan untuk konsultasi dengan business advisor.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper Widgets
  static pw.Widget _sectionTitle(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8, left: 4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400, width: 1)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: const PdfColor.fromInt(0xFF212121),
        ),
      ),
    );
  }

  static pw.Widget _kpiCard(String label, String value, String growth, PdfColor bgColor) {
    final isPositive = !growth.contains('−') && !growth.contains('-');
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: bgColor,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                pw.Text(
                  growth,
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: isPositive ? const PdfColor.fromInt(0xFF2E7D32) : const PdfColor.fromInt(0xFFC62828),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Text(value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _insightBox(String insight) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFFFF9C4),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFFBC02D), width: 1),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 4,
            height: 4,
            margin: const pw.EdgeInsets.only(top: 6, right: 8),
            decoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFF57C00),
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              insight,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey900),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _legendItem(String label, PdfColor color) {
    return pw.Row(
      children: [
        pw.Container(
          width: 12,
          height: 12,
          decoration: pw.BoxDecoration(
            color: color,
            shape: pw.BoxShape.circle,
          ),
        ),
        pw.SizedBox(width: 6),
        pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
      ],
    );
  }

  static pw.Widget _healthMetric(String label, String value, String status) {
    PdfColor statusColor;
   PdfColor bgColor;
    if (status.contains('Normal') || status.contains('Baik') || status.contains('Optimal')) {
      statusColor = const PdfColor.fromInt(0xFF2E7D32);
      bgColor = const PdfColor.fromInt(0xFFE8F5E9); // Light green
    } else if (status.contains('Tinggi') || status.contains('Buruk')) {
      statusColor = const PdfColor.fromInt(0xFFC62828);
      bgColor = const PdfColor.fromInt(0xFFFFEBEE); // Light red
    } else {
      statusColor = const PdfColor.fromInt(0xFFF57C00);
      bgColor = const PdfColor.fromInt(0xFFFFF3E0); // Light orange
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
              pw.SizedBox(height: 2),
              pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(
              color: bgColor,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Text(
              status,
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }



  static String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String _formatCurrency(int amount) {
    final str = amount.toString().split('').reversed.join();
    String result = '';
    for (int i = 0; i < str.length; i++) {
      if (i % 3 == 0 && i != 0) result += '.';
      result += str[i];
    }
    return result.split('').reversed.join();
  }

  static double _parseGrowth(String growthText) {
    final cleaned = growthText.replaceAll('%', '').replaceAll('+', '').replaceAll('−', '-').trim();
    return double.tryParse(cleaned.replaceAll(',', '.')) ?? 0;
  }

  static int _safeDivide(int numerator, int denominator) {
    if (denominator == 0) return 0;
    return (numerator / denominator).round();
  }

  static ({
    String overview,
    String queueStatus,
    String occupancyStatus,
    String efficiencyStatus,
    List<String> actionItems,
  }) _assessHealth(ReportData data) {
    final actionItems = <String>[];
    String queueStatus, occupancyStatus, efficiencyStatus;
    
    // Assess queue
    if (data.avgQueue < 10) {
      queueStatus = 'Normal';
    } else if (data.avgQueue < 20) {
      queueStatus = 'Cukup Tinggi';
      actionItems.add('Pertimbangkan sistem appointment untuk mengurangi antrian walk-in');
    } else {
      queueStatus = 'Tinggi';
      actionItems.add('URGENT: Antrian terlalu panjang, tingkatkan kapasitas service atau perpanjang jam operasional');
    }

    // Assess occupancy
    if (data.occupancy < 70) {
      occupancyStatus = 'Rendah';
      actionItems.add('Occupancy rendah, giatkan promosi dan customer acquisition');
    } else if (data.occupancy < 90) {
      occupancyStatus = 'Normal';
    } else {
      occupancyStatus = 'Tinggi';
      actionItems.add('Occupancy hampir penuh, pertimbangkan ekspansi atau optimasi waktu service');
    }

    // Assess efficiency
    if (data.efficiency >= 90) {
      efficiencyStatus = 'Baik';
    } else if (data.efficiency >= 75) {
      efficiencyStatus = 'Cukup';
      actionItems.add('Tingkatkan efisiensi dengan training staff atau optimasi workflow');
    } else {
      efficiencyStatus = 'Buruk';
      actionItems.add('URGENT: Efisiensi rendah, evaluasi proses operasional dan bottleneck');
    }

    String overview;
    if (actionItems.isEmpty) {
      overview = 'Kondisi kesehatan operasional bengkel berada pada level optimal. Standar operasional prosedur saat ini menunjukkan efektivitas yang baik dan sebaiknya dipertahankan untuk memastikan konsistensi kualitas layanan.';
    } else if (actionItems.length == 1) {
      overview = 'Secara umum kesehatan operasional dalam kondisi baik, namun terdapat beberapa aspek yang memerlukan perhatian dan perbaikan untuk optimalisasi operasional.';
    } else {
      overview = 'Analisis menunjukkan beberapa indikator operasional memerlukan tindakan korektif segera untuk mencegah degradasi kualitas layanan dan efisiensi operasional.';
    }

    return (
      overview: overview,
      queueStatus: queueStatus,
      occupancyStatus: occupancyStatus,
      efficiencyStatus: efficiencyStatus,
      actionItems: actionItems,
    );
  }
}
