import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Service untuk monitoring koneksi internet.
/// 
/// Menggunakan connectivity_plus untuk mendeteksi perubahan koneksi
/// dan menyediakan callback untuk offline/online status.
class ConnectivityService {
  ConnectivityService._();
  
  static final ConnectivityService instance = ConnectivityService._();
  
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  
  /// Callback yang dipanggil saat koneksi berubah menjadi offline
  VoidCallback? onOffline;
  
  /// Callback yang dipanggil saat koneksi kembali online
  VoidCallback? onOnline;
  
  bool _isOffline = false;
  bool get isOffline => _isOffline;
  
  /// Mulai monitoring koneksi internet
  Future<void> startMonitoring({
    VoidCallback? onOffline,
    VoidCallback? onOnline,
  }) async {
    this.onOffline = onOffline;
    this.onOnline = onOnline;
    
    // Check initial connection
    await _checkInitialConnection();
    
    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChange,
      onError: (error) {
        debugPrint('Connectivity error: $error');
      },
    );
  }
  
  /// Check koneksi awal saat app start
  Future<void> _checkInitialConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _handleConnectivityChange(results);
    } catch (e) {
      debugPrint('Error checking initial connectivity: $e');
    }
  }
  
  /// Handle perubahan koneksi
  void _handleConnectivityChange(List<ConnectivityResult> results) {
    // Jika semua result adalah none, berarti offline
    final isConnected = results.any((result) => result != ConnectivityResult.none);
    
    if (!isConnected && !_isOffline) {
      // Berubah dari online ke offline
      _isOffline = true;
      debugPrint('Connection lost - Going offline');
      onOffline?.call();
    } else if (isConnected && _isOffline) {
      // Berubah dari offline ke online
      _isOffline = false;
      debugPrint('Connection restored - Back online');
      onOnline?.call();
    }
  }
  
  /// Check koneksi manual (untuk retry button)
  Future<bool> checkConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((result) => result != ConnectivityResult.none);
    } catch (e) {
      debugPrint('Error checking connection: $e');
      return false;
    }
  }
  
  /// Stop monitoring
  void stopMonitoring() {
    _subscription?.cancel();
    _subscription = null;
    onOffline = null;
    onOnline = null;
  }
  
  /// Dispose service
  void dispose() {
    stopMonitoring();
  }
}
