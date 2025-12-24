class TransactionItem {
  final String id;
  final String? name;
  final String? serviceTypeName;
  final num price;
  final int quantity;
  final num subtotal;

  TransactionItem({
    required this.id,
    this.name,
    this.serviceTypeName,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> j) {
    num parseNum(dynamic v) {
      if (v is num) return v;
      if (v is String) return num.tryParse(v) ?? 0;
      return 0;
    }

    int parseIntVal(dynamic v) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    String? serviceTypeName() {
      final st = j['service_type'];
      if (st is Map && st['name'] != null) {
        return st['name'].toString();
      }
      if (j['service_type_name'] != null) {
        return j['service_type_name'].toString();
      }
      return null;
    }

    return TransactionItem(
      id: (j['id'] ?? '').toString(),
      name: j['name']?.toString(),
      serviceTypeName: serviceTypeName(),
      price: parseNum(j['price']),
      quantity: parseIntVal(j['quantity'] ?? j['qty']),
      subtotal: parseNum(j['subtotal'] ?? j['total']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (name != null) 'name': name,
    if (serviceTypeName != null) 'service_type_name': serviceTypeName,
    'price': price,
    'quantity': quantity,
    'subtotal': subtotal,
  };

  int get qty => quantity;
  num get total => subtotal;
}
