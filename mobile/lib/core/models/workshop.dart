import 'package:flutter/foundation.dart';

class Workshop {
  final String id;
  final String userUuid;
  final String code;
  final String name;
  final String? description;
  final String address;
  final String phone;
  final String email;
  final String? photo;
  final String city;
  final String province;
  final String country;
  final String postalCode;
  final double? latitude;
  final double? longitude;
  final String? mapsUrl;
  final String openingTime;
  final String closingTime;
  final String operationalDays;
  final bool isActive;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Workshop({
    required this.id,
    required this.userUuid,
    required this.code,
    required this.name,
    this.description,
    required this.address,
    required this.phone,
    required this.email,
    this.photo,
    required this.city,
    required this.province,
    required this.country,
    required this.postalCode,
    this.latitude,
    this.longitude,
    this.mapsUrl,
    required this.openingTime,
    required this.closingTime,
    required this.operationalDays,
    required this.isActive,
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
  });

  factory Workshop.fromJson(Map<String, dynamic> json) {
    // Helper untuk parse double (aman dari null, int, atau string)
    double? parseDoubleSafe(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    // Helper untuk parse bool (aman dari null, int, atau string)
    bool parseBoolSafe(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
      return false;
    }

    // Helper untuk parse DateTime (aman dari null atau format salah)
    DateTime? parseDateTimeSafe(dynamic value) {
      if (value == null || value is! String) return null;
      return DateTime.tryParse(value);
    }

    // Helper untuk sanitize URL localhost ke 10.0.2.2 (untuk Android Emulator)
    String? sanitizeUrl(String? url) {
      if (url == null) return null;
      // Basic check, ideally check standard platform logic but this is safe enough for typical dev setup
      if (url.contains('localhost')) {
        return url.replaceAll('localhost', '10.0.2.2');
      }
      if (url.contains('127.0.0.1')) {
        return url.replaceAll('127.0.0.1', '10.0.2.2');
      }
      return url;
    }

    try {
      return Workshop(
        id: json['id'] as String? ?? 'unknown_workshop_id',
        userUuid: json['user_uuid'] as String? ?? '',
        code: json['code'] as String? ?? '',
        name: json['name'] as String? ?? 'Unknown Workshop',
        description: json['description'] as String?,
        address: json['address'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String? ?? '',
        photo: sanitizeUrl(json['photo'] as String?),
        city: json['city'] as String? ?? '',
        province: json['province'] as String? ?? '',
        country: json['country'] as String? ?? '',
        postalCode: json['postal_code'] as String? ?? '',
        latitude: parseDoubleSafe(json['latitude']),
        longitude: parseDoubleSafe(json['longitude']),
        mapsUrl: json['maps_url'] as String?,
        openingTime: json['opening_time'] as String? ?? '00:00',
        closingTime: json['closing_time'] as String? ?? '00:00',
        operationalDays: json['operational_days'] as String? ?? '',
        isActive: parseBoolSafe(json['is_active']),
        status: json['status'] as String? ?? 'pending',
        createdAt: parseDateTimeSafe(json['created_at']),
        updatedAt: parseDateTimeSafe(json['updated_at']),
      );
    } catch (e) {
      // Jika terjadi error saat parsing, print errornya
      if (kDebugMode) {
        debugPrint('FATAL ERROR parsing Workshop JSON: $e');
        debugPrint('Problematic Workshop JSON: $json');
      }
      // Lemparkan error agar `User.fromJson` bisa menangkapnya
      throw Exception('Failed to parse Workshop: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_uuid': userUuid,
      'code': code,
      'name': name,
      'description': description,
      'address': address,
      'phone': phone,
      'email': email,
      'photo': photo,
      'city': city,
      'province': province,
      'country': country,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'maps_url': mapsUrl,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'operational_days': operationalDays,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
