import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/admin_notification_entity.dart';

class SimpleNotificationDetailsDialog extends StatelessWidget {
  final AdminNotificationEntity notification;

  const SimpleNotificationDetailsDialog({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Container(
        padding: EdgeInsets.all(24.w),
        constraints: BoxConstraints(maxWidth: 400.w, maxHeight: 500.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: _getTypeColor(
                      notification.notificationType,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    _getTypeIcon(notification.notificationType),
                    color: _getTypeColor(notification.notificationType),
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'تفاصيل الإشعار',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: AppColors.textSecondary,
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    _buildInfoItem('العنوان', notification.title, Icons.title),

                    SizedBox(height: 16.h),

                    // Body
                    _buildInfoItem('المحتوى', notification.body, Icons.message),

                    SizedBox(height: 16.h),

                    // Type
                    _buildInfoItem(
                      'النوع',
                      _getTypeArabicName(notification.notificationType),
                      Icons.category,
                    ),

                    SizedBox(height: 16.h),

                    // Status
                    _buildInfoItem(
                      'الحالة',
                      _getStatusText(notification),
                      Icons.info,
                    ),

                    SizedBox(height: 16.h),

                    // Created at
                    _buildInfoItem(
                      'تاريخ الإنشاء',
                      _formatDateTime(notification.createdAt),
                      Icons.access_time,
                    ),

                    if (notification.sentAt != null) ...[
                      SizedBox(height: 16.h),
                      _buildInfoItem(
                        'تاريخ الإرسال',
                        _formatDateTime(notification.sentAt!),
                        Icons.send,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'إغلاق',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                if (!notification.isSent) ...[
                  SizedBox(width: 12.w),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Implement send now
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'إرسال الآن',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.news:
        return Icons.article;
      case NotificationType.reportUpdate:
        return Icons.update;
      case NotificationType.reportComment:
        return Icons.comment;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.general:
        return Icons.notifications;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.news:
        return AppColors.info;
      case NotificationType.reportUpdate:
        return AppColors.warning;
      case NotificationType.reportComment:
        return AppColors.secondary;
      case NotificationType.system:
        return AppColors.error;
      case NotificationType.general:
        return AppColors.primary;
    }
  }

  String _getTypeArabicName(NotificationType type) {
    switch (type) {
      case NotificationType.general:
        return 'عام';
      case NotificationType.news:
        return 'أخبار';
      case NotificationType.reportUpdate:
        return 'تحديث بلاغ';
      case NotificationType.reportComment:
        return 'تعليق بلاغ';
      case NotificationType.system:
        return 'نظام';
    }
  }

  String _getStatusText(AdminNotificationEntity notification) {
    if (notification.isSent) {
      return 'تم الإرسال';
    } else if (notification.sentAt != null) {
      return 'مجدول';
    } else if (notification.fcmMessageId != null) {
      return 'قيد المعالجة';
    } else {
      return 'مسودة';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
