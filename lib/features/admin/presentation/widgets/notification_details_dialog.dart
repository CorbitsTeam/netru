import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/admin_notification_entity.dart';

class NotificationDetailsDialog extends StatelessWidget {
  final AdminNotificationEntity notification;

  const NotificationDetailsDialog({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.all(24.w),
        constraints: BoxConstraints(maxWidth: 500.w, maxHeight: 600.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  _getTypeIcon(notification.notificationType),
                  color: _getTypeColor(notification.notificationType),
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'تفاصيل الإشعار',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
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
                    // Basic Info
                    _buildInfoSection('المعلومات الأساسية', [
                      _buildInfoRow('العنوان', notification.title),
                      if (notification.titleAr != null)
                        _buildInfoRow(
                          'العنوان بالعربية',
                          notification.titleAr!,
                        ),
                      _buildInfoRow('المحتوى', notification.body),
                      if (notification.bodyAr != null)
                        _buildInfoRow('المحتوى بالعربية', notification.bodyAr!),
                    ]),

                    SizedBox(height: 20.h),

                    // Status Info
                    _buildInfoSection('معلومات الحالة', [
                      _buildInfoRow(
                        'النوع',
                        notification.notificationType.arabicName,
                      ),
                      _buildInfoRow(
                        'الأولوية',
                        notification.priority.arabicName,
                      ),
                      _buildInfoRow('الحالة', _getStatusText(notification)),
                      _buildInfoRow(
                        'تاريخ الإنشاء',
                        _formatDateTime(notification.createdAt),
                      ),
                      if (notification.sentAt != null)
                        _buildInfoRow(
                          'تاريخ الإرسال',
                          _formatDateTime(notification.sentAt!),
                        ),
                      if (notification.readAt != null)
                        _buildInfoRow(
                          'تاريخ القراءة',
                          _formatDateTime(notification.readAt!),
                        ),
                    ]),

                    SizedBox(height: 20.h),

                    // Technical Info
                    if (notification.fcmMessageId != null ||
                        notification.referenceId != null ||
                        notification.data != null) ...[
                      _buildInfoSection('المعلومات التقنية', [
                        if (notification.fcmMessageId != null)
                          _buildInfoRow('معرف FCM', notification.fcmMessageId!),
                        if (notification.referenceId != null)
                          _buildInfoRow(
                            'معرف المرجع',
                            notification.referenceId!,
                          ),
                        if (notification.referenceType != null)
                          _buildInfoRow(
                            'نوع المرجع',
                            _getReferenceTypeText(notification.referenceType!),
                          ),
                      ]),

                      if (notification.data != null &&
                          notification.data!.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        _buildDataSection(notification.data!),
                      ],
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
                  child: const Text('إغلاق'),
                ),
                SizedBox(width: 12.w),
                if (!notification.isSent) ...[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Implement send now
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                    ),
                    child: const Text(
                      'إرسال الآن',
                      style: TextStyle(color: Colors.white),
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

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2E7D32),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'البيانات الإضافية',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2E7D32),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                data.entries
                    .map(
                      (entry) =>
                          _buildInfoRow(entry.key, entry.value.toString()),
                    )
                    .toList(),
          ),
        ),
      ],
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
        return const Color(0xFF1976D2);
      case NotificationType.reportUpdate:
        return const Color(0xFFFF9800);
      case NotificationType.reportComment:
        return const Color(0xFF9C27B0);
      case NotificationType.system:
        return const Color(0xFFD32F2F);
      case NotificationType.general:
        return const Color(0xFF388E3C);
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

  String _getReferenceTypeText(ReferenceType type) {
    switch (type) {
      case ReferenceType.newsArticle:
        return 'مقال إخباري';
      case ReferenceType.report:
        return 'تقرير';
      case ReferenceType.system:
        return 'نظام';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
