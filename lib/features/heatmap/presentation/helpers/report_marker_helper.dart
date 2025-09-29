import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Helper class for report markers on the map
/// Provides methods for getting icons and colors based on report type and priority
class ReportMarkerHelper {
  /// Get icon based on report type
  static IconData getReportIcon(String reportType) {
    final type = reportType.toLowerCase();

    // Theft - سرقة
    if (type.contains('theft') || type.contains('سرقة')) {
      return Icons.security_rounded;
    }

    // Domestic Violence - عنف أسري
    if (type.contains('domestic_violence') ||
        type.contains('violence') ||
        type.contains('عنف أسري') ||
        type.contains('عنف')) {
      return Icons.home_rounded;
    }

    // Missing Persons - بلاغ مفقودات
    if (type.contains('missing') ||
        type.contains('مفقودات') ||
        type.contains('مفقود')) {
      return Icons.person_search_rounded;
    }

    // Riots / Illegal Assembly - أعمال شغب او تجمع غير قانوني
    if (type.contains('riot') ||
        type.contains('شغب') ||
        type.contains('تجمع')) {
      return Icons.groups_rounded;
    }

    // Traffic Accident - حادث مروري جسيم
    if (type.contains('traffic') ||
        type.contains('accident') ||
        type.contains('مرور') ||
        type.contains('حادث')) {
      return Icons.car_crash_rounded;
    }

    // Fire / Sabotage - حريق / محاولة تخريب
    if (type.contains('fire') ||
        type.contains('vandalism') ||
        type.contains('حريق') ||
        type.contains('تخريب')) {
      return Icons.local_fire_department_rounded;
    }

    // Bribery / Corruption - رشوة / فساد مالي
    if (type.contains('bribery') ||
        type.contains('corruption') ||
        type.contains('رشوة') ||
        type.contains('فساد')) {
      return Icons.monetization_on_rounded;
    }

    // Cybercrime - جريمة إلكترونية
    if (type.contains('cyber') ||
        type.contains('إلكترونية') ||
        type.contains('اختراق')) {
      return Icons.computer_rounded;
    }

    // Blackmail / Threats - ابتزاز / تهديد
    if (type.contains('blackmail') ||
        type.contains('threat') ||
        type.contains('ابتزاز') ||
        type.contains('تهديد')) {
      return Icons.warning_amber_rounded;
    }

    // Kidnapping / Disappearance - خطف / إختفاء
    if (type.contains('kidnap') ||
        type.contains('disappear') ||
        type.contains('خطف') ||
        type.contains('اختفاء')) {
      return Icons.person_off_rounded;
    }

    // Unlicensed Weapons - أسلحة غير مرخصة
    if (type.contains('weapon') ||
        type.contains('أسلحة') ||
        type.contains('سلاح')) {
      return Icons.dangerous_rounded;
    }

    // Drugs - مخدرات
    if (type.contains('drug') ||
        type.contains('مخدرات') ||
        type.contains('مخدر')) {
      return Icons.local_pharmacy_rounded;
    }

    // Physical Assault - اعتداء جسدي
    if (type.contains('assault') ||
        type.contains('اعتداء') ||
        type.contains('ضرب')) {
      return Icons.front_hand_rounded;
    }

    // Terrorism / Suspicious Activity - إرهاب / نشاط مشبوه
    if (type.contains('terrorism') ||
        type.contains('suspicious') ||
        type.contains('إرهاب') ||
        type.contains('مشبوه')) {
      return Icons.report_problem_rounded;
    }

    // Murder / Attempted Murder - قتل / محاولة قتل
    if (type.contains('murder') ||
        type.contains('kill') ||
        type.contains('قتل')) {
      return Icons.cancel_rounded;
    }

    // Armed Robbery - سطو مسلح
    if (type.contains('armed_robbery') ||
        type.contains('robbery') ||
        type.contains('سطو')) {
      return Icons.gpp_bad_rounded;
    }

    // Other Report - بلاغ آخر
    if (type.contains('other') || type.contains('آخر')) {
      return Icons.description_rounded;
    }

    // Default fallback
    return Icons.report_rounded;
  }

