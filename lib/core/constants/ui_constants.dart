import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// UI Constants for consistent spacing, sizing, and styling across the app
class UIConstants {
  UIConstants._();

  // Spacing
  static SizedBox get verticalSpaceSmall => SizedBox(height: 8.h);
  static SizedBox get verticalSpaceMedium => SizedBox(height: 16.h);
  static SizedBox get verticalSpaceLarge => SizedBox(height: 24.h);
  static SizedBox get verticalSpaceExtraLarge => SizedBox(height: 32.h);

  static SizedBox get horizontalSpaceSmall => SizedBox(width: 8.w);
  static SizedBox get horizontalSpaceMedium => SizedBox(width: 16.w);
  static SizedBox get horizontalSpaceLarge => SizedBox(width: 24.w);

  // Padding
  static EdgeInsets get paddingSmall => EdgeInsets.all(8.w);
  static EdgeInsets get paddingMedium => EdgeInsets.all(16.w);
  static EdgeInsets get paddingLarge => EdgeInsets.all(24.w);

  static EdgeInsets get paddingHorizontalMedium =>
      EdgeInsets.symmetric(horizontal: 16.w);
  static EdgeInsets get paddingVerticalMedium =>
      EdgeInsets.symmetric(vertical: 16.h);

  static EdgeInsets get paddingSymmetricMedium =>
      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h);
  static EdgeInsets get paddingSymmetricLarge =>
      EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h);

  // Border Radius
  static BorderRadius get borderRadiusSmall => BorderRadius.circular(8.r);
  static BorderRadius get borderRadiusMedium => BorderRadius.circular(12.r);
  static BorderRadius get borderRadiusLarge => BorderRadius.circular(16.r);
  static BorderRadius get borderRadiusExtraLarge => BorderRadius.circular(20.r);

  // Icon Sizes
  static double get iconSizeSmall => 16.r;
  static double get iconSizeMedium => 20.r;
  static double get iconSizeLarge => 24.r;
  static double get iconSizeExtraLarge => 40.r;

  // Font Sizes
  static double get fontSizeSmall => 12.sp;
  static double get fontSizeMedium => 14.sp;
  static double get fontSizeLarge => 16.sp;
  static double get fontSizeExtraLarge => 18.sp;
  static double get fontSizeTitle => 20.sp;

  // Elevation
  static double get elevationLow => 2.0;
  static double get elevationMedium => 4.0;
  static double get elevationHigh => 8.0;

  // Common Box Shadows
  static List<BoxShadow> get defaultShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // Animation Durations
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationLong = Duration(milliseconds: 500);
}
