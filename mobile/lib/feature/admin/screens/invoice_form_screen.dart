
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/service.dart';
import '../providers/admin_service_provider.dart';
import '../widgets/invoice/add_item_sheet.dart';
import 'cash_payment_screen.dart';

class InvoiceFormScreen extends StatefulWidget {
  final ServiceModel? service; // Make nullable to conform, but we expect it passed
  final String serviceId;
  final String serviceType; // 'booking' or 'on-site'

  const InvoiceFormScreen({
    super.key,
    this.service,
    required this.serviceId,
    required this.serviceType,
  });

  @override
  State<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  final List<InvoiceItemMap> _items = [];
  final TextEditingController _notesController = TextEditingController();
  
  bool _isLoading = false;
  late ServiceModel? _localService;

  @override
  void initState() {
    super.initState();
    _localService = widget.service;
    // If service not passed, we should ideally fetch it, but usually passed from detail
    if (_localService == null) {
      _fetchService();
    }
  }

  Future<void> _fetchService() async {
    try {
      final s = await context.read<AdminServiceProvider>().performFetchServiceDetail(widget.serviceId);
      setState(() => _localService = s);
    } catch (_) {}
  }

  double get _subtotal => _items.fold(0, (sum, item) => sum + (item.subtotal));
  double get _total => _subtotal; // Can add tax logic later if needed again

  // Currency Formatter
  final NumberFormat _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final DateFormat _dateFormat = DateFormat('d MMMM yyyy', 'id_ID');

