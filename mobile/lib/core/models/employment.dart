import 'package:bengkel_online_flutter/core/models/user.dart';
import 'package:bengkel_online_flutter/core/models/workshop.dart';

class Employment {
  final String id;
  final String userUuid;
  final String workshopUuid;
  final String code;
  final String? specialist;
  final String? jobdesk;
  final String? status;
  final User? user;
  final Workshop? workshop;
  final String? roleName;

  Employment({
    required this.id,
    required this.userUuid,
    required this.workshopUuid,
    required this.code,
    this.specialist,
    this.jobdesk,
    this.status,
    this.user,
    this.workshop,
    this.roleName,
  });

  String get role {
// ... (fungsi getter tidak berubah) ...
    final r = (roleName ?? '').trim();
    if (r.isNotEmpty) return r;
    return (user?.role ?? '').trim();
  }

  String get name => user?.name ?? '';
  String get email => user?.email ?? '';
  bool get isActive => (status ?? 'active') == 'active';

  Employment copyWith({
// ... (fungsi copyWith tidak berubah) ...
    String? id,
    String? userUuid,
    String? workshopUuid,
    String? code,
    String? specialist,
    String? jobdesk,
    String? status,
    User? user,
    Workshop? workshop,
    String? roleName,
  }) {
    return Employment(
      id: id ?? this.id,
      userUuid: userUuid ?? this.userUuid,
      workshopUuid: workshopUuid ?? this.workshopUuid,
      code: code ?? this.code,
      specialist: specialist ?? this.specialist,
      jobdesk: jobdesk ?? this.jobdesk,
      status: status ?? this.status,
      user: user ?? this.user,
      workshop: workshop ?? this.workshop,
      roleName: roleName ?? this.roleName,
    );
  }

  factory Employment.fromJson(Map<String, dynamic> json) {
    String? extractRole(Map<String, dynamic> j) {
// ... (fungsi extractRole tidak berubah) ...
      final r = j['role'];
      if (r is String && r.trim().isNotEmpty) return r.trim();

      final u = j['user'];
      if (u is Map<String, dynamic>) {
        final ur = u['role'];
        if (ur is String && ur.trim().isNotEmpty) return ur.trim();
        // Spatie (roles[] -> name)
        final roles = u['roles'];
        if (roles is List && roles.isNotEmpty) {
          final first = roles.first;
          if (first is Map && first['name'] is String) {
            return (first['name'] as String).trim();
          }
        }
      }
      return null;
    }

    // ==========================================================
    // PERBAIKAN DI SINI:
    // Ubah `as String` menjadi `(json[...] ?? '').toString()`
    // untuk menangani nilai null dengan aman.
    // ==========================================================
    return Employment(
      id: (json['id'] ?? '').toString(),
      userUuid: (json['user_uuid'] ?? '').toString(),
      workshopUuid: (json['workshop_uuid'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      specialist: json['specialist'] as String?,
      jobdesk: json['jobdesk'] as String?,
      status: json['status'] as String?,
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      workshop: json['workshop'] != null
          ? Workshop.fromJson(json['workshop'] as Map<String, dynamic>)
          : null,
      roleName: extractRole(json),
    );
  }

  Map<String, dynamic> toJson() => {
// ... (fungsi toJson tidak berubah) ...
    'id': id,
    'user_uuid': userUuid,
    'workshop_uuid': workshopUuid,
    'code': code,
    'specialist': specialist,
    'jobdesk': jobdesk,
    'status': status,
    if (role.isNotEmpty) 'role': role,
  };
}