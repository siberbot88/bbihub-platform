import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bengkel_online_flutter/core/services/api_service.dart';
import 'package:bengkel_online_flutter/core/models/notification_model.dart';
import 'auth_provider.dart';

class NotificationProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthProvider _authProvider;

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  Timer? _pollingTimer;

  NotificationProvider(this._authProvider) {
    // Start polling if logged in
    if (_authProvider.isLoggedIn) {
      startPolling();
    }
  }

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  void startPolling() {
    stopPolling();
    fetchNotifications(silent: false);
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_authProvider.isLoggedIn) {
        stopPolling();
        return;
      }
      fetchNotifications(silent: true);
      fetchUnreadCount();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> fetchNotifications({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final res = await _apiService.fetchNotifications();
      final data = res['data'];
      final List list = (data is Map && data['data'] is List) 
          ? data['data'] 
          : (data is List ? data : []);

      _notifications = list.map((e) => NotificationModel.fromJson(e)).toList();
      
      // Update unread count based on list? Or better separate call?
      // Let's use the explicit count API for badge accuracy
      await fetchUnreadCount();
      
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      } else {
        notifyListeners(); // Update list silently
      }
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      _unreadCount = await _apiService.getUnreadNotificationCount();
      notifyListeners();
    } catch (e) {
      // ignore
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _apiService.markNotificationRead(id);
      
      // Optimistic update
      if (id == 'all') {
        _notifications = _notifications.map((n) {
          // Can't modify final fields, creating new list logic would be needed if model was mutable
          // Simpler: just re-fetch
          return n;
        }).toList();
        _unreadCount = 0;
        await fetchNotifications(silent: true);
      } else {
         // Find and update local
         final index = _notifications.indexWhere((n) => n.id == id);
         if (index != -1) {
             // force refresh for simplicity or construct new object
             await fetchNotifications(silent: true);
         }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking read: $e');
    }
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
