import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/invoice_item.dart';
import '../utils/currency_idr.dart';

class AddEditItemSheet extends StatefulWidget {
  final InvoiceItem? itemToEdit;
  final Function(InvoiceItem) onSave;

  const AddEditItemSheet({
    super.key,
    this.itemToEdit,
    required this.onSave,
  });

  @override
  State<AddEditItemSheet> createState() => _AddEditItemSheetState();
}

class _AddEditItemSheetState extends State<AddEditItemSheet> {
  // Colors
  final Color _primaryRed = const Color(0xFFEF4444);
  final Color _border = const Color(0xFFE5E7EB);
  final Color _textSecondary = const Color(0xFF6B7280);

  // State
  late InvoiceItemType _selectedType;
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _notesController;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    final item = widget.itemToEdit;
    if (item != null) {
      _selectedType = item.type;
      _nameController = TextEditingController(text: item.name);
      _priceController = TextEditingController(
        text: CurrencyIdr.formatNoSymbol(item.unitPrice),
      );
      _notesController = TextEditingController(text: item.notes);
      _qty = item.qty;
    } else {
      _selectedType = InvoiceItemType.service;
      _nameController = TextEditingController();
      _priceController = TextEditingController();
      _notesController = TextEditingController();
      _qty = 1;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double _parsePrice() {
    String clean = _priceController.text.replaceAll('.', '');
    return double.tryParse(clean) ?? 0;
  }

  void _handleSave() {
    final name = _nameController.text.trim();
    final price = _parsePrice();

    if (name.isEmpty || price <= 0) return;

    final newItem = InvoiceItem(
      id: widget.itemToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: _selectedType,
      qty: _qty,
      unitPrice: price,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    widget.onSave(newItem);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total for read-only field
    final total = _qty * _parsePrice();
    final bool isValid = _nameController.text.trim().isNotEmpty && _parsePrice() > 0;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(
                  widget.itemToEdit != null ? "Ubah Item" : "Tambah Item",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                    letterSpacing: -0.5,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: _textSecondary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 24,
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),

          // Scrollable fields
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24, 
                24, 
                24, 
                MediaQuery.of(context).viewInsets.bottom + 100 // Padding for bottom buttons
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type Segmented Control
                  _buildLabel("Tipe Item"),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _buildSegmentButton(
                          "Jasa", 
                          InvoiceItemType.service,
                        ),
                        _buildSegmentButton(
                          "Sparepart", 
                          InvoiceItemType.sparepart,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Name
                  _buildLabel("Nama item", isRequired: true),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    onChanged: (_) => setState(() {}),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: const Color(0xFF111827),
                    ),
                    decoration: _inputDecoration("Contoh: Kampas Rem Depan"),
                  ),

                  const SizedBox(height: 20),

                  // Qty & Price Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Qty
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Qty", isRequired: true),
                            const SizedBox(height: 8),
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _border),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _qtyButton(
                                    icon: Icons.remove, 
                                    onTap: () {
                                      if (_qty > 1) setState(() => _qty--);
                                    }
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        _qty.toString(),
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF111827),
                                        ),
                                      ),
                                    ),
                                  ),
                                  _qtyButton(
                                    icon: Icons.add,
                                    isAdd: true,
                                    onTap: () {
                                      setState(() => _qty++);
                                    }
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Price
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             _buildLabel("Harga Satuan", isRequired: true),
                             const SizedBox(height: 8),
                             TextField(
                               controller: _priceController,
                               keyboardType: TextInputType.number,
                               onChanged: (val) {
                                  // Simple formatter logic
                                  String clean = val.replaceAll(RegExp(r'[^0-9]'), '');
                                  if (clean.isNotEmpty) {
                                    double val = double.parse(clean);
                                    String formatted = CurrencyIdr.formatNoSymbol(val);
                                    
                                    if (_priceController.text != formatted) {
                                      _priceController.value = TextEditingValue(
                                        text: formatted,
                                        selection: TextSelection.collapsed(offset: formatted.length),
                                      );
                                    }
                                  }
                                  setState(() {});
                               },
                               style: GoogleFonts.inter(
                                 fontSize: 16,
                                 fontWeight: FontWeight.w500,
                                 color: const Color(0xFF111827),
                               ),
                               decoration: _inputDecoration("0").copyWith(
                                 prefixIcon: Padding(
                                   padding: const EdgeInsets.only(left: 16, right: 12),
                                   child: Column(
                                     mainAxisAlignment: MainAxisAlignment.center,
                                     children: [
                                       Text(
                                          "Rp",
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w500,
                                            color: _textSecondary,
                                          ),
                                        ),
                                     ],
                                   ),
                                 ),
                               ),
                             ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Total Item (Read Only)
                  _buildLabel("Total Item"),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          CurrencyIdr.format(total),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _textSecondary,
                          ),
                        ),
                        Icon(Icons.lock_outline, size: 20, color: Colors.grey[400]),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Notes
                  RichText(
                    text: TextSpan(
                      text: "Catatan item ",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: "(Opsional)",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.normal,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    style: GoogleFonts.inter(fontSize: 16),
                    decoration: _inputDecoration("Tambahkan detail spesifik..."),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Buttons (Fixed)
          Container(
            padding: EdgeInsets.fromLTRB(
              24, 
              16, 
              24, 
              MediaQuery.of(context).padding.bottom + 24
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: const Color(0xFF111827),
                    ),
                    child: Text(
                      "Batal",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: isValid ? _handleSave : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryRed,
                      disabledBackgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: isValid ? 4 : 0,
                      shadowColor: _primaryRed.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Simpan Item",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _textSecondary,
        ),
        children: [
          if (isRequired)
            TextSpan(
              text: " *",
              style: GoogleFonts.inter(color: Colors.red),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryRed),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _buildSegmentButton(String label, InvoiceItemType type) {
    final bool isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? const Color(0xFF111827) : _textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap, bool isAdd = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: isAdd 
            ? Border(left: BorderSide(color: _border))
            : Border(right: BorderSide(color: _border)),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isAdd ? _primaryRed : Colors.grey[500],
        ),
      ),
    );
  }
}
