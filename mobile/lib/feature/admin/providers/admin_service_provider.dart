import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:bengkel_online_flutter/core/services/api_service.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';
import 'package:bengkel_online_flutter/core/providers/service_provider.dart';

/// Provider khusus ADMIN
/// Extend ServiceProvider supaya:
/// - state list, detail, loading, pagination tetap 1 sumber
/// - tapi endpoint & aksi-aksi admin pakai route /admins/services
class AdminServiceProvider extends ServiceProvider {
  final ApiService _adminApi = ApiService();

  /// Override hook: sekarang list service pakai endpoint ADMIN
  /// GET /v1/admins/services
  /// Override hook: ambil data dari API Admin, LALU FLATTEN strukturnya
  /// supaya `ServiceProvider` (parent) bisa baca sebagai `['data']` adalah List.
  @override
  Future<Map<String, dynamic>> performFetchServicesRaw({
    String? status,
    bool includeExtras = true,
    String? workshopUuid,
    String? code,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int perPage = 10,
    String? type, // Added type param
  }) async {
    // 1. Ambil raw response asli
    final res = await _adminApi.adminFetchServicesRaw(
      page: page,
      perPage: perPage,
      status: status ?? statusFilter,
      workshopUuid: workshopUuid,
      code: code,
      dateFrom: dateFrom,
      dateTo: dateTo,
      type: type, // Pass type
    );

    // 2. Transform struktur: grouped_services -> flat list
    // Response asli: { data: { grouped_services: { date: [s1, s2] } }, ... }
    // Target: { data: [s1, s2], ... }
    
    try {
      if (res['data'] is Map && res['data']['grouped_services'] is Map) {
        final grouped = res['data']['grouped_services'] as Map<String, dynamic>;
        final flatList = <dynamic>[];
        
        // Flatten
        for (var key in grouped.keys) {
          final listDetails = grouped[key];
          if (listDetails is List) {
            flatList.addAll(listDetails);
          }
        }
        
        // Modifikasi 'data' agar jadi list
        // Kita copy res biar aman
        final newRes = Map<String, dynamic>.from(res);
        newRes['data'] = flatList; // Ganti object data dengan list services
        
        return newRes;
      }
    } catch (e) {
      if (kDebugMode) print('Error transforming admin services: $e');
    }

    return res;
  }

  /// Override hook detail: sekarang pakai /v1/admins/services/{id}
  @override
  Future<ServiceModel> performFetchServiceDetail(String id) {
    return _adminApi.adminFetchServiceDetail(id);
  }

  /// Helper simpel kalau mau refresh pakai page sekarang
  Future<void> refreshAdmin({int? page}) {
    return fetchServices(page: page ?? currentPage);
  }

  /* ==================== ADMIN FLOW ACTIONS ==================== */

  /// ADMIN: ACCEPT service
  /// Backend rule:
  /// - acceptance_status = accepted
  /// - status auto in progress
  /// - optional: sekaligus assign mechanic
  Future<void> acceptServiceAsAdmin(
      String id, {
        String? mechanicUuid,
        bool refresh = true,
      }) async {
    try {
      await _adminApi.adminAcceptService(
        id,
        mechanicUuid: mechanicUuid,
      );

      if (refresh) {
        // refresh detail & list dengan logic bawaan ServiceProvider
        await fetchDetail(id);
        await fetchServices(page: currentPage);
      }
    } catch (e) {
      if (kDebugMode) print('acceptServiceAsAdmin error: $e');
      rethrow;
    }
  }

  /// ADMIN: DECLINE service
  /// Wajib kirim reason, kalau reason == 'lainnya' wajib reasonDescription
  Future<void> declineServiceAsAdmin(
      String id, {
        required String reason,
        String? reasonDescription,
        bool refresh = true,
      }) async {
    try {
      await _adminApi.adminDeclineService(
        id,
        reason: reason,
        reasonDescription: reasonDescription,
      );

      if (refresh) {
        await fetchDetail(id);
        await fetchServices(page: currentPage);
      }
    } catch (e) {
      if (kDebugMode) print('declineServiceAsAdmin error: $e');
      rethrow;
    }
  }

  /// ADMIN: Assign mechanic
  /// Rules backend:
  /// - hanya boleh kalau acceptance_status == 'accepted'
  /// - status auto jadi 'in progress'
  Future<void> assignMechanicAsAdmin(
      String id,
      String mechanicUuid, {
        bool refresh = true,
      }) async {
    try {
      await _adminApi.adminAssignMechanic(
        id,
        mechanicUuid: mechanicUuid,
      );

      if (refresh) {
        await fetchDetail(id);
        await fetchServices(page: currentPage);
      }
    } catch (e) {
      if (kDebugMode) print('assignMechanicAsAdmin error: $e');
      rethrow;
    }
  }

  /// ADMIN: Create Walk-In Service
  Future<void> createWalkInService({
    required String customerName,
    required String customerPhone,
    required String vehicleBrand,
    required String vehicleModel,
    required String vehiclePlate,
    required String vehicleYear,
    required String vehicleColor,
    required String vehicleCategory,
    required String serviceName,
    String? serviceDescription,
    File? image,
  }) async {
    try {
      if (kDebugMode) {
        print('createWalkInService called with: Year=$vehicleYear, Color=$vehicleColor');
      }
      
      await _adminApi.adminCreateWalkInService(
        customerName: customerName,
        customerPhone: customerPhone,
        vehicleBrand: vehicleBrand,
        vehicleModel: vehicleModel,
        vehiclePlate: vehiclePlate,
        vehicleYear: vehicleYear,
        vehicleColor: vehicleColor,
        vehicleCategory: vehicleCategory,
        serviceName: serviceName,
        serviceDescription: serviceDescription,
        image: image,
      );
      
      // Refresh list
      await fetchServices(page: currentPage);
    } catch (e) {
      if (kDebugMode) print('createWalkInService error: $e');
      rethrow;
    }
  }

  /// Fetch ACTIVE services (for Service Logging / Pencatatan tab)
  /// Uses /admins/services/active endpoint
  Future<List<ServiceModel>> fetchActiveServices({int page = 1, int perPage = 15}) async {
    try {
      final res = await _adminApi.adminFetchActiveServices(page: page, perPage: perPage);
      
      if (res['data'] == null || res['data']['services'] == null) {
        return [];
      }
      
      final services = (res['data']['services'] as List)
          .map((e) => ServiceModel.fromJson(e))
          .toList();
      
      return services;
    } catch (e) {
      if (kDebugMode) print('fetchActiveServices error: $e');
      rethrow;
    }
  }

  /// ADMIN: Fetch mechanics for assignment
  Future<List<Map<String, dynamic>>> fetchMechanicsForAssignment() async {
    try {
      final res = await _adminApi.adminFetchMechanics();
      if (res['data'] is List) {
        return List<Map<String, dynamic>>.from(res['data']);
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('fetchMechanicsForAssignment error: $e');
      rethrow;
    }
  }

  /// ADMIN: Delete service
  Future<void> deleteServiceAsAdmin(
      String id, {
        bool refresh = true,
      }) async {
    try {
      await _adminApi.adminDeleteService(id);

      if (refresh) {
        await fetchServices(page: currentPage);
      }
    } catch (e) {
      if (kDebugMode) print('deleteServiceAsAdmin error: $e');
      rethrow;
    }
  }
}
