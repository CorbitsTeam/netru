import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // 🌓 الوضع الفاتح
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: GoogleFonts.almarai().fontFamily,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryColor,
        secondary: AppColors.green,
        surface: Colors.white,
        error: AppColors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.grey,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        titleTextStyle: TextStyle(
          color: AppColors.primaryColor,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          fontFamily: GoogleFonts.almarai().fontFamily,
        ),
        actionsIconTheme: const IconThemeData(color: AppColors.primaryColor),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(AppColors.primaryColor),
      ),
      switchTheme: SwitchThemeData(
        overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.4)),
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.all(AppColors.green),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      textTheme: TextTheme(
        // Display styles for headers
        displayLarge: textStyle(24.sp, FontWeight.bold, Colors.black),
        displayMedium: textStyle(20.sp, FontWeight.w600, Colors.black),
        displaySmall: textStyle(18.sp, FontWeight.w500, Colors.black),

        // Headline styles for section titles
        headlineLarge: textStyle(
          22.sp,
          FontWeight.bold,
          AppColors.primaryColor,
        ),
        headlineMedium: textStyle(
          18.sp,
          FontWeight.w600,
          AppColors.primaryColor,
        ),
        headlineSmall: textStyle(
          16.sp,
          FontWeight.w500,
          AppColors.primaryColor,
        ),

        // Title styles
        titleLarge: textStyle(20.sp, FontWeight.w600, Colors.black),
        titleMedium: textStyle(16.sp, FontWeight.w500, Colors.black),
        titleSmall: textStyle(14.sp, FontWeight.w500, Colors.black),

        // Body text styles
        bodyLarge: textStyle(16.sp, FontWeight.normal, Colors.black),
        bodyMedium: textStyle(14.sp, FontWeight.normal, AppColors.grey),
        bodySmall: textStyle(12.sp, FontWeight.normal, AppColors.grey),

        // Label styles for buttons and small text
        labelLarge: textStyle(14.sp, FontWeight.w500, Colors.black),
        labelMedium: textStyle(12.sp, FontWeight.w500, AppColors.grey),
        labelSmall: textStyle(10.sp, FontWeight.w500, AppColors.grey),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primaryColor,
          textStyle: textStyle(16.sp, FontWeight.bold, Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
          textStyle: textStyle(16.sp, FontWeight.w600, AppColors.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          textStyle: textStyle(14.sp, FontWeight.w600, AppColors.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.red),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        hintStyle: textStyle(14.sp, FontWeight.normal, AppColors.grey),
        labelStyle: textStyle(14.sp, FontWeight.w500, AppColors.grey),
      ),
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }

  // 🌙 الوضع الداكن
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: Colors.grey[900]!,
      fontFamily: GoogleFonts.almarai().fontFamily,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryColor,
        secondary: AppColors.green,
        surface: Colors.grey[800]!,
        error: AppColors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          fontFamily: GoogleFonts.almarai().fontFamily,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: textStyle(24.sp, FontWeight.bold, Colors.white),
        displayMedium: textStyle(20.sp, FontWeight.w600, Colors.white),
        displaySmall: textStyle(18.sp, FontWeight.w500, Colors.white),

        headlineLarge: textStyle(
          22.sp,
          FontWeight.bold,
          AppColors.primaryColor,
        ),
        headlineMedium: textStyle(
          18.sp,
          FontWeight.w600,
          AppColors.primaryColor,
        ),
        headlineSmall: textStyle(
          16.sp,
          FontWeight.w500,
          AppColors.primaryColor,
        ),

        titleLarge: textStyle(20.sp, FontWeight.w600, Colors.white),
        titleMedium: textStyle(16.sp, FontWeight.w500, Colors.white),
        titleSmall: textStyle(14.sp, FontWeight.w500, Colors.white),

        bodyLarge: textStyle(16.sp, FontWeight.normal, Colors.white),
        bodyMedium: textStyle(14.sp, FontWeight.normal, Colors.grey[300]!),
        bodySmall: textStyle(12.sp, FontWeight.normal, Colors.grey[400]!),

        labelLarge: textStyle(14.sp, FontWeight.w500, Colors.white),
        labelMedium: textStyle(12.sp, FontWeight.w500, Colors.grey[300]!),
        labelSmall: textStyle(10.sp, FontWeight.w500, Colors.grey[400]!),
      ),
      cardTheme: CardTheme(
        color: Colors.grey[800],
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primaryColor,
          textStyle: textStyle(16.sp, FontWeight.bold, Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
          textStyle: textStyle(16.sp, FontWeight.w600, AppColors.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          textStyle: textStyle(14.sp, FontWeight.w600, AppColors.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  // 🎨 دالة لإنشاء TextStyle بسهولة
  static TextStyle textStyle(double size, FontWeight weight, Color color) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      fontFamily: GoogleFonts.almarai().fontFamily,
    );
  }
}
