import 'package:flutter/material.dart';

/// Application border radius constants.
///
/// Provides consistent border radius values throughout the app.
class AppRadius {
  AppRadius._(); // Private constructor

  // ===== Radius Values =====
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double round = 100.0; // For pill-shaped buttons

  // ===== BorderRadius Objects =====
  static BorderRadius radiusXS = BorderRadius.circular(xs);
  static BorderRadius radiusSM = BorderRadius.circular(sm);
  static BorderRadius radiusMD = BorderRadius.circular(md);
  static BorderRadius radiusLG = BorderRadius.circular(lg);
  static BorderRadius radiusXL = BorderRadius.circular(xl);
  static BorderRadius radiusXXL = BorderRadius.circular(xxl);
  static BorderRadius radiusRound = BorderRadius.circular(round);

  // ===== Specific Use Cases =====
  static BorderRadius get buttonRadius => radiusXL; // 20px for buttons
  static BorderRadius get cardRadius => radiusLG; // 16px for cards
  static BorderRadius get inputRadius => radiusMD; // 12px for text fields
  static BorderRadius get dialogRadius => radiusLG; // 16px for dialogs
  static BorderRadius get bottomSheetRadius => const BorderRadius.only(
        topLeft: Radius.circular(xxl),
        topRight: Radius.circular(xxl),
      );
}
