import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTextStyles {
  // الخط الأساسي
  static const String _fontFamily = 'Almarai';

  // أحجام الخطوط
  static final double _displayLarge = 32.sp;
  static final double _displayMedium = 28.sp;
  static final double _displaySmall = 24.sp;
  static final double _headlineLarge = 22.sp;
  static final double _headlineMedium = 20.sp;
  static final double _headlineSmall = 18.sp;
  static final double _titleLarge = 16.sp;
  static final double _titleMedium = 14.sp;
  static final double _titleSmall = 12.sp;
  static final double _bodyLarge = 16.sp;
  static final double _bodyMedium = 14.sp;
  static final double _bodySmall = 12.sp;
  static final double _labelLarge = 14.sp;
  static final double _labelMedium = 12.sp;
  static final double _labelSmall = 10.sp;

  // Display Styles
  static TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _displayLarge,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _displayMedium,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static TextStyle displaySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _displaySmall,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  // Headline Styles
  static TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _headlineLarge,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _headlineMedium,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _headlineSmall,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // Title Styles
  static TextStyle titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _titleLarge,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _titleMedium,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static TextStyle titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _titleSmall,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  // Body Styles
  static TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _bodyLarge,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _bodyMedium,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.textPrimary,
  );

  static TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _bodySmall,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.textSecondary,
  );

  // Label Styles
  static TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _labelLarge,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _labelMedium,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _labelSmall,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  // Button Styles
  static TextStyle buttonLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _bodyLarge,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: Colors.white,
  );

  static TextStyle buttonMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _bodyMedium,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: Colors.white,
  );

  static TextStyle buttonSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _bodySmall,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: Colors.white,
  );

  // Caption Style
  static TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _labelSmall,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textTertiary,
  );

  // Error Style
  static TextStyle error = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _bodySmall,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.error,
  );

  // Link Style
  static TextStyle link = TextStyle(
    fontFamily: _fontFamily,
    fontSize: _bodyMedium,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
  );
}
