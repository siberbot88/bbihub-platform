import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bengkel_online_flutter/core/models/cached_service.dart';
import 'package:bengkel_online_flutter/core/models/cached_dashboard.dart';
import 'package:bengkel_online_flutter/core/models/cached_staff.dart';
import 'package:bengkel_online_flutter/core/services/local_storage_service.dart';

/// 🔥 SERVICE REPOSITORY - Handles both online/offline data for Services
class ServiceRepository {
  final String baseUrl;
  final String? authToken;
  final LocalStorageService _localStorage = LocalStorageService.instance;

  ServiceRepository({
    required this.baseUrl,
    this.authToken,
  });

  /// Fetch services - tries online first, falls back to cache
  Future<List<CachedService>> getServices({
    String? workshopId,
    String? status,
    bool forceRefresh = false,
  }) async {
    // Check connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    // If offline or force refresh is false, try cache first
    if (!isOnline || !forceRefresh) {
      final cachedServices = await _localStorage.getCachedServices(workshopId);
      if (cachedServices.isNotEmpty) {
        debugPrint('📦 [ServiceRepository] Returning ${cachedServices.length} services from cache');
        return cachedServices;
      }
    }

    // Try to fetch from API
    if (isOnline) {
      try {
        final url = Uri.parse('$baseUrl/api/v1/services');
        final response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          final services = (jsonData['data'] as List)
              .map((e) => CachedService.fromJson(e))
              .toList();

          // Cache the response
          await _localStorage.cacheServices(services, workshopId);
          debugPrint('✅ [ServiceRepository] Fetched ${services.length} services from API and cached');

          return services;
        } else {
          throw Exception('API returned status ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('❌ [ServiceRepository] API error: $e');
        // Fall back to cache if API fails
        final cachedServices = await _localStorage.getCachedServices(workshopId);
        if (cachedServices.isNotEmpty) {
          debugPrint('📦 [ServiceRepository] Returning ${cachedServices.length} services from cache (API failed)');
          return cachedServices;
        }
        rethrow;
      }
    }

    // No data available
    return [];
  }

  /// Get a single service by ID
  Future<CachedService?> getServiceById(String serviceId) async {
    final services = await getServices();
    try {
      return services.firstWhere((s) => s.uuid == serviceId);
    } catch (e) {
      return null;
    }
  }
}

/// 🔥 DASHBOARD REPOSITORY - Handles both online/offline data for Dashboard
class DashboardRepository {
  final String baseUrl;
  final String? authToken;
  final LocalStorageService _localStorage = LocalStorageService.instance;

  DashboardRepository({
    required this.baseUrl,
    this.authToken,
  });

  /// Fetch dashboard stats - tries online first, falls back to cache
  Future<CachedDashboard?> getDashboardStats({
    String? workshopId,
    bool forceRefresh = false,
  }) async {
    // Check connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    // If offline or not forcing refresh, try cache first
    if (!isOnline || !forceRefresh) {
      final cachedDashboard = await _localStorage.getCachedDashboard(workshopId);
      if (cachedDashboard != null && !cachedDashboard.isStale) {
        debugPrint('📦 [DashboardRepository] Returning dashboard from cache');
        return cachedDashboard;
      }
    }

    // Try to fetch from API
    if (isOnline) {
      try {
        final url = Uri.parse('$baseUrl/api/v1/dashboard');
        final response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          final dashboard = CachedDashboard.fromJson(jsonData['data']);

          // Cache the response
          await _localStorage.cacheDashboard(dashboard, workshopId);
          debugPrint('✅ [DashboardRepository] Fetched dashboard from API and cached');

          return dashboard;
        } else {
          throw Exception('API returned status ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('❌ [DashboardRepository] API error: $e');
        // Fall back to cache if API fails
        final cachedDashboard = await _localStorage.getCachedDashboard(workshopId);
        if (cachedDashboard != null) {
          debugPrint('📦 [DashboardRepository] Returning dashboard from cache (API failed)');
          return cachedDashboard;
        }
        rethrow;
      }
    }

    return null;
  }
}

/// 🔥 STAFF REPOSITORY - Handles both online/offline data for Staff
class StaffRepository {
  final String baseUrl;
  final String? authToken;
  final LocalStorageService _localStorage = LocalStorageService.instance;

  StaffRepository({
    required this.baseUrl,
    this.authToken,
  });

  /// Fetch staff list - tries online first, falls back to cache
  Future<List<CachedStaff>> getStaff({
    String? workshopId,
    String? status,
    bool forceRefresh = false,
  }) async {
    // Check connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult != ConnectivityResult.none;

    // If offline or not forcing refresh, try cache first
    if (!isOnline || !forceRefresh) {
      final cachedStaff = await _localStorage.getCachedStaff(workshopId);
      if (cachedStaff.isNotEmpty) {
        debugPrint('📦 [StaffRepository] Returning ${cachedStaff.length} staff from cache');
        return cachedStaff;
      }
    }

    // Try to fetch from API
    if (isOnline) {
      try {
        final url = Uri.parse('$baseUrl/api/v1/employments');
        final response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          final staff = (jsonData['data'] as List)
              .map((e) => CachedStaff.fromJson(e))
              .toList();

          // Cache the response
          await _localStorage.cacheStaff(staff, workshopId);
          debugPrint('✅ [StaffRepository] Fetched ${staff.length} staff from API and cached');

          return staff;
        } else {
          throw Exception('API returned status ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('❌ [StaffRepository] API error: $e');
        // Fall back to cache if API fails
        final cachedStaff = await _localStorage.getCachedStaff(workshopId);
        if (cachedStaff.isNotEmpty) {
          debugPrint('📦 [StaffRepository] Returning ${cachedStaff.length} staff from cache (API failed)');
          return cachedStaff;
        }
        rethrow;
      }
    }

    // No data available
    return [];
  }

  /// Get a single staff member by ID
  Future<CachedStaff?> getStaffById(String staffId) async {
    final staff = await getStaff();
    try {
      return staff.firstWhere((s) => s.uuid == staffId);
    } catch (e) {
      return null;
    }
  }
}