  /// Get color based on priority level
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return AppColors.red; // Red for most dangerous
      case 'high':
        return AppColors.orange; // Orange for high priority
      case 'medium':
        return AppColors.green; // Green for medium/least dangerous
      case 'low':
        return AppColors.info; // Blue for low priority
      default:
        return AppColors.grey; // Grey for unknown
    }
  }

  /// Get priority display name in Arabic
  static String getPriorityNameAr(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return 'عاجل';
      case 'high':
        return 'عالي';
      case 'medium':
        return 'متوسط';
      case 'low':
        return 'منخفض';
      default:
        return 'غير محدد';
    }
  }

  /// Get cluster color based on report count
  static Color getClusterColor(int reportCount, String highestPriority) {
    // Color based on report count thresholds
    if (reportCount >= 20) {
      return AppColors.red; // Red for 20 or more
    } else if (reportCount >= 15) {
      return AppColors.orange; // Orange for 15-19
    } else if (reportCount >= 10) {
      return AppColors.yellow; // Yellow for 10-14
    }

    return AppColors.green; // Green for less than 10
  }

  /// Get radius circle opacity based on priority
  static double getRadiusOpacity(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return 0.3;
      case 'high':
        return 0.2;
      case 'medium':
        return 0.15;
      default:
        return 0.1;
    }
  }

  /// Get radius size based on priority and report count
  static double getRadiusSize(String priority, int reportCount) {
    double baseSize = 30.0;

    // Adjust based on priority
    if (priority == 'urgent') {
      baseSize = 50.0;
    } else if (priority == 'high') {
      baseSize = 40.0;
    }

    // Adjust based on count
    if (reportCount >= 20) {
      baseSize += 30.0;
    } else if (reportCount >= 10) {
      baseSize += 20.0;
    } else if (reportCount >= 5) {
      baseSize += 10.0;
    }

    return baseSize;
  }

  /// Check if report should show pulse animation
  static bool shouldShowPulse(String priority) {
    return priority.toLowerCase() == 'urgent';
  }

  /// Get report type display name in Arabic
  static String getReportTypeNameAr(String reportType) {
    final type = reportType.toLowerCase();

    if (type.contains('theft') || type.contains('سرقة')) {
      return 'سرقة';
    }
    if (type.contains('domestic_violence') || type.contains('عنف أسري')) {
      return 'عنف أسري';
    }
    if (type.contains('missing') || type.contains('مفقودات')) {
      return 'بلاغ مفقودات';
    }
    if (type.contains('riot') || type.contains('شغب')) {
      return 'أعمال شغب';
    }
    if (type.contains('traffic') || type.contains('حادث مروري')) {
      return 'حادث مروري جسيم';
    }
    if (type.contains('fire') || type.contains('حريق')) {
      return 'حريق / محاولة تخريب';
    }
    if (type.contains('bribery') || type.contains('رشوة')) {
      return 'رشوة / فساد مالي';
    }
    if (type.contains('cyber') || type.contains('إلكترونية')) {
      return 'جريمة إلكترونية';
    }
    if (type.contains('blackmail') || type.contains('ابتزاز')) {
      return 'ابتزاز / تهديد';
    }
    if (type.contains('kidnap') || type.contains('خطف')) {
      return 'خطف / إختفاء';
    }
    if (type.contains('weapon') || type.contains('أسلحة')) {
      return 'أسلحة غير مرخصة';
    }
    if (type.contains('drug') || type.contains('مخدرات')) {
      return 'مخدرات';
    }
    if (type.contains('assault') || type.contains('اعتداء')) {
      return 'اعتداء جسدي';
    }
    if (type.contains('terrorism') || type.contains('إرهاب')) {
      return 'إرهاب / نشاط مشبوه';
    }
    if (type.contains('murder') || type.contains('قتل')) {
      return 'قتل / محاولة قتل';
    }
    if (type.contains('robbery') || type.contains('سطو')) {
      return 'سطو مسلح';
    }

    return reportType; // Return original if not found
  }
}