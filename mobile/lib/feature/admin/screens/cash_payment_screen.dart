import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/service.dart';
import '../providers/admin_service_provider.dart';
import '../../../../core/services/pdf_service.dart';
import 'dart:typed_data';

class CashPaymentScreen extends StatefulWidget {
  final String invoiceId;
  final double total;
  final String invoiceCode;
  final ServiceModel? service; 

  const CashPaymentScreen({
    super.key,
    required this.invoiceId,
    required this.total,
    this.invoiceCode = '',
    this.service,
  });

  @override
  State<CashPaymentScreen> createState() => _CashPaymentScreenState();
}

class _CashPaymentScreenState extends State<CashPaymentScreen> {
  bool _isLoading = false;
  bool _isSuccess = false; // Controls "Success Animation" view
  bool _isPaid = false;    // Controls "Receipt Mode" vs "Payment Mode"
  Map<String, dynamic>? _invoiceDetail;

  // Formatters
  final NumberFormat _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final DateFormat _dateFormat = DateFormat('d MMM yyyy', 'id_ID');

  @override
  void initState() {
    super.initState();
    _fetchInvoiceDetails();
  }

  Future<void> _fetchInvoiceDetails() async {
    // Determine initial paid status from Service/Transaction passed in widget
    if (widget.service != null) {
       final s = widget.service!;
       final isTxSuccess = s.transaction != null && 
          (s.transaction!['status'] == 'success' || s.transaction!['status'] == 'paid');
       final isStatusPaid = ['lunas'].contains((s.status ?? '').toLowerCase());
       
       if (isTxSuccess || isStatusPaid) {
         setState(() => _isPaid = true);
       }
    }

    if (widget.service == null) return;
    try {
      final data = await context.read<AdminServiceProvider>().fetchInvoiceByService(widget.service!.id);
      if (mounted) {
        setState(() {
          _invoiceDetail = data;
          if (_invoiceDetail?['status'] == 'paid' || _invoiceDetail?['status'] == 'success') {
             _isPaid = true;
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching invoice: $e");
    }
  }

  void _showCashInputSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CashInputSheet(
        total: widget.total,
        onPay: (amount) => _processPayment(amount),
      ),
    );
  }

  Future<void> _processPayment(double amountPaid) async {
    Navigator.pop(context); // Close sheet
    setState(() => _isLoading = true);

    try {
      final provider = context.read<AdminServiceProvider>();
      await provider.processCashPayment(widget.invoiceId, amountPaid);

      if (!mounted) return;
      
      // Update state to PAID and show Success View
      await _fetchInvoiceDetails(); // Refresh to ensure data consistency
      setState(() {
        _isLoading = false;
        _isSuccess = true;
        _isPaid = true;
      });

    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // If just finished payment successfully, show Success Screen
    if (_isSuccess) {
      return _buildSuccessView();
    }

    final invoiceData = _invoiceDetail ?? widget.service?.invoice;
    final items = (invoiceData?['items'] as List?) ?? [];
    
    // Data extraction
    final vehicleName = widget.service?.displayVehicleName ?? 'Motor';
    final vehiclePlate = widget.service?.displayVehiclePlate ?? '';
    final customerName = widget.service?.customer?.name ?? widget.service?.displayCustomerName ?? 'Customer';
    final customerAddress = widget.service?.customer?.address ?? '';
    final customerPhone = widget.service?.customer?.phone ?? '';
    final invoiceCode = widget.invoiceCode.isNotEmpty ? widget.invoiceCode : (invoiceData?['invoice_code'] ?? 'INV-Pending');
    final invoiceDate = invoiceData?['created_at'] != null 
        ? _dateFormat.format(DateTime.parse(invoiceData!['created_at']))
        : _dateFormat.format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.primaryRed,
      body: Stack(
        children: [
          // Background Header (Expanded)
          Positioned(
            top: 0, left: 0, right: 0, height: 340, // Increased height
            child: Container(
              color: AppColors.primaryRed,
              padding: const EdgeInsets.fromLTRB(24, 50, 24, 0), // Adjusted top padding slightly
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Navigation Row
                   Row(
                     children: [
                       IconButton(
                         icon: const Icon(Icons.arrow_back, color: Colors.white),
                         onPressed: () => Navigator.pop(context),
                         padding: EdgeInsets.zero,
                         alignment: Alignment.centerLeft,
                       ),
                       const Spacer(),
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.end,
                         children: [
                           if (vehiclePlate.isNotEmpty)
                             Text(
                               "LP: $vehiclePlate",
                               style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
                             ),
                         ],
                       )
                     ],
                   ),
                   const SizedBox(height: 10), // Reduced spacing
                   
                   // Receipt Title / Badge
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                     decoration: BoxDecoration(
                       color: Colors.white.withOpacity(0.2),
                       borderRadius: BorderRadius.circular(20),
                     ),
                     child: const Text(
                       "INVOICE",
                       style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                     ),
                   ),
                   const SizedBox(height: 12),
                   
                   // Vehicle Name (Large)
                   Expanded( // Use Expanded to avoid overflow usage, though Column size is fixed
                     child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                             vehicleName.toUpperCase(),
                             maxLines: 2,
                             overflow: TextOverflow.ellipsis,
                             style: const TextStyle(
                               color: Colors.white,
                               fontSize: 28, // Slightly reduced from 32
                               fontWeight: FontWeight.w900,
                               height: 1.1, 
                             ),
                           ),
                           const SizedBox(height: 8),
                           // Invoice Code
                           Text(
                             invoiceCode,
                             style: TextStyle(
                               color: Colors.white.withOpacity(0.8),
                               fontSize: 14,
                               letterSpacing: 0.5,
                               fontFamily: 'monospace',
                             ),
                           ),
                        ],
                     ),
                   ),
                ],
              ),
            ),
          ),

          // Main Content Card
          Positioned(
            top: 290, // Pushed down to reveal header content
            left: 0, right: 0, bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF9FAFB),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(), // Enable scrolling always
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 150), // Increased bottom padding
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Customer Section
                          _AnimatedEntry(
                            delay: 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'INVOICE FOR',
                                  style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  customerName,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                                ),
                                if (customerAddress.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    customerAddress,
                                    style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                                  ),
                                ],
                                if (customerPhone.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    customerPhone,
                                    style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Total Card
                          _AnimatedEntry(
                            delay: 200, 
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6), 
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'TOTAL TAGIHAN',
                                        style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                                      ),
                                      const SizedBox(height: 4),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: 'Rp ', 
                                              style: TextStyle(color: Color(0xFF111827), fontSize: 16, fontWeight: FontWeight.bold)
                                            ),
                                            TextSpan(
                                              text: _currency.format(widget.total).replaceAll('Rp ', ''),
                                              style: const TextStyle(color: Color(0xFF111827), fontSize: 24, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Date Box
                                  Container(
                                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                     decoration: BoxDecoration(
                                       color: Colors.white,
                                       borderRadius: BorderRadius.circular(8),
                                       border: Border.all(color: Colors.grey[300]!),
                                     ),
                                     child: Row(
                                       children: [
                                         Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                                         const SizedBox(width: 6),
                                         Text(invoiceDate, style: TextStyle(fontSize: 12, color: Colors.grey[800], fontWeight: FontWeight.w600)),
                                       ],
                                     ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Divider(height: 1, color: Color(0xFFE5E7EB)),
                          const SizedBox(height: 32),
                          
                          // Items Header
                          _AnimatedEntry(
                            delay: 300,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'DAFTAR PERBAIKAN',
                                  style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                                ),
                                Text('TOTAL', style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Items List
                          ...items.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final item = entry.value;
                            return _AnimatedEntry(
                              delay: 300 + (idx * 50),
                              child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item['name'] ?? 'Jasa/Part', 
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    _currency.format(double.tryParse('${item['subtotal'] ?? item['price']}') ?? 0),
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                                  ),
                                ],
                              ),
                              ),
                            );
                          }).toList(),
                          
                          const SizedBox(height: 24),
                          
                          // Technician Notes (Conditional)
                          if (widget.service?.note != null && widget.service!.note!.trim().isNotEmpty) ...[
                            _AnimatedEntry(
                              delay: 500,
                              child: _buildNotesSection(widget.service?.note),
                            ),
                            const SizedBox(height: 24),
                          ],
                          
                          // Bottom Status Section (if needed, or maybe just "Total Amount" large text)
                          if (!_isPaid) 
                            _AnimatedEntry(
                              delay: 600,
                              child: _buildStatusCard(),
                            ),
                            
                          if (_isPaid)
                            Align(
                              alignment: Alignment.centerRight,
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.end,
                                 children: [
                                   Text("TOTAL AMOUNT", style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.bold)),
                                   const SizedBox(height: 4),
                                   Text(
                                     _currency.format(widget.total),
                                     style: const TextStyle(color: Color(0xFF111827), fontSize: 24, fontWeight: FontWeight.bold),
                                   ),
                                 ],
                               ),
                            ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Sticky Footer
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
               padding: const EdgeInsets.all(24),
               decoration: BoxDecoration(
                 color: Colors.white,
                 boxShadow: [
                   BoxShadow(
                     color: Colors.black.withOpacity(0.05),
                     blurRadius: 20,
                     offset: const Offset(0, -4),
                   ),
                 ],
               ),
               child: _isLoading 
                 ? const Center(child: CircularProgressIndicator())
                 : _buildFooterActions(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterActions() {
    if (_isPaid) {
      return ElevatedButton(
        onPressed: _handleExport,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: AppColors.primaryRed.withOpacity(0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.download, size: 20),
            SizedBox(width: 8),
            Text('UNDUH NOTA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    final isBooking = (widget.service?.type != 'on-site' && widget.service?.type != 'ditempat');
    
    if (isBooking) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.orange[50], 
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange[200]!)
        ),
        child: Column(
          children: [
            const Icon(Icons.app_blocking_outlined, color: Colors.orange),
             const SizedBox(height: 8),
            const Text("Menunggu Pembayaran Customer", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
             const SizedBox(height: 4),
            Text("Booking via Aplikasi", style: TextStyle(fontSize: 12, color: Colors.orange[800])),
          ],
        ),
      );
    }

    return Column(
      children: [
        ElevatedButton(
          onPressed: _showCashInputSheet,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            shadowColor: AppColors.primaryRed.withOpacity(0.4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('Lanjutkan Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Batalkan Pembayaran', style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  void _handleExport() {
    if (_invoiceDetail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data invoice belum siap. Tunggu sebentar...')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                'Pilih Format Unduhan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.picture_as_pdf, color: Colors.blue),
              ),
              title: const Text('Invoice Standar (B5)'),
              subtitle: const Text('Format resmi dengan logo & detail lengkap'),
              onTap: () {
                Navigator.pop(context);
                _generateAndSharePdf('b5');
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.receipt_long, color: Colors.black87),
              ),
              title: const Text('Struk Thermal (80mm)'),
              subtitle: const Text('Format kasir hemat kertas (Hitam Putih)'),
              onTap: () {
                Navigator.pop(context);
                _generateAndSharePdf('thermal');
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _generateAndSharePdf(String type) async {
    setState(() => _isLoading = true);
    
    try {
      final invoice = _invoiceDetail!;
      
      // Extract data from root level (Refactored Backend Structure)
      var workshop = invoice['workshop'] as Map<String, dynamic>? ?? {};
      var customer = invoice['customer'] as Map<String, dynamic>? ?? {};
      
      var service = invoice['service'] as Map<String, dynamic>? ?? {};
      var vehicle = service['vehicle'] as Map<String, dynamic>? ?? {};
      
      // Fallback: Use local service data if backend invoice relations are missing
      if (customer.isEmpty && widget.service?.customer != null) {
        customer = widget.service!.customer!.toJson();
      }
      
      if (vehicle.isEmpty && widget.service?.vehicle != null) {
        vehicle = widget.service!.vehicle!.toJson();
      }

      // Check for workshop name fallback
      if (workshop.isEmpty && widget.service?.workshopName != null) {
         workshop = {'name': widget.service!.workshopName!};
      }
      
      // Items are at root level in new resource
      final itemsRaw = invoice['items'] as List?;
      final items = itemsRaw?.map((e) => e as Map<String, dynamic>).toList() ?? [];

      Uint8List bytes;

      if (type == 'b5') {
        bytes = await PdfService.generateB5Invoice(
          invoice: invoice,
          workshop: workshop,
          customer: customer,
          vehicle: vehicle,
          items: items,
        );
      } else {
        // Thermal
        bytes = await PdfService.generateThermalReceipt(
          invoice: invoice,
          workshop: workshop,
          customer: customer,
          vehicle: vehicle,
          items: items,
        );
      }

      final filename = '${type == "b5" ? "Invoice" : "Struk"}_${invoice['code'] ?? 'INV'}.pdf';
      await PdfService.sharePdf(bytes, filename);
      
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat PDF: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildCustomerSection() {
    // Unused in new layout, logic moved inline to main build to allow better control
    return const SizedBox.shrink(); 
  }

  Widget _buildTotalCard() {
    // Unused in new layout, logic swapped inline
    return const SizedBox.shrink();
  }
  
  // Updated Build Notes
  Widget _buildNotesSection(String? note) {
    if (note == null || note.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CATATAN TEKNISI',
          style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(
            note, 
            style: const TextStyle(color: Color(0xFF4B5563), height: 1.5),
          ),
        ),
      ],
    );
  }


  Widget _buildStatusCard() {
    if (_isPaid) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green[100]!),
        ),
        child: Row(
          children: [
            Container(
               margin: const EdgeInsets.only(right: 12),
               height: 40, width: 40,
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.check_circle, color: Colors.green[700]),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LUNAS',
                    style: TextStyle(color: Colors.green[800], fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pembayaran telah diterima.',
                    style: TextStyle(color: Colors.green[800]?.withOpacity(0.8), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange[100]!),
      ),
      child: Row(
        children: [
          Container(
             margin: const EdgeInsets.only(right: 12),
             height: 40, width: 40,
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.access_time_filled, color: Colors.orange[700]),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MENUNGGU PEMBAYARAN',
                  style: TextStyle(color: Colors.orange[800], fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Silakan lakukan pembayaran.',
                  style: TextStyle(color: Colors.orange[800]?.withOpacity(0.8), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Scaffold(
      backgroundColor: AppColors.primaryRed,
      body: Stack(
         children: [
           Container(
             color: AppColors.primaryRed,
             height: 300,
           ),
           SafeArea(
             child: Column(
               children: [
                 const SizedBox(height: 40),
                 const Center(
                   child: Text(
                     'Pembayaran Berhasil!',
                     style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                   ),
                 ),
                 const SizedBox(height: 40),
                 Expanded(
                   child: Container(
                     width: double.infinity,
                     margin: const EdgeInsets.symmetric(horizontal: 24),
                     decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(24),
                       boxShadow: [
                         BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
                       ],
                     ),
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Container(
                           padding: const EdgeInsets.all(24),
                           decoration: BoxDecoration(
                             color: Colors.green[50],
                             shape: BoxShape.circle,
                           ),
                           child: const Icon(Icons.check_circle, size: 64, color: Colors.green),
                         ),
                         const SizedBox(height: 24),
                         Text(
                           _currency.format(widget.total),
                           style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                         ),
                         Text(
                           'Telah dibayar tunai',
                           style: TextStyle(color: Colors.grey[500]),
                         ),
                         const SizedBox(height: 48),
                         Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 32),
                           child: ElevatedButton(
                             onPressed: () {
                               // Switch to Receipt Mode within the same screen
                               setState(() => _isSuccess = false);
                             },
                             style: ElevatedButton.styleFrom(
                               backgroundColor: AppColors.primaryRed,
                               foregroundColor: Colors.white,
                               minimumSize: const Size(double.infinity, 54),
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                             ),
                             child: const Text('Lihat Nota & Cetak'),
                           ),
                         ),
                         const SizedBox(height: 16),
                         TextButton(
                           onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                           child: const Text("Kembali ke Menu Utama", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                         )
                       ],
                     ),
                   ),
                 ),
                 const SizedBox(height: 40),
               ],
             ),
           ),
         ],
      ),
    );
  }
}

class _CashInputSheet extends StatefulWidget {
  final double total;
  final Function(double) onPay;

  const _CashInputSheet({required this.total, required this.onPay});

  @override
  State<_CashInputSheet> createState() => _CashInputSheetState();
}

class _CashInputSheetState extends State<_CashInputSheet> {
  final TextEditingController _amountController = TextEditingController();
  double get _amount => double.tryParse(_amountController.text) ?? 0;
  double get _change => _amount - widget.total;
  bool get _isValid => _amount >= widget.total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24, 
        bottom: MediaQuery.of(context).viewInsets.bottom + 24
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Masukkan Nominal Cash', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              prefixText: 'Rp ',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              hintText: '0',
            ),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          if (_amount > 0)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                color: _change >= 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _change >= 0 ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _change >= 0 ? 'Kembalian:' : 'Kurang:',
                    style: TextStyle(
                      color: _change >= 0 ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Rp ${NumberFormat('#,###', 'id_ID').format(_change.abs())}',
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      color: _change >= 0 ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isValid ? () => widget.onPay(_amount) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Bayar Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _AnimatedEntry extends StatefulWidget {
  final Widget child;
  final int delay;

  const _AnimatedEntry({required this.child, required this.delay});

  @override
  State<_AnimatedEntry> createState() => _AnimatedEntryState();
}

class _AnimatedEntryState extends State<_AnimatedEntry> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
