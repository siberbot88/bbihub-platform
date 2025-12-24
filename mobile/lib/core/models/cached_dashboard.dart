import 'package:hive/hive.dart';

part 'cached_dashboard.g.dart';

/// Cached Dashboard Data for offline viewing
/// 
/// Stores dashboard statistics locally so owner can view
/// their workshop metrics even when offline.
@HiveType(typeId: 1)
class CachedDashboard extends HiveObject {
  @HiveField(0)
  final int servicesToday;

  @HiveField(1)
  final int inProgress;

  @HiveField(2)
  final int completed;

  @HiveField(3)
  final double? todayRevenue;

  @HiveField(4)
  final DateTime cachedAt;

  @HiveField(5)
  final List<CachedMechanicStat>? mechanicStats;

  CachedDashboard({
    required this.servicesToday,
    required this.inProgress,
    required this.completed,
    this.todayRevenue,
    required this.cachedAt,
    this.mechanicStats,
  });

  /// Create from API JSON response
  factory CachedDashboard.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    
    List<CachedMechanicStat>? stats;
    if (data['mechanic_stats'] != null) {
      stats = (data['mechanic_stats'] as List)
          .map((s) => CachedMechanicStat.fromJson(s))
          .toList();
    }

    return CachedDashboard(
      servicesToday: data['services_today'] ?? 0,
      inProgress: data['in_progress'] ?? 0,
      completed: data['completed'] ?? 0,
      todayRevenue: data['today_revenue']?.toDouble(),
      cachedAt: DateTime.now(),
      mechanicStats: stats,
    );
  }

  /// Convert to JSON for display
  Map<String, dynamic> toJson() {
    return {
      'services_today': servicesToday,
      'in_progress': inProgress,
      'completed': completed,
      'today_revenue': todayRevenue,
      'mechanic_stats': mechanicStats?.map((s) => s.toJson()).toList(),
    };
  }

  /// Check if cache is stale (older than 1 hour for dashboard)
  bool get isStale {
    final age = DateTime.now().difference(cachedAt);
    return age.inHours > 1;
  }

  /// Get cache age text
  String get cacheAgeText {
    final age = DateTime.now().difference(cachedAt);
    
    if (age.inMinutes < 60) {
      return '${age.inMinutes} menit lalu';
    } else {
      return '${age.inHours} jam lalu';
    }
  }
}

/// Cached Mechanic Statistics
@HiveType(typeId: 2)
class CachedMechanicStat extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int completedJobs;

  @HiveField(3)
  final int activeJobs;

  @HiveField(4)
  final double? avgRating;

  CachedMechanicStat({
    required this.id,
    required this.name,
    required this.completedJobs,
    required this.activeJobs,
    this.avgRating,
  });

  factory CachedMechanicStat.fromJson(Map<String, dynamic> json) {
    return CachedMechanicStat(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      completedJobs: json['completed_jobs'] ?? 0,
      activeJobs: json['active_jobs'] ?? 0,
      avgRating: json['avg_rating']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'completed_jobs': completedJobs,
      'active_jobs': activeJobs,
      'avg_rating': avgRating,
    };
  }
}
