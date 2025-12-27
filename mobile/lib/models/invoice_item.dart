class InvoiceItem {
  final String id;
  final String name;
  final InvoiceItemType type;
  final int qty;
  final double unitPrice;
  final String? notes;

  InvoiceItem({
    required this.id,
    required this.name,
    required this.type,
    required this.qty,
    required this.unitPrice,
    this.notes,
  });

  double get total => qty * unitPrice;

  InvoiceItem copyWith({
    String? id,
    String? name,
    InvoiceItemType? type,
    int? qty,
    double? unitPrice,
    String? notes,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      qty: qty ?? this.qty,
      unitPrice: unitPrice ?? this.unitPrice,
      notes: notes ?? this.notes,
    );
  }
}

enum InvoiceItemType {
  service,
  sparepart,
}
