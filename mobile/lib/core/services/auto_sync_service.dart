import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:bengkel_online_flutter/core/repositories/data_repository.dart';

/// 🔥 AUTO-SYNC SERVICE
/// Automatically syncs data when app goes online
class AutoSyncService {
  static final AutoSyncService instance = AutoSyncService._internal();
  AutoSyncService._internal();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isOnline = false;
  bool _isSyncing = false;
  
  // Repositories (akan di-set saat login)
  ServiceRepository? _serviceRepository;
  DashboardRepository? _dashboardRepository;
  StaffRepository? _staffRepository;
  String? _workshopId;

  /// Initialize auto-sync with repositories
  void initialize({
    required ServiceRepository serviceRepository,
    required DashboardRepository dashboardRepository,
    required StaffRepository staffRepository,
    String? workshopId,
  }) {
    _serviceRepository = serviceRepository;
    _dashboardRepository = dashboardRepository;
    _staffRepository = staffRepository;
    _workshopId = workshopId;

    debugPrint('✅ [AutoSync] Initialized with workshopId: $workshopId');
    _startListeningToConnectivity();
  }

  /// Start listening to connectivity changes
  void _startListeningToConnectivity() {
    _connectivitySubscription?.cancel();
    
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final wasOffline = !_isOnline;
      // Check if any result is not none (device is online)
      _isOnline = results.any((result) => result != ConnectivityResult.none);

      debugPrint('🌐 [AutoSync] Connectivity changed: ${results.map((r) => r.name).join(', ')} (isOnline: $_isOnline)');

      // If we just went online, trigger sync
      if (wasOffline && _isOnline) {
        debugPrint('🔄 [AutoSync] Device just went ONLINE - triggering auto-sync');
        _performAutoSync();
      }
    });

    // Check initial connectivity
    Connectivity().checkConnectivity().then((results) {
      _isOnline = results.any((result) => result != ConnectivityResult.none);
      debugPrint('🌐 [AutoSync] Initial connectivity: ${results.map((r) => r.name).join(', ')} (isOnline: $_isOnline)');
    });
  }

  /// Perform auto-sync when device goes online
  Future<void> _performAutoSync() async {
    if (_isSyncing) {
      debugPrint('⏳ [AutoSync] Sync already in progress, skipping');
      return;
    }

    if (_serviceRepository == null || _dashboardRepository == null || _staffRepository == null) {
      debugPrint('⚠️ [AutoSync] Repositories not initialized, skipping sync');
      return;
    }

    _isSyncing = true;
    debugPrint('🔄 [AutoSync] Starting auto-sync...');

    try {
      // Sync all data in parallel
      await Future.wait([
        _syncServices(),
        _syncDashboard(),
        _syncStaff(),
      ]);

      debugPrint('✅ [AutoSync] All data synced successfully');
    } catch (e) {
      debugPrint('❌ [AutoSync] Error during sync: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync services data
  Future<void> _syncServices() async {
    try {
      debugPrint('📦 [AutoSync] Syncing services...');
      await _serviceRepository!.getServices(
        workshopId: _workshopId,
        forceRefresh: true,
      );
      debugPrint('✅ [AutoSync] Services synced');
    } catch (e) {
      debugPrint('❌ [AutoSync] Error syncing services: $e');
    }
  }

  /// Sync dashboard data
  Future<void> _syncDashboard() async {
    try {
      debugPrint('📊 [AutoSync] Syncing dashboard...');
      await _dashboardRepository!.getDashboardStats(
        workshopId: _workshopId,
        forceRefresh: true,
      );
      debugPrint('✅ [AutoSync] Dashboard synced');
    } catch (e) {
      debugPrint('❌ [AutoSync] Error syncing dashboard: $e');
    }
  }

  /// Sync staff data
  Future<void> _syncStaff() async {
    try {
      debugPrint('👥 [AutoSync] Syncing staff...');
      await _staffRepository!.getStaff(
        workshopId: _workshopId,
        forceRefresh: true,
      );
      debugPrint('✅ [AutoSync] Staff synced');
    } catch (e) {
      debugPrint('❌ [AutoSync] Error syncing staff: $e');
    }
  }

  /// Manual sync trigger (for pull-to-refresh)
  Future<void> manualSync() async {
    debugPrint('🔄 [AutoSync] Manual sync triggered');
    await _performAutoSync();
  }

  /// Update workshop ID (when user switches workshop)
  void updateWorkshopId(String? workshopId) {
    _workshopId = workshopId;
    debugPrint('🔄 [AutoSync] Workshop ID updated: $workshopId');
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    debugPrint('🔌 [AutoSync] Disposed');
  }

  /// Check if currently online
  bool get isOnline => _isOnline;

  /// Check if currently syncing
  bool get isSyncing => _isSyncing;
}