  void _showAddItemSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddItemSheet(
        onItemAdded: (itemData) {
          setState(() {
            _items.add(InvoiceItemMap(
              type: itemData['type'],
              name: itemData['name'],
              quantity: itemData['quantity'],
              unitPrice: itemData['unit_price'],
              description: itemData['description'],
              subtotal: itemData['subtotal'],
            ));
          });
        },
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _submitInvoice() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal harus ada 1 item')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<AdminServiceProvider>();
      
      // STEP 1: Ensure Service is Completed
      // API requires service to be 'completed' before creating invoice.
      final currentStatus = (_localService?.status ?? '').toLowerCase();
      if (currentStatus != 'completed' && currentStatus != 'done') {
        try {
          final updatedService = await provider.completeService(widget.serviceId);
          if (mounted) {
            setState(() => _localService = updatedService);
          }
        } catch (e) {
          // If completion fails, we might not be able to proceed, but we'll try creating invoice 
          // to let the backend validation return the specific error if it persists.
          debugPrint('Warning: Auto-complete service failed: $e');
        }
      }

      // STEP 2: Create Invoice
      final itemsData = _items.map((item) => {
        'type': item.type,
        'name': item.name,
        'description': item.description,
        'quantity': item.quantity,
        'unit_price': item.unitPrice,
      }).toList();

      final result = await provider.createInvoice(
        widget.serviceId,
        items: itemsData,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (!mounted) return;

      // Navigate based on service type
      if (widget.serviceType == 'on-site' || widget.serviceType == 'ditempat') {
        // Go to cash payment screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => CashPaymentScreen(
              invoiceId: result['invoice_id'],
              total: double.tryParse(result['total'].toString()) ?? 0.0,
              invoiceCode: result['invoice_code'] ?? '',
              service: _localService, // Pass service for UI
            ),
          ),
        );
      } else {
        // Booking - invoice sent to customer
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice berhasil dikirim ke customer')),
        );
        Navigator.of(context).pop(true); // Go back with success
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Background light
      appBar: AppBar(
        title: const Text('Buat Invoice', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[200], height: 1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Scrollable Content
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 180), // Padding bottom for footer
                  child: Column(
                    children: [
                      _buildOrderSummary(),
                      const SizedBox(height: 24),
                      _buildItemsSection(),
                      const SizedBox(height: 24),
                      _buildNotesSection(),
                    ],
                  ),
                ),

                // Sticky Footer
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildFooter(),
                ),
              ],
            ),
    );
  }

  Widget _buildOrderSummary() {
    final s = _localService;
    final dateStr = s?.scheduledDate != null 
        ? _dateFormat.format(s!.scheduledDate!) 
        : '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
           BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ringkasan Order', style: AppTextStyles.heading4()),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  s?.code ?? '#ORD-PENDING',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Row 1
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text('Pelanggan', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                     const SizedBox(height: 4),
                     Text(s?.customer?.name ?? s?.displayCustomerName ?? '-', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text('Kendaraan', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                     const SizedBox(height: 4),
                     Text(s?.displayVehicleName ?? '-', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  ],
                ),
              ),
            ],
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),

          // Row 2
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text('Tanggal', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                     const SizedBox(height: 4),
                     Text(dateStr, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text('Teknisi', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                     const SizedBox(height: 8),
                     Row(
                       children: [
                         CircleAvatar(
                           radius: 12,
                           backgroundColor: Colors.grey[200],
                           backgroundImage: (s?.mechanic?.photoUrl != null) ? NetworkImage(s!.mechanic!.photoUrl!) : null,
                           child: (s?.mechanic?.photoUrl == null) ? const Icon(Icons.person, size: 14, color: Colors.grey) : null,
                         ),
                         const SizedBox(width: 8),
                         Flexible(
                           child: Text(
                             s?.mechanic?.name ?? 'Teknisi',
                             style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                             overflow: TextOverflow.ellipsis,
                           ),
                         ),
                       ],
                     ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Item Tagihan', style: AppTextStyles.heading4()),
              if (_items.isNotEmpty)
                Text('${_items.length} item', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
        
        if (_items.isEmpty) 
          _buildEmptyState()
        else 
          Column(
            children: [
              ..._items.asMap().entries.map((e) => _buildItemCard(e.key, e.value)),
              
              const SizedBox(height: 12),
              
              // Add Item Button (Outline style when list populated)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showAddItemSheet,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Tambah Item'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: Colors.grey[300]!, style: BorderStyle.none), // Using internal dashed border via CustomPaint is overkill, referencing screenshot style
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryRed,
                    elevation: 0,
                  ).copyWith(
                    side: MaterialStateProperty.all(BorderSide(color: Colors.grey[300]!)),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid), // Dashed border usually needed but solid okay for MVP
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long, size: 32, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          const Text('Belum ada item', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Tambahkan sparepart atau jasa\nuntuk menghitung total.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddItemSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[100],
              foregroundColor: AppColors.primaryRed,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Tambah Item'),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(int index, InvoiceItemMap item) {
    bool isService = item.type == 'service';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
           BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Expanded(
                 child: Text(
                   item.name,
                   style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                 ),
               ),
               GestureDetector(
                 onTap: () => _removeItem(index),
                 child: Icon(Icons.more_vert, size: 20, color: Colors.grey[400]),
               ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                 decoration: BoxDecoration(
                   color: isService ? Colors.blue[50] : Colors.orange[50], // Blue for Service, Orange for Parts
                   borderRadius: BorderRadius.circular(4),
                 ),
                 child: Text(
                   isService ? 'Jasa' : 'Sparepart',
                   style: TextStyle(
                     fontSize: 11,
                     fontWeight: FontWeight.bold,
                     color: isService ? Colors.blue[700] : Colors.orange[700],
                   ),
                 ),
              ),
              Text(
                _currency.format(item.subtotal),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text('Catatan Teknisi', style: AppTextStyles.heading4()),
        ),
        Stack(
          children: [
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Masukkan catatan tambahan...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text('Opsional', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[100]!)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Tagihan', style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500)),
                  Text('Subtotal: ${_currency.format(_subtotal)}', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                ],
              ),
              Text(
                _currency.format(_total), 
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: (_items.isEmpty || _isLoading) ? null : _submitInvoice,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: AppColors.primaryRed.withOpacity(0.4),
            ),
            child: _isLoading 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Kirim Invoice', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      const Icon(Icons.send, size: 20),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// Temporary internal model for Map
class InvoiceItemMap {
  final String type;
  final String name;
  final int quantity;
  final double unitPrice;
  final String description;
  final double subtotal;

  InvoiceItemMap({
    required this.type,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.description,
    required this.subtotal,
  });
}
