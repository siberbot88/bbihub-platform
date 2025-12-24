import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primary = Color(0xFFDC2828);
  static const Color backgroundLight = Color(0xFFF8F6F6);
  static const Color backgroundDark = Color(0xFF201212);
  static const Color cardDark = Color(0xFF2A1A1A);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: ColorScheme.light(
      primary: primary,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSurface: const Color(0xFF1A0E0E),
    ),
    textTheme: GoogleFonts.manropeTextTheme(ThemeData.light().textTheme).copyWith(
      bodyLarge: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF1A0E0E),
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF1A0E0E),
      ),
      bodySmall: GoogleFonts.manrope(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: Colors.grey[500],
      ),
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    colorScheme: ColorScheme.dark(
      primary: primary,
      surface: cardDark,
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),
    textTheme: GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme).copyWith(
      bodyLarge: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      bodySmall: GoogleFonts.manrope(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: Colors.grey[400],
      ),
    ),
    cardTheme: const CardThemeData(
      color: cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
  );

  // Helper untuk heading text style (Poppins)
  static TextStyle heading({
    required BuildContext context,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.poppins(
      fontSize: fontSize ?? 28,
      fontWeight: fontWeight ?? FontWeight.bold,
      color: color ?? (isDark ? Colors.white : const Color(0xFF1A0E0E)),
    );
  }
}
