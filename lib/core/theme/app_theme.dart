import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class AppTheme {
  // 🌓 الوضع الفاتح
  static ThemeData get lightTheme {
    return ThemeData();


    //   ThemeData(
    //   brightness: Brightness.light,
    //   primaryColor: AppColors.primaryColor,
    //   scaffoldBackgroundColor: AppColors.backgroundColor,
    //   fontFamily: GoogleFonts.almarai().fontFamily,
    //   colorScheme: ColorScheme(
    //     primary: AppColors.primaryColor, // اللون الثاني
    //     secondary: Colors.green, // اللون الثانوي الثاني
    //     surface: Colors.white, // خلفية التطبيقات
    //     error: Colors.red, // اللون الخاص بالأخطاء
    //     onPrimary: Colors.white, // اللون عند استخدام الـ primary
    //     onSecondary: Colors.black, // اللون عند استخدام الـ secondary
    //     onSurface: AppColors.lightGrey, // اللون عند استخدام الـ background
    //     onError: Colors.white, // اللون عند استخدام الـ error
    //     brightness: Brightness.light, // مستوى السطوع (فاتح أو غامق)
    //   ),
    //   appBarTheme: AppBarTheme(
    //     elevation: 0,
    //     scrolledUnderElevation: 0,
    //     centerTitle: true,
    //     backgroundColor: AppColors.backgroundColor,
    //     iconTheme: IconThemeData(color: AppColors.primaryColor),
    //
    //     titleTextStyle: TextStyle(
    //       color: AppColors.primaryColor,
    //       fontSize: 20.sp,
    //       fontWeight: FontWeight.bold,
    //
    //       fontFamily: GoogleFonts.almarai().fontFamily,
    //     ),
    //     actionsIconTheme: IconThemeData(
    //       color: AppColors.primaryColor,
    //     ),
    //   ),
    //   radioTheme: RadioThemeData(
    //     fillColor: WidgetStatePropertyAll(AppColors.primaryColor),
    //     // overlayColor: WidgetStatePropertyAll(
    //     //   AppColors.primaryColor.withValues(alpha: 0.2),
    //     // ),
    //   ),
    //
    //   switchTheme: SwitchThemeData(
    //     overlayColor: WidgetStatePropertyAll(
    //       AppColors.white.withValues(alpha: 0.4),
    //     ),
    //     thumbColor: WidgetStatePropertyAll(AppColors.white),
    //     trackColor: WidgetStatePropertyAll(AppColors.green),
    //     trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
    //   ),
    //   textTheme: TextTheme(
    //     // black
    //     displayLarge: textStyle(18.sp, FontWeight.bold, AppColors.black),
    //     displayMedium: textStyle(16.sp, FontWeight.w600, AppColors.black),
    //     displaySmall: textStyle(12.sp, FontWeight.w500, AppColors.black),
    //
    //     // grey
    //     bodyLarge: textStyle(18.sp, FontWeight.w500, AppColors.darkGrey),
    //     bodyMedium: textStyle(16.sp, FontWeight.normal, AppColors.greyMeduim),
    //     bodySmall: textStyle(12.sp, FontWeight.normal, AppColors.lightGrey),
    //
    //     // نصوص العناوين , primaryColor , blue
    //     headlineLarge: TextStyle(
    //       fontSize: 18.sp,
    //       fontWeight: FontWeight.bold,
    //       color: AppColors.primaryColor,
    //     ),
    //     headlineMedium: TextStyle(
    //       fontSize: 16.sp,
    //       fontWeight: FontWeight.w600,
    //       color: AppColors.primaryColor,
    //     ),
    //     headlineSmall: TextStyle(
    //       fontSize: 12.sp,
    //       fontWeight: FontWeight.w500,
    //       color: AppColors.primaryColor,
    //     ),
    //   ),
    //   cardColor: AppColors.primaryColor,
    //   buttonTheme: ButtonThemeData(
    //     buttonColor: AppColors.backgroundColor,
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    //   ),
    //   elevatedButtonTheme: ElevatedButtonThemeData(
    //     style: ElevatedButton.styleFrom(
    //       foregroundColor: Colors.white,
    //       backgroundColor: AppColors.primaryColor,
    //       textStyle: textStyle(16, FontWeight.bold, Colors.white),
    //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    //     ),
    //   ),
    //   iconTheme: const IconThemeData(color: Colors.black),
    // );
  }

  // // 🌙 الوضع الداكن
  // static ThemeData get darkTheme {
  //   return ThemeData(
  //     brightness: Brightness.dark,
  //     primaryColor: AppColors.primaryColor,
  //     scaffoldBackgroundColor: AppColors.backgroundColor,
  //     fontFamily: GoogleFonts.almarai().fontFamily,
  //     appBarTheme: const AppBarTheme(
  //       elevation: 0,
  //       centerTitle: true,
  //       backgroundColor: Colors.black,
  //       iconTheme: IconThemeData(color: Colors.white),
  //       titleTextStyle: TextStyle(
  //         color: Colors.white,
  //         fontSize: 18,
  //         fontWeight: FontWeight.bold,
  //       ),
  //     ),
  //     textTheme: TextTheme(
  //       // black
  //       displayLarge: textStyle(24.sp, FontWeight.bold, AppColors.black),
  //       displayMedium: textStyle(20.sp, FontWeight.w600, AppColors.black),
  //       displaySmall: textStyle(18.sp, FontWeight.w500, AppColors.black),

  //      // grey
  //       bodyLarge: textStyle(14.sp, FontWeight.w500, AppColors.darkGrey),
  //       bodyMedium: textStyle(12.sp, FontWeight.normal, AppColors.greyMeduim),
  //       bodySmall: textStyle(10.sp, FontWeight.normal, AppColors.lightGrey),

  //       // نصوص العناوين , primaryColor , blue
  //       headlineLarge: TextStyle(
  //         fontSize: 16.sp,
  //         fontWeight: FontWeight.bold,
  //         color: AppColors.primaryColor,
  //       ),
  //       headlineMedium: TextStyle(
  //         fontSize: 16.sp,
  //         fontWeight: FontWeight.w600,
  //         color: AppColors.primaryColor,
  //       ),
  //       headlineSmall: TextStyle(
  //         fontSize: 12.sp,
  //         fontWeight: FontWeight.w500,
  //         color: AppColors.primaryColor,
  //       ),
  //     ),

  //     cardColor: Colors.grey[900],
  //     buttonTheme: ButtonThemeData(
  //       buttonColor: AppColors.primaryColor,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //     ),
  //     elevatedButtonTheme: ElevatedButtonThemeData(
  //       style: ElevatedButton.styleFrom(
  //         foregroundColor: Colors.white,
  //         backgroundColor: AppColors.primaryColor,
  //         textStyle: textStyle(16, FontWeight.bold, Colors.white),
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //       ),
  //     ),
  //     iconTheme: const IconThemeData(color: Colors.white),
  //   );
  // }

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