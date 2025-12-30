import 'package:flutter/foundation.dart';
import 'package:bengkel_online_flutter/core/services/api_service.dart';

class AdminAnalyticsProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Mini Dashboard / Quick Stats (from /admins/dashboard)
  Map<String, dynamic>? _quickStats;
  Map<String, dynamic>? get quickStats => _quickStats;

  // Detailed Stats (from /admins/dashboard/stats)
  Map<String, dynamic>? _detailedStats;
  Map<String, dynamic>? get detailedStats => _detailedStats;

  Future<void> fetchQuickStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.adminFetchDashboard();
      if (res['data'] != null) {
        _quickStats = res['data'];
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('AdminAnalyticsProvider QuickError: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDetailedStats({String? dateFrom, String? dateTo}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.adminFetchDashboardStats(
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      _detailedStats = res;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('AdminAnalyticsProvider DetailError: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper getters for Quick Stats
  int get serviceToday => _quickStats?['services_today'] ?? 0;
  int get needsAssign => _quickStats?['needs_assignment'] ?? 0;
  // Note: feedback count not in quick stats provided by backend logic viewed earlier?
  // Actually dashboard logic:
  // 'services_today', 'needs_assignment', 'in_progress', 'completed'
  // No explicit feedback count in quick stats.
  // But top_services, mechanic_stats are there.

  int get inProgress => _quickStats?['in_progress'] ?? 0;
  int get completedToday => _quickStats?['completed'] ?? 0; // "Selesai"

  List<dynamic> get quickTrend => _quickStats?['trend_weekly'] ?? [];
  
  // Clean up
  void clear() {
    _quickStats = null;
    _detailedStats = null;
    _error = null;
    notifyListeners();
  }
}
