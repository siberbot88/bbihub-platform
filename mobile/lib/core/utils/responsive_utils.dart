import 'package:flutter/material.dart';

/// Responsive utility class for handling different screen sizes
/// and providing consistent responsive behavior across the app
class ResponsiveUtils {
  ResponsiveUtils._();

  // Breakpoints
  static const double phoneMaxWidth = 600;
  static const double tabletMaxWidth = 900;
  static const double baseWidth = 375; // iPhone X width

  /// Check if current device is a small phone (< 360px width)
  static bool isSmallPhone(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }

  /// Check if current device is a phone (< 600px width)
  static bool isPhone(BuildContext context) {
    return MediaQuery.of(context).size.width < phoneMaxWidth;
  }

  /// Check if current device is a tablet (600-900px width)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= phoneMaxWidth && width < tabletMaxWidth;
  }

  /// Check if current device is a desktop (>= 900px width)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletMaxWidth;
  }

  /// Get responsive font size based on screen width
  /// [base] is the base font size for 375px width screens
  static double getResponsiveFontSize(BuildContext context, double base) {
    final width = MediaQuery.of(context).size.width;
    return base * (width / baseWidth);
  }

  /// Get responsive value based on screen type
  /// Returns [phoneValue] for phones, [tabletValue] for tablets, [desktopValue] for desktops
  static T getResponsiveValue<T>({
    required BuildContext context,
    required T phoneValue,
    T? tabletValue,
    T? desktopValue,
  }) {
    if (isDesktop(context)) {
      return desktopValue ?? tabletValue ?? phoneValue;
    } else if (isTablet(context)) {
      return tabletValue ?? phoneValue;
    }
    return phoneValue;
  }

  /// Get screen width percentage
  /// [percentage] should be between 0.0 and 1.0
  static double widthPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage;
  }

  /// Get screen height percentage
  /// [percentage] should be between 0.0 and 1.0
  static double heightPercentage(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isTablet(context) || isDesktop(context)) {
      return const EdgeInsets.all(24);
    }
    return const EdgeInsets.all(16);
  }

  /// Get responsive horizontal padding
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 48);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32);
    }
    return const EdgeInsets.symmetric(horizontal: 16);
  }
}
