import 'package:hive/hive.dart';

part 'cached_service.g.dart';

/// Cached Service Model for offline storage
/// 
/// Stores essential service data locally so users can view
/// service list even when offline.
@HiveType(typeId: 0)
class CachedService extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String customerName;

  @HiveField(2)
  final String? vehiclePlate;

  @HiveField(3)
  final String status;

  @HiveField(4)
  final String? mechanicName;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime cachedAt;

  @HiveField(7)
  final String? serviceType;

  @HiveField(8)
  final double? estimatedCost;

  CachedService({
    required this.id,
    required this.customerName,
    this.vehiclePlate,
    required this.status,
    this.mechanicName,
    required this.createdAt,
    required this.cachedAt,
    this.serviceType,
    this.estimatedCost,
  });

  /// Create from API JSON response
  factory CachedService.fromJson(Map<String, dynamic> json) {
    return CachedService(
      id: json['id'] ?? '',
      customerName: json['customer']?['name'] ?? 'Unknown',
      vehiclePlate: json['vehicle']?['plate_number'],
      status: json['status'] ?? 'pending',
      mechanicName: json['mechanic']?['user']?['name'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      cachedAt: DateTime.now(),
      serviceType: json['service_type'],
      estimatedCost: json['estimated_cost']?.toDouble(),
    );
  }

  /// Convert to JSON for display
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'vehicle_plate': vehiclePlate,
      'status': status,
      'mechanic_name': mechanicName,
      'created_at': createdAt.toIso8601String(),
      'service_type': serviceType,
      'estimated_cost': estimatedCost,
    };
  }

  /// Check if cache is stale (older than 24 hours)
  bool get isStale {
    final age = DateTime.now().difference(cachedAt);
    return age.inHours > 24;
  }

  /// Get cache age in human readable format
  String get cacheAgeText {
    final age = DateTime.now().difference(cachedAt);
    
    if (age.inMinutes < 60) {
      return '${age.inMinutes} menit lalu';
    } else if (age.inHours < 24) {
      return '${age.inHours} jam lalu';
    } else {
      return '${age.inDays} hari lalu';
    }
  }
}
