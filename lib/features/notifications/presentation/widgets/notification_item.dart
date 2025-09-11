import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/features/notifications/data/models/notifications_model.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onDelete;
  final int index;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onDelete,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: _getIconColor().withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getIconColor().withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(_getIcon(), color: _getIconColor(), size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _getTextColor(),
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  notification.subtitle,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: _getTextColor().withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getIconColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        _formatDate(notification.createdAt),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: _getTextColor().withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.close, color: Colors.grey[600], size: 16.sp),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (notification.type) {
      case NotificationType.danger:
        return const Color(0xFFF1CBD2);
      case NotificationType.success:
        return const Color(0xFFD3F3E5);
      case NotificationType.warning:
        return const Color(0xFFF7DFB6);
    }
  }

  Color _getTextColor() {
    switch (notification.type) {
      case NotificationType.danger:
        return const Color(0xFF681923);
      case NotificationType.success:
        return const Color(0xFF30624A);
      case NotificationType.warning:
        return const Color(0xFF673617);
    }
  }

  Color _getIconColor() {
    switch (notification.type) {
      case NotificationType.danger:
        return const Color(0xFFDC3545);
      case NotificationType.success:
        return const Color(0xFF198754);
      case NotificationType.warning:
        return const Color(0xFFFFC107);
    }
  }

  IconData _getIcon() {
    switch (notification.type) {
      case NotificationType.danger:
        return Icons.error;
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.warning:
        return Icons.warning;
    }
  }

  String _formatDate(DateTime date) {
    final arabicMonths = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    final day = date.day;
    final month = arabicMonths[date.month - 1];
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day $month، $year - $hour:$minute';
  }
}
