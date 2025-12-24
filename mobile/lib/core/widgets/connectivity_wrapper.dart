// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bengkel_online_flutter/core/services/connectivity_service.dart';
import 'package:bengkel_online_flutter/core/utils/offline_helper.dart';

/// Wrapper widget yang monitoring connectivity dan auto-show offline screen.
/// 
/// Wrap MaterialApp dengan widget ini untuk enable auto offline detection.
///
/// Example:
/// ```dart
/// return ConnectivityWrapper(
///   child: MaterialApp(...),
/// );
/// ```
class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  
  /// Navigator key untuk navigate ke offline screen
  final GlobalKey<NavigatorState>? navigatorKey;

  const ConnectivityWrapper({
    super.key,
    required this.child,
    this.navigatorKey,
  });

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  final ConnectivityService _connectivityService = ConnectivityService.instance;
  bool _isOfflineScreenShown = false;

  @override
  void initState() {
    super.initState();
    _initConnectivityMonitoring();
  }

  @override
  void dispose() {
    _connectivityService.stopMonitoring();
    super.dispose();
  }

  Future<void> _initConnectivityMonitoring() async {
    await _connectivityService.startMonitoring(
      onOffline: _handleOffline,
      onOnline: _handleOnline,
    );
  }

  /// Get navigator context safely from navigatorKey
  BuildContext? get _navContext => widget.navigatorKey?.currentContext;

  /// Handle offline state - show offline screen
  void _handleOffline() {
    debugPrint('[ConnectivityWrapper] OFFLINE detected!');
    if (_isOfflineScreenShown) {
      debugPrint('[ConnectivityWrapper] Offline screen already shown, skipping');
      return;
    }
    
    if (!mounted) {
      debugPrint('[ConnectivityWrapper] Not mounted, cannot show offline screen');
      return;
    }
    
    _isOfflineScreenShown = true;
    debugPrint('[ConnectivityWrapper] Showing offline screen...');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _navContext;
      if (ctx != null && mounted) {
        OfflineHelper.showOfflineRoute(
          ctx,
          onRetry: _handleRetry,
        );
        debugPrint('[ConnectivityWrapper] Offline screen displayed');
      } else {
        debugPrint('[ConnectivityWrapper] No navigator context available');
      }
    });
  }

  /// Handle online state - close offline screen if shown
  void _handleOnline() {
    if (!_isOfflineScreenShown) {
      return;
    }
    
    _isOfflineScreenShown = false;
    debugPrint(' [ConnectivityWrapper] Closing offline screen...');
    
    final ctx = _navContext;
    if (ctx != null && mounted) {
      Navigator.of(ctx).pop();
      debugPrint(' [ConnectivityWrapper] Offline screen closed');
    }
  }

  /// Handle retry button press
  Future<void> _handleRetry() async {
    // Capture context before async operation
    final ctx = _navContext;
    
    final isConnected = await _connectivityService.checkConnection();
    
    // Check mounted after async operation
    if (!mounted || ctx == null) return;
    
    if (isConnected) {
      _isOfflineScreenShown = false;
      Navigator.of(ctx).pop();
    } else {
      // Still offline, show snackbar
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text('Masih offline. Silakan coba lagi.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
