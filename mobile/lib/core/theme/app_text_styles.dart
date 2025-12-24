import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Application text styles.
///
/// Provides consistent typography throughout the app using Google Fonts (Poppins).
class AppTextStyles {
  AppTextStyles._(); // Private constructor

  // ===== Headings =====
  static TextStyle heading1({Color? color}) => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: color ?? AppColors.primaryRed,
      );

  static TextStyle heading2({Color? color}) => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle heading3({Color? color}) => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle heading4({Color? color}) => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle heading5({Color? color}) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      );

  // ===== Body Text =====
  static TextStyle bodyLarge({Color? color}) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle bodySmall({Color? color}) => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: color ?? AppColors.textSecondary,
      );

  // ===== Labels & Captions =====
  static TextStyle label({Color? color}) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle labelBold({Color? color}) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle caption({Color? color}) => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: color ?? AppColors.textHint,
      );

  // ===== Button Text =====
  static TextStyle button({Color? color}) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textOnPrimary,
      );

  static TextStyle buttonSmall({Color? color}) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textOnPrimary,
      );

  // ===== Special Text Styles =====
  static TextStyle subtitle({Color? color}) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle overline({Color? color}) => GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
        color: color ?? AppColors.textSecondary,
      );

  // ===== Link Text =====
  static TextStyle link({Color? color}) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.underline,
        color: color ?? AppColors.primaryRed,
      );
}
