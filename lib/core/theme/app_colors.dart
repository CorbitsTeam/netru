import 'package:flutter/material.dart';

class AppColors {
  // الألوان الأساسية الموجودة
  static const Color primaryColor = Color(0xFF002768);
  static const Color grey = Color(0xFF4B5563);
  static const Color orange = Color(0xFFFF582F);
  static const Color green = Color(0xFF16A34A);
  static const Color red = Color(0xFFDC2626);

  // الألوان الجديدة المحسنة
  static const Color primary = primaryColor;
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);

  // الألوان الثانوية
  static const Color secondary = Color(0xFF64748B);
  static const Color secondaryLight = Color(0xFF94A3B8);
  static const Color secondaryDark = Color(0xFF475569);

  // ألوان النصوص
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);

  // ألوان الخلفيات
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // ألوان الحدود
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color borderDark = Color(0xFFCBD5E1);

  // ألوان الحالات
  static const Color success = green;
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);

  static const Color error = red;
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);

  static const Color warning = orange;
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);

  // ألوان إضافية
  static const Color disabled = Color(0xFFE2E8F0);
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x80000000);

  // تدرجات الألوان
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
