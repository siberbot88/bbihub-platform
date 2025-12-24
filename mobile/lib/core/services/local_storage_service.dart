import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bengkel_online_flutter/core/models/cached_service.dart';
import 'package:bengkel_online_flutter/core/models/cached_dashboard.dart';
import 'package:bengkel_online_flutter/core/models/cached_staff.dart';

/// Local Storage Service using Hive
/// 
/// Handles all local data caching for offline support.
/// Provides methods to cache and retrieve data from local storage.
class LocalStorageService {
  LocalStorageService._();

  static final LocalStorageService instance = LocalStorageService._();

  // Box names
  static const String servicesBox = 'services';
  static const String dashboardBox = 'dashboard';
  static const String staffBox = 'staff';

  // Cache keys
  static const String dashboardKey = 'latest_dashboard';

  /// Initialize Hive and open all boxes
  /// 
  /// Call this in main() before runApp()
  Future<void> init() async {
    try {
      debugPrint('[LocalStorage] Initializing Hive...');
      
      await Hive.initFlutter();

      // Register type adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CachedServiceAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(CachedDashboardAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(CachedMechanicStatAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(CachedStaffAdapter());
      }

      // Open boxes
      await Hive.openBox<CachedService>(servicesBox);
      await Hive.openBox<CachedDashboard>(dashboardBox);
      await Hive.openBox<CachedStaff>(staffBox);

      debugPrint('[LocalStorage] ✅ Hive initialized successfully');
    } catch (e) {
      debugPrint('[LocalStorage] ❌ Error initializing Hive: $e');
      rethrow;
    }
  }

  // ==================== SERVICES ====================

  /// Cache services list
  Future<void> cacheServices(List<CachedService> services) async {
    try {
      final box = Hive.box<CachedService>(servicesBox);
      await box.clear(); // Clear old data
      await box.addAll(services);
      debugPrint('[LocalStorage] ✅ Cached ${services.length} services');
    } catch (e) {
      debugPrint('[LocalStorage] ❌ Error caching services: $e');
    }
  }

  /// Get cached services
  List<CachedService> getCachedServices() {
    try {
      final box = Hive.box<CachedService>(servicesBox);
      final services = box.values.toList();
      debugPrint('[LocalStorage] Retrieved ${services.length} cached services');
      return services;
    } catch (e) {
      debugPrint('[LocalStorage] ❌ Error getting cached services: $e');
      return [];
    }
  }

  /// Check if services cache exists
  bool hasServiceCache() {
    final box = Hive.box<CachedService>(servicesBox);
    return box.isNotEmpty;
  }

  /// Clear services cache
  Future<void> clearServicesCache() async {
    final box = Hive.box<CachedService>(servicesBox);
    await box.clear();
    debugPrint('[LocalStorage] 🗑️  Services cache cleared');
  }

  // ==================== DASHBOARD ====================

  /// Cache dashboard data
  Future<void> cacheDashboard(CachedDashboard dashboard) async {
    try {
      final box = Hive.box<CachedDashboard>(dashboardBox);
      await box.put(dashboardKey, dashboard);
      debugPrint('[LocalStorage] ✅ Dashboard cached');
    } catch (e) {
      debugPrint('[LocalStorage] ❌ Error caching dashboard: $e');
    }
  }

  /// Get cached dashboard
  CachedDashboard? getCachedDashboard() {
    try {
      final box = Hive.box<CachedDashboard>(dashboardBox);
      final dashboard = box.get(dashboardKey);
      
      if (dashboard != null) {
        debugPrint('[LocalStorage] Retrieved cached dashboard (${dashboard.cacheAgeText})');
      }
      
      return dashboard;
    } catch (e) {
      debugPrint('[LocalStorage] ❌ Error getting cached dashboard: $e');
      return null;
    }
  }

  /// Check if dashboard cache exists
  bool hasDashboardCache() {
    final box = Hive.box<CachedDashboard>(dashboardBox);
    return box.containsKey(dashboardKey);
  }

  /// Clear dashboard cache
  Future<void> clearDashboardCache() async {
    final box = Hive.box<CachedDashboard>(dashboardBox);
    await box.delete(dashboardKey);
    debugPrint('[LocalStorage] 🗑️  Dashboard cache cleared');
  }

  // ==================== STAFF ====================

  /// Cache staff list
  Future<void> cacheStaff(List<CachedStaff> staff) async {
    try {
      final box = Hive.box<CachedStaff>(staffBox);
      await box.clear(); // Clear old data
      await box.addAll(staff);
      debugPrint('[LocalStorage] ✅ Cached ${staff.length} staff members');
    } catch (e) {
      debugPrint('[LocalStorage] ❌ Error caching staff: $e');
    }
  }

  /// Get cached staff
  List<CachedStaff> getCachedStaff() {
    try {
      final box = Hive.box<CachedStaff>(staffBox);
      final staff = box.values.toList();
      debugPrint('[LocalStorage] Retrieved ${staff.length} cached staff members');
      return staff;
    } catch (e) {
      debugPrint('[LocalStorage] ❌ Error getting cached staff: $e');
      return [];
    }
  }

  /// Check if staff cache exists
  bool hasStaffCache() {
    final box = Hive.box<CachedStaff>(staffBox);
    return box.isNotEmpty;
  }

  /// Clear staff cache
  Future<void> clearStaffCache() async {
    final box = Hive.box<CachedStaff>(staffBox);
    await box.clear();
    debugPrint('[LocalStorage] 🗑️  Staff cache cleared');
  }

  // ==================== UTILITIES ====================

  /// Clear ALL caches
  Future<void> clearAllCache() async {
    await clearServicesCache();
    await clearDashboardCache();
    await clearStaffCache();
    debugPrint('[LocalStorage] 🗑️  ALL cache cleared');
  }

  /// Get total cache size info
  Map<String, dynamic> getCacheInfo() {
    final servicesBox = Hive.box<CachedService>(LocalStorageService.servicesBox);
    final dashboardBox = Hive.box<CachedDashboard>(LocalStorageService.dashboardBox);
    final staffBox = Hive.box<CachedStaff>(LocalStorageService.staffBox);

    return {
      'services_count': servicesBox.length,
      'has_dashboard': dashboardBox.containsKey(dashboardKey),
      'staff_count': staffBox.length,
      'total_items': servicesBox.length + staffBox.length + (dashboardBox.isNotEmpty ? 1 : 0),
    };
  }

  /// Check if any cache is stale
  bool hasStaleCache() {
    // Check dashboard
    final dashboard = getCachedDashboard();
    if (dashboard != null && dashboard.isStale) {
      return true;
    }

    // Check services
    final services = getCachedServices();
    if (services.isNotEmpty && services.first.isStale) {
      return true;
    }

    // Check staff
    final staff = getCachedStaff();
    if (staff.isNotEmpty && staff.first.isStale) {
      return true;
    }

    return false;
  }

  /// Close all boxes (call on app dispose)
  Future<void> dispose() async {
    await Hive.close();
    debugPrint('[LocalStorage] Hive closed');
  }
}
