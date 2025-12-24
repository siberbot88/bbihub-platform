import 'package:hive/hive.dart';

part 'cached_staff.g.dart';

/// Cached Staff/Employment Data for offline viewing
/// 
/// Stores staff members locally so owner can view
/// their team even when offline.
@HiveType(typeId: 3)
class CachedStaff extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userName;

  @HiveField(2)
  final String? userEmail;

  @HiveField(3)
  final String role;

  @HiveField(4)
  final String status;

  @HiveField(5)
  final DateTime cachedAt;

  @HiveField(6)
  final int? completedJobs;

  @HiveField(7)
  final int? activeJobs;

  @HiveField(8)
  final double? avgRating;

  CachedStaff({
    required this.id,
    required this.userName,
    this.userEmail,
    required this.role,
    required this.status,
    required this.cachedAt,
    this.completedJobs,
    this.activeJobs,
    this.avgRating,
  });

  /// Create from API JSON response
  factory CachedStaff.fromJson(Map<String, dynamic> json) {
    return CachedStaff(
      id: json['id'] ?? '',
      userName: json['user']?['name'] ?? json['name'] ?? 'Unknown',
      userEmail: json['user']?['email'] ?? json['email'],
      role: json['role'] ?? 'staff',
      status: json['status'] ?? 'active',
      cachedAt: DateTime.now(),
      completedJobs: json['completed_jobs'],
      activeJobs: json['active_jobs'],
      avgRating: json['avg_rating']?.toDouble(),
    );
  }

  /// Convert to JSON for display
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': {
        'name': userName,
        'email': userEmail,
      },
      'role': role,
      'status': status,
      'completed_jobs': completedJobs,
      'active_jobs': activeJobs,
      'avg_rating': avgRating,
    };
  }

  /// Check if cache is stale (older than 24 hours)
  bool get isStale {
    final age = DateTime.now().difference(cachedAt);
    return age.inHours > 24;
  }

  /// Get cache age text
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

  /// Check if staff is active
  bool get isActive => status.toLowerCase() == 'active';
}
