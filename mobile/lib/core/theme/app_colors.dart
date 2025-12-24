import 'package:flutter/material.dart';

/// Application color palette.
///
/// Centralizes all colors used throughout the app to ensure consistency
/// and make theme changes easier to manage.
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // ===== Primary Colors =====
  /// Main brand color (Red) - #D72B1C
  static const Color primaryRed = Color(0xFFD72B1C);
  
  /// Darker shade of primary red - #B70F0F
  static const Color primaryDark = Color(0xFFB70F0F);
  
  /// Even darker shade for gradients - #9B0D0D
  static const Color primaryDarker = Color(0xFF9B0D0D);

  // ===== Accent Colors =====
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentGreen = Color(0xFF4CAF50);
  
  // ===== Semantic Colors =====
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // ===== Status Colors (for Services) =====
  static const Color statusPending = Color(0xFFFF9800);
  static const Color statusAccept = Color(0xFF4CAF50);
  static const Color statusInProgress = Color(0xFF2196F3);
  static const Color statusCompleted = Color(0xFF4CAF50);
  static const Color statusCancelled = Color(0xFFF44336);
  
  // ===== UI Background =====
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // ===== Text Colors =====
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // ===== Border & Divider =====
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFBDBDBD);
  
  // ===== Shadows =====
  static Color shadow = Colors.black.withAlpha(20);
  static Color cardShadow = Colors.black.withAlpha(26);
  
  // ===== Gradients =====
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDarker, primaryRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
