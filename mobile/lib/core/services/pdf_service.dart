import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

class PdfService {
  /// Generate thermal receipt (80mm width)
  static Future<Uint8List> generateThermalReceipt({
    required Map<String, dynamic> invoice,
    required Map<String, dynamic> workshop,
    required Map<String, dynamic> customer,
    required Map<String, dynamic> vehicle,
    required List<Map<String, dynamic>> items,
  }) async {
    final pdf = pw.Document();
    
    // Fetch Logo
    pw.ImageProvider? logoImage;
    if (workshop['logo_url'] != null) {
      try {
        logoImage = await networkImage(workshop['logo_url']);
      } catch (e) {
        // Ignore logo error
      }
    }

    // Thermal receipt is 80mm = ~226 points
    const receiptWidth = 80 * PdfPageFormat.mm;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(receiptWidth, double.infinity),
        margin: const pw.EdgeInsets.all(8),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Header - Workshop Info
              _buildReceiptHeader(workshop, logoImage),
              
              _buildDivider(),

              // Invoice Info
              pw.SizedBox(height: 8),
              pw.Text(
                'INVOICE: ${invoice['code'] ?? ''}',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Tanggal: ${_formatDate(invoice['created_at'])}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              
              _buildDivider(),

              // Customer & Vehicle Info
              pw.SizedBox(height: 4),
              _buildReceiptRow('Customer', customer['name'] ?? '-'),
              _buildReceiptRow('Telepon', customer['phone'] ?? '-'),
              _buildReceiptRow('Kendaraan', '${vehicle['brand'] ?? ''} ${vehicle['model'] ?? ''}'),
              _buildReceiptRow('Plat', vehicle['plate_number'] ?? '-'),
              
              _buildDoubleDivider(),

              // Items Header
              pw.Text(
                'DAFTAR PERBAIKAN:',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
              
              _buildDivider(),

              // Items List
              ...items.map((item) => _buildReceiptItem(item)).toList(),
              
              _buildDoubleDivider(),

              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL:',
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    _formatCurrency(invoice['total'] ?? 0),
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              
              _buildDoubleDivider(),

              // Footer
              pw.SizedBox(height: 8),
              pw.Text(
                'Terima Kasih!',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                'Selamat Berkendara',
                style: const pw.TextStyle(fontSize: 9),
                textAlign: pw.TextAlign.center,
              ),
              
              _buildDoubleDivider(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Generate B5 invoice (182 x 257 mm)
  static Future<Uint8List> generateB5Invoice({
    required Map<String, dynamic> invoice,
    required Map<String, dynamic> workshop,
    required Map<String, dynamic> customer,
    required Map<String, dynamic> vehicle,
    required List<Map<String, dynamic>> items,
  }) async {
    final pdf = pw.Document();

    // Fetch Logo
    pw.ImageProvider? logoImage;
    if (workshop['logo_url'] != null) {
      try {
        logoImage = await networkImage(workshop['logo_url']);
      } catch (e) {
        // Ignore logo error
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(18.2 * PdfPageFormat.cm, 25.7 * PdfPageFormat.cm),
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildB5Header(workshop, logoImage),
              
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),

              // Invoice Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'INVOICE',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(invoice['code'] ?? '', style: const pw.TextStyle(fontSize: 12)),
                      pw.Text(_formatDate(invoice['created_at']), style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

             // Customer Info
              _buildB5Section(
                'BILL TO',
                [
                  'Nama: ${customer['name'] ?? '-'}',
                  'Telepon: ${customer['phone'] ?? '-'}',
                  'Kendaraan: ${vehicle['brand'] ?? ''} ${vehicle['model'] ?? ''}',
                  'Plat Nomor: ${vehicle['plate_number'] ?? '-'}',
                ],
              ),

              pw.SizedBox(height: 20),

              // Items Table
              _buildB5ItemsTable(items),

              pw.SizedBox(height: 16),

              // Total
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'TOTAL: ',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    _formatCurrency(invoice['total'] ?? 0),
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),

              pw.Spacer(),

              // Footer
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Terima kasih atas kepercayaan Anda!',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Save PDF to device
  static Future<File> savePdf(Uint8List bytes, String filename) async {
    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Share PDF
  static Future<void> sharePdf(Uint8List bytes, String filename) async {
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  // ========== Helper Methods ==========

  static pw.Widget _buildReceiptHeader(Map<String, dynamic> workshop, pw.ImageProvider? logo) {
    return pw.Column(
      children: [
        if (logo != null)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Image(logo, height: 40),
          ),
        pw.Text(
          workshop['name'] ?? 'WORKSHOP',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          workshop['address'] ?? '',
          style: const pw.TextStyle(fontSize: 9),
          textAlign: pw.TextAlign.center,
          maxLines: 2,
        ),
        pw.Text(
          'Telp: ${workshop['phone'] ?? '-'}',
          style: const pw.TextStyle(fontSize: 9),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  static pw.Widget _buildB5Header(Map<String, dynamic> workshop, pw.ImageProvider? logo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        if (logo != null)
           pw.Image(logo, height: 50),
        
        pw.Spacer(),

        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              workshop['name'] ?? 'WORKSHOP',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(workshop['address'] ?? '', style: const pw.TextStyle(fontSize: 10)),
            pw.Text('Telp: ${workshop['phone'] ?? '-'}', style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildDivider() {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Text(
        '--------------------------------',
        style: const pw.TextStyle(fontSize: 8),
      ),
    );
  }

  static pw.Widget _buildDoubleDivider() {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Text(
        '================================',
        style: const pw.TextStyle(fontSize: 8),
      ),
    );
  }

  static pw.Widget _buildReceiptRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('$label:', style: const pw.TextStyle(fontSize: 9)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }

  static pw.Widget _buildReceiptItem(Map<String, dynamic> item) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          item['name'] ?? '',
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              '  ${item['quantity'] ?? 1}x',
              style: const pw.TextStyle(fontSize: 9),
            ),
            pw.Text(
              _formatCurrency(item['subtotal'] ?? 0),
              style: const pw.TextStyle(fontSize: 9),
            ),
          ],
        ),
        _buildDivider(),
      ],
    );
  }

  static pw.Widget _buildB5Section(String title, List<String> lines) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        ...lines.map((line) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Text(line, style: const pw.TextStyle(fontSize: 10)),
        )).toList(),
      ],
    );
  }

  static pw.Widget _buildB5ItemsTable(List<Map<String, dynamic>> items) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('Item', isHeader: true),
            _buildTableCell('Qty', isHeader: true),
            _buildTableCell('Harga', isHeader: true, align: pw.TextAlign.right),
            _buildTableCell('Subtotal', isHeader: true, align: pw.TextAlign.right),
          ],
        ),
        // Items
        ...items.map((item) {
          return pw.TableRow(
            children: [
              _buildTableCell(item['name'] ?? ''),
              _buildTableCell('${item['quantity'] ?? 1}'),
              _buildTableCell(_formatCurrency(_safeDouble(item['subtotal']) / _safeDouble(item['quantity'], 1)), align: pw.TextAlign.right),
              _buildTableCell(_formatCurrency(item['subtotal']), align: pw.TextAlign.right),
            ],
          );
        }).toList(),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: align,
      ),
    );
  }

  static String _formatCurrency(dynamic amount) {
    final val = _safeDouble(amount);
    final value = val.toInt();
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  static double _safeDouble(dynamic value, [double defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  static String _formatDate(dynamic dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString.toString());
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString.toString();
    }
  }
}
