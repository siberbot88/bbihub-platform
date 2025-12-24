// core/models/vehicle.dart

class Vehicle {
  final String id;
  final String? customerUuid;
  final String? code;
  final String? name;
  final String? type;
  final String? category;
  final String? brand;
  final String? model;
  final String? year;
  final String? color;
  final String? plateNumber;
  final int? odometer;

  Vehicle({
    required this.id,
    this.customerUuid,
    this.code,
    this.name,
    this.type,
    this.category,
    this.brand,
    this.model,
    this.year,
    this.color,
    this.plateNumber,
    this.odometer,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic v) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String && v.isNotEmpty) return int.tryParse(v);
      return null;
    }

    return Vehicle(
      id: (json['id'] ?? '').toString(),
      customerUuid: json['customer_uuid']?.toString(),
      code: json['code']?.toString(),
      name: json['name']?.toString(),
      type: json['type']?.toString(),           // <= penting
      category: json['category']?.toString(),   // <= penting
      brand: json['brand']?.toString(),
      model: json['model']?.toString(),
      year: json['year']?.toString(),           // varchar -> String
      color: json['color']?.toString(),
      plateNumber: json['plate_number']?.toString(),
      odometer: toInt(json['odometer']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (customerUuid != null) 'customer_uuid': customerUuid,
    if (code != null) 'code': code,
    if (name != null) 'name': name,
    if (type != null) 'type': type,
    if (category != null) 'category': category,
    if (brand != null) 'brand': brand,
    if (model != null) 'model': model,
    if (year != null) 'year': year,
    if (color != null) 'color': color,
    if (plateNumber != null) 'plate_number': plateNumber,
    if (odometer != null) 'odometer': odometer,
  };
}
