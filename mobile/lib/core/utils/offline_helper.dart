import 'package:flutter/material.dart';
import 'package:bengkel_online_flutter/core/screens/offline_screen.dart';

/// Helper class to show offline screen in various ways.
///
/// Provides convenient methods to display the offline screen
/// as a full-page widget or as a route.
class OfflineHelper {
  OfflineHelper._(); // Private constructor

  /// Show offline screen as a full-screen page with navigation.
  ///
  /// This will push a new route to the navigator stack.
  /// Use this when you want to completely block the app until connection is restored.
  static Future<void> showOfflineRoute(
    BuildContext context, {
    VoidCallback? onRetry,
    String? title,
    String? message,
    bool showRetryButton = true,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OfflineScreen(
          onRetry: onRetry ?? () => Navigator.of(context).pop(),
          title: title,
          message: message,
          showRetryButton: showRetryButton,
        ),
      ),
    );
  }

  /// Show offline screen as a modal bottom sheet.
  ///
  /// This is less intrusive than a full page and allows users
  /// to dismiss it by swiping down.
  static Future<void> showOfflineBottomSheet(
    BuildContext context, {
    VoidCallback? onRetry,
    String? title,
    String? message,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: OfflineScreen(
          onRetry: onRetry ?? () => Navigator.of(context).pop(),
          title: title,
          message: message,
          showRetryButton: true,
        ),
      ),
    );
  }

  /// Show offline dialog.
  ///
  /// A compact dialog version of the offline screen.
  /// Good for temporary connection issues.
  static Future<void> showOfflineDialog(
    BuildContext context, {
    VoidCallback? onRetry,
    String? title,
    String? message,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 500),
          child: OfflineScreen(
            onRetry: onRetry ?? () => Navigator.of(context).pop(),
            title: title,
            message: message,
            showRetryButton: true,
          ),
        ),
      ),
    );
  }

  /// Replace current route with offline screen.
  ///
  /// Use this when you want to replace the current screen entirely
  /// with the offline screen.
  static Future<void> replaceWithOfflineScreen(
    BuildContext context, {
    VoidCallback? onRetry,
    String? title,
    String? message,
  }) async {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => OfflineScreen(
          onRetry: onRetry,
          title: title,
          message: message,
          showRetryButton: true,
        ),
      ),
    );
  }
}
