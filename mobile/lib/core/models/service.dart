import 'customer.dart';
import 'vehicle.dart';
import 'transaction_item.dart';

/// Referensi teknisi (disediakan backend pada field `mechanic`)
class MechanicRef {
  final String id;
  final String? name;

  MechanicRef({required this.id, this.name});

  factory MechanicRef.fromJson(Map<String, dynamic> json) {
    return MechanicRef(
      id: (json['id'] ?? '').toString(),
      name: json['name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (name != null) 'name': name,
  };
}

class ServiceModel {
  final String id;
  final String code;
  final String name;
  final String? description;
  final num? price;

  /// Tanggal booking / jadwal
  final DateTime? scheduledDate;

  /// Estimasi selesai (optional)
  final DateTime? estimatedTime;

  /// Status utama service:
  /// pending / in progress / completed / menunggu pembayaran / lunas / cancelled
  final String status;

  /// status penerimaan (dari kolom `acceptance_status`)
  final String? acceptanceStatus;

  /// Waktu saat service di-accept (admin)
  final DateTime? acceptedAt;

  /// Waktu saat service dinyatakan completed
  final DateTime? completedAt;

  // referensi id (opsional)
  final String? customerUuid;
  final String? workshopUuid;
  final String? vehicleId;
  final String? mechanicUuid; // <--- dari kolom mechanic_uuid

  // relasi
  final Customer? customer;
  final Vehicle? vehicle;
  final String? workshopName;

  // teknisi (opsional, dari relasi `mechanic`)
  final MechanicRef? mechanic;

  // item transaksi (sparepart/jasa tambahan)
  final List<TransactionItem>? items;

  // catatan dari bengkel
  final String? note;

  /// kolom `category_service` di tabel services
  final String? categoryName;

  final String? reason;
  final String? reasonDescription; // <--- dari kolom reason_description
  final String? feedbackMechanic;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ServiceModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.price,
    this.scheduledDate,
    this.estimatedTime,
    required this.status,
    this.acceptanceStatus,
    this.acceptedAt,
    this.completedAt,
    this.customerUuid,
    this.workshopUuid,
    this.vehicleId,
    this.mechanicUuid,
    this.customer,
    this.vehicle,
    this.workshopName,
    this.mechanic,
    this.items,
    this.note,
    this.categoryName,
    this.reason,
    this.reasonDescription,
    this.feedbackMechanic,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDT(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
      return null;
    }

    String? vehicleId() {
      if (json['vehicle_uuid'] != null) {
        return json['vehicle_uuid'].toString();
      }
      if (json['vehicle_id'] != null) {
        return json['vehicle_id'].toString();
      }
      if (json['vehicleId'] != null) {
        return json['vehicleId'].toString();
      }
      final v = json['vehicle'];
      if (v is Map && v['id'] != null) {
        return v['id'].toString();
      }
      return null;
    }

    // workshop name dari relasi
    String? workshopName() {
      final w = json['workshop'];
      if (w is Map &&
          w['name'] is String &&
          (w['name'] as String).isNotEmpty) {
        return w['name'] as String;
      }
      return null;
    }

    // mechanic dari relasi
    MechanicRef? mechanic() {
      final m = json['mechanic'];
      if (m is Map) {
        return MechanicRef.fromJson(Map<String, dynamic>.from(m));
      }
      return null;
    }

    final itemsJson =
    (json['items'] is List) ? (json['items'] as List) : const <dynamic>[];

    return ServiceModel(
      id: (json['id'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      price: json['price'] is num
          ? json['price']
          : num.tryParse('${json['price']}'),
      scheduledDate: parseDT(json['scheduled_date']),
      estimatedTime: parseDT(json['estimated_time']),
      status: (json['status'] ?? '').toString(),

      /// status & waktu status
      acceptanceStatus: json['acceptance_status']?.toString(),
      acceptedAt: parseDT(json['accepted_at']),
      completedAt: parseDT(json['completed_at']),

      customerUuid: json['customer_uuid']?.toString(),
      workshopUuid: json['workshop_uuid']?.toString(),
      vehicleId: vehicleId(),
      mechanicUuid: json['mechanic_uuid']?.toString(),

      customer: (json['customer'] is Map)
          ? Customer.fromJson(
        Map<String, dynamic>.from(json['customer'] as Map),
      )
          : null,
      vehicle: (json['vehicle'] is Map)
          ? Vehicle.fromJson(
        Map<String, dynamic>.from(json['vehicle'] as Map),
      )
          : null,
      workshopName: workshopName(),
      mechanic: mechanic(),

      items: itemsJson
          .whereType<Map>()
          .map(
            (e) => TransactionItem.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList(),
      note: json['note']?.toString(),

      /// pakai kolom `category_service`, fallback ke `category_name`
      categoryName:
      (json['category_service'] ?? json['category_name'])?.toString(),

      reason: json['reason']?.toString(),
      reasonDescription: json['reason_description']?.toString(),
      feedbackMechanic: json['feedback_mechanic']?.toString(),
      createdAt: parseDT(json['created_at']),
      updatedAt: parseDT(json['updated_at']),
    );
  }

  /// Serialization ringan (tanpa memanggil `toJson()` dari model lain).
  Map<String, dynamic> toJson({bool includeRelations = false}) {
    Map<String, dynamic>? customerJson() {
      if (!includeRelations || customer == null) return null;
      try {
        final c = customer as dynamic;
        return {
          'id': c.id?.toString(),
          'name': c.name?.toString(),
        };
      } catch (_) {
        return null;
      }
    }

    Map<String, dynamic>? vehicleJson() {
      if (!includeRelations || vehicle == null) return null;
      try {
        final v = vehicle as dynamic;
        return {
          'id': v.id?.toString(),
          'plate_number': v.plateNumber?.toString(),
          'brand': v.brand?.toString(),
          'model': v.model?.toString(),
          'name': v.name?.toString(),
        };
      } catch (_) {
        return null;
      }
    }

    List<Map<String, dynamic>>? itemsJson() {
      if (!includeRelations || items == null) return null;
      final out = <Map<String, dynamic>>[];
      for (final it in items!) {
        try {
          final d = it as dynamic;
          out.add({
            'id': d.id?.toString(),
            'name': d.name?.toString(),
            'qty': d.qty ?? d.quantity,
            'price': d.price,
            'total': d.total ?? d.subtotal,
          });
        } catch (_) {}
      }
      return out.isEmpty ? null : out;
    }

    return {
      'id': id,
      'code': code,
      'name': name,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (scheduledDate != null)
        'scheduled_date': scheduledDate!.toIso8601String(),
      if (estimatedTime != null)
        'estimated_time': estimatedTime!.toIso8601String(),
      'status': status,
      if (acceptanceStatus != null) 'acceptance_status': acceptanceStatus,
      if (acceptedAt != null) 'accepted_at': acceptedAt!.toIso8601String(),
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
      if (customerUuid != null) 'customer_uuid': customerUuid,
      if (workshopUuid != null) 'workshop_uuid': workshopUuid,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (mechanicUuid != null) 'mechanic_uuid': mechanicUuid,
      if (includeRelations && workshopName != null)
        'workshop': {'name': workshopName},
      if (mechanic != null) 'mechanic': mechanic!.toJson(),
      if (includeRelations && customerJson() != null)
        'customer': customerJson(),
      if (includeRelations && vehicleJson() != null)
        'vehicle': vehicleJson(),
      if (includeRelations && itemsJson() != null) 'items': itemsJson(),
      if (note != null) 'note': note,
      if (categoryName != null) 'category_service': categoryName,
      if (reason != null) 'reason': reason,
      if (reasonDescription != null)
        'reason_description': reasonDescription,
      if (feedbackMechanic != null) 'feedback_mechanic': feedbackMechanic,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Untuk UI: tampilkan nama teknisi (atau '-')
  String get mechanicName {
    final n = mechanic?.name ?? '';
    return n.isEmpty ? '-' : n;
  }

  // ===== Display Getters untuk UI (Type-safe) =====

  /// Display: customer name
  String get displayCustomerName => customer?.name ?? '-';

  /// Display: vehicle plate number
  String get displayVehiclePlate => vehicle?.plateNumber ?? '-';

  /// Display: vehicle brand
  String get displayVehicleBrand => vehicle?.brand ?? '-';

  /// Display: vehicle model
  String get displayVehicleModel => vehicle?.model ?? '-';

  /// Display: vehicle name
  String get displayVehicleName => vehicle?.name ?? displayVehicleModel;

  /// Display: workshop name
  String get displayWorkshopName => workshopName ?? '-';

  /// Combined search string for efficient searching (lowercase)
  String get searchKeywords {
    final parts = <String>[
      code,
      name,
      description ?? '',
      customer?.name ?? '',
      vehicle?.plateNumber ?? '',
      vehicle?.brand ?? '',
      vehicle?.model ?? '',
      vehicle?.name ?? '',
      workshopName ?? '',
    ];
    return parts.where((e) => e.isNotEmpty).join(' | ').toLowerCase();
  }

  // Getters for compatibility
  String? get complaint => description;
  String? get request => description;
}
