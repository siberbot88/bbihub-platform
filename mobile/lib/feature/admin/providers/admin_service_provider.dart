import 'package:flutter/foundation.dart';
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
  }) {
    return _adminApi.adminFetchServicesRaw(
      page: page,
      perPage: perPage,
      status: status ?? statusFilter,
      workshopUuid: workshopUuid,
      code: code,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
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
