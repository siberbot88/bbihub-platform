import 'package:intl/intl.dart';

class Voucher {
  final String id;
  final String workshopUuid;
  final String codeVoucher;
  final String title;
  final double discountValue;
  final int quota;
  final double minTransaction;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;
  final String? imageUrl;

  Voucher({
    required this.id,
    required this.workshopUuid,
    required this.codeVoucher,
    required this.title,
    required this.discountValue,
    required this.quota,
    required this.minTransaction,
    required this.validFrom,
    required this.validUntil,
    required this.isActive,
    this.imageUrl,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id']?.toString() ?? '',
      workshopUuid: json['workshop_uuid']?.toString() ?? '',
      codeVoucher: json['code_voucher']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      discountValue: double.tryParse(json['discount_value'].toString()) ?? 0.0,
      quota: int.tryParse(json['quota'].toString()) ?? 0,
      minTransaction: double.tryParse(json['min_transaction'].toString()) ?? 0.0,
      validFrom: json['valid_from'] != null ? DateTime.parse(json['valid_from']) : DateTime.now(),
      validUntil: json['valid_until'] != null ? DateTime.parse(json['valid_until']) : DateTime.now(),
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      imageUrl: _fixImageUrl(json['image_url']),
    );
  }

  static String? _fixImageUrl(dynamic url) {
    if (url == null || url.toString().isEmpty) {
      print("DEBUG_IMAGE: URL is null or empty");
      return null;
    }
    String finalUrl = url.toString();
    print("DEBUG_IMAGE_ORIGINAL: $finalUrl");
    
    // Fix for Android Emulator 127.0.0.1 -> 10.0.2.2
    if (finalUrl.contains("127.0.0.1")) {
      finalUrl = finalUrl.replaceAll("127.0.0.1", "10.0.2.2");
    } else if (finalUrl.contains("localhost")) {
      finalUrl = finalUrl.replaceAll("localhost", "10.0.2.2");
    }
    print("DEBUG_IMAGE_FIXED: $finalUrl");
    return finalUrl;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workshop_uuid': workshopUuid,
      'code_voucher': codeVoucher,
      'title': title,
      'discount_value': discountValue,
      'quota': quota,
      'min_transaction': minTransaction,
      'valid_from': validFrom.toIso8601String(),
      'valid_until': validUntil.toIso8601String(),
      'is_active': isActive,
      'image_url': imageUrl,
    };
  }

  String get formattedValidDate {
    final formatter = DateFormat('d MMMM yyyy', 'id_ID');
    return "${formatter.format(validFrom)} - ${formatter.format(validUntil)}";
  }

  String get formattedUntilDate {
    final formatter = DateFormat('d MMMM yyyy', 'id_ID');
    return formatter.format(validUntil);
  }

  bool get isExpired => DateTime.now().isAfter(validUntil);
}