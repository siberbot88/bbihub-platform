import 'package:bengkel_online_flutter/core/widgets/clean_notification.dart';
import 'package:flutter/material.dart';

enum AlertType { success, error, warning, info }

class CustomAlert {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required AlertType type,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    // Map AlertType to NotificationType
    final notificationType = _mapType(type);

    // Determine default action text if not provided
    String? finalActionText = actionLabel;
    if (onAction != null && finalActionText == null) {
      switch (type) {
        case AlertType.success:
          finalActionText = "OK";
          break;
        case AlertType.error:
          finalActionText = "Coba Lagi";
          break;
        case AlertType.warning:
        case AlertType.info:
          finalActionText = "Lihat";
          break;
      }
    }

    CleanNotification.show(
      context,
      title: title,
      message: message,
      type: notificationType,
      actionText: finalActionText,
      onAction: onAction,
      duration: duration,
      // Removed redundant 'Tutup' button since we have 'X' icon
      onSecondaryAction: null,
      secondaryActionText: null,
    );
  }

  static NotificationType _mapType(AlertType type) {
    switch (type) {
      case AlertType.success:
        return NotificationType.success;
      case AlertType.error:
        return NotificationType.error;
      case AlertType.warning:
        return NotificationType.warning;
      case AlertType.info:
      default:
        return NotificationType.info;
    }
  }
}

