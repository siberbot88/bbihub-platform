import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/invoice_item.dart';
import '../utils/currency_idr.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/billing_empty_state.dart';
import '../widgets/billing_item_card.dart';
import '../widgets/technician_notes_field.dart';
import '../widgets/invoice_bottom_bar.dart';
import '../sheets/add_edit_item_sheet.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  // State
  final List<InvoiceItem> _items = [];
  final TextEditingController _notesController = TextEditingController();

  double get _subtotal {
    return _items.fold(0, (sum, item) => sum + item.total);
  }

  void _addItem() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditItemSheet(
        onSave: (newItem) {
          setState(() {
            _items.add(newItem);
          });
        },
      ),
    );
  }

  void _editItem(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditItemSheet(
        itemToEdit: _items[index],
        onSave: (updatedItem) {
          setState(() {
            _items[index] = updatedItem;
          });
        },
      ),
    );
  }

  void _deleteItem(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Hapus Item", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: Text("Anda yakin ingin menghapus item ini?", style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal", style: GoogleFonts.inter(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _items.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: Text("Hapus", style: GoogleFonts.inter(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleSend() {
    // Action implementation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invoice dikirim! Total: ${CurrencyIdr.format(_subtotal)}')),
    );
  }
  
  // Debug helper to pre-fill data as per Screen B
  @override
  void initState() {
    super.initState();
    // Uncomment to start with Empty State (Screen A)
    // _items.clear(); 
    
    // Uncomment to start with Populated State (Screen B)
    /*
    _items.addAll([
       InvoiceItem(
         id: '1', name: 'Servis besar', type: InvoiceItemType.service, 
         qty: 1, unitPrice: 450000
       ),
       InvoiceItem(
         id: '2', name: 'Ganti kampas rem', type: InvoiceItemType.sparepart, 
         qty: 1, unitPrice: 250000
       ),
       InvoiceItem(
         id: '3', name: 'Ganti ban belakang', type: InvoiceItemType.sparepart, 
         qty: 1, unitPrice: 380000
       ),
    ]);
    _notesController.text = "Perlu perawatan dan pengecekan rutin setiap 3 bulan sekali kedepannya.";
    */
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          "Buat Invoice",
          style: GoogleFonts.inter(
            color: const Color(0xFF111827),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () {},
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E7EB), height: 1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF6B7280)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Order Summary
                  const OrderSummaryCard(),
                  const SizedBox(height: 24),

                  // 2. Item Tagihan Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Item Tagihan",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (_items.isNotEmpty)
                        Text(
                          "${_items.length} item",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 3. Item List or Empty State
                  if (_items.isEmpty)
                    BillingEmptyState(onAdd: _addItem)
                  else ...[
                    // Animated List could be nice, but simple Column works for "pixel perfect" snapshot
                    ..._items.asMap().entries.map((entry) {
                      return BillingItemCard(
                        item: entry.value,
                        onEdit: () => _editItem(entry.key),
                        onDelete: () => _deleteItem(entry.key),
                      );
                    }),
                    
                    // Add Button below list
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _addItem,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFFD1D5DB), style: BorderStyle.solid), // Dashed implied by design logic but standard solid is visible in Screen B image usually or explicitly dashed. Screen B description: "Tombol Tambah Item tampil di bawah list, style border putus-putus".
                          // Ah, Screen B says "border putus-putus". OutlinedButton is solid.
                          // I should use DottedBorder or CustomPaint if I want exact match. 
                          // Or just style it to look like the Empty State button?
                          // The empty state button in design is "Tambah Item". 
                          // The filled state "Tambah Item" below list: "style border putus-putus".
                          // I'll reuse a similar style or a custom container.
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          foregroundColor: const Color(0xFFEF4444),
                        ),
                        icon: const Icon(Icons.add_circle_outline),
                        label: Text(
                          "Tambah Item",
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // 4. Technician Notes
                  Text(
                    "Catatan Teknisi",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TechnicianNotesField(controller: _notesController),
                  
                  // Bottom Padding to ensure notes aren't partially obscured if we had a floating bar
                  // Since we are using Column, this is less critical, but good for aesthetics.
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          
          // Sticky Bottom Bar
          InvoiceBottomBar(
            subtotal: _subtotal,
            onSend: _handleSend,
          ),
        ],
      ),
    );
  }
}
