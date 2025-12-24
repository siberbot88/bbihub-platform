enum WorkStatus { pending, process, done }

class WorkItem {
  final String id;
  final String workOrder;
  final String customer;
  final String vehicle;
  final String plate;
  final String service;
  final DateTime? schedule;
  final String mechanic;
  final num? price;
  final WorkStatus status;

  WorkItem({
    required this.id,
    required this.workOrder,
    required this.customer,
    required this.vehicle,
    required this.plate,
    required this.service,
    required this.schedule,
    required this.mechanic,
    required this.price,
    required this.status,
  });
}

/// State filter lanjutan (jenis kendaraan, kategori, urutan)
class AdvancedFilter {
  final String? vehicleType; // 'mobil' | 'motor'
  final String? vehicleCategory; // 'matic', 'suv', dll (lowercase)
  final String sort; // 'newest' | 'oldest' | 'none'

  const AdvancedFilter({
    this.vehicleType,
    this.vehicleCategory,
    this.sort = 'none',
  });

  bool get isEmpty =>
      (vehicleType == null || vehicleType!.isEmpty) &&
      (vehicleCategory == null || vehicleCategory!.isEmpty) &&
      (sort == 'none' || sort.isEmpty);

  AdvancedFilter copyWith({
    String? vehicleType,
    String? vehicleCategory,
    String? sort,
  }) {
    return AdvancedFilter(
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleCategory: vehicleCategory ?? this.vehicleCategory,
      sort: sort ?? this.sort,
    );
  }

  static const empty = AdvancedFilter();
}

String formatDate(DateTime? dt) {
  if (dt == null) return '-';
  const bulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des'
  ];
  final tgl = '${dt.day} ${bulan[dt.month - 1]} ${dt.year}';
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$tgl - $hh:$mm';
}

String formatDateShort(DateTime? dt) {
  if (dt == null) return '-';
  const bulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des'
  ];
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '${dt.day} ${bulan[dt.month - 1]} • $hh:$mm';
}


String formatRupiah(num nominal) {
  final s = nominal.toInt().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final rev = s.length - i;
    buf.write(s[i]);
    if (rev > 1 && rev % 3 == 1) buf.write('.');
  }
  return buf.toString();
}

T? tryOrNull<T>(T Function() f) {
  try {
    return f();
  } catch (_) {
    return null;
  }
}
