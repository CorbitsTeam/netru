import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Material(
        color: notification.isRead ? Colors.white : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12.r),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification Icon
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: _getIconColor().withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getIcon(), color: _getIconColor(), size: 20.sp),
                ),
                SizedBox(width: 12.w),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        notification.getLocalizedTitle(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight:
                              notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),

                      // Body
                      Text(
                        notification.getLocalizedBody(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),

                      // Time and actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Time
                          Text(
                            _getFormattedTime(),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          // Actions
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Priority indicator
                              if (notification.priority ==
                                      NotificationPriority.high ||
                                  notification.priority ==
                                      NotificationPriority.urgent)
                                Container(
                                  width: 8.w,
                                  height: 8.h,
                                  decoration: BoxDecoration(
                                    color:
                                        notification.priority ==
                                                NotificationPriority.urgent
                                            ? Colors.red
                                            : Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                ),

                              if (notification.priority ==
                                      NotificationPriority.high ||
                                  notification.priority ==
                                      NotificationPriority.urgent)
                                SizedBox(width: 8.w),

                              // Mark as read button
                              if (!notification.isRead && onMarkAsRead != null)
                                GestureDetector(
                                  onTap: onMarkAsRead,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Text(
                                      'قراءة',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),

                              if (!notification.isRead && onMarkAsRead != null)
                                SizedBox(width: 8.w),

                              // Delete button
                              if (onDelete != null)
                                GestureDetector(
                                  onTap: onDelete,
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.grey[400],
                                    size: 16.sp,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Unread indicator
                if (!notification.isRead)
                  Container(
                    width: 8.w,
                    height: 8.h,
                    margin: EdgeInsets.only(top: 4.h, left: 8.w),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (notification.type) {
      case NotificationType.news:
        return Icons.article_outlined;
      case NotificationType.reportUpdate:
        return Icons.update;
      case NotificationType.reportComment:
        return Icons.comment_outlined;
      case NotificationType.system:
        return Icons.settings_outlined;
      case NotificationType.general:
        return Icons.notifications_outlined;
    }
  }

  Color _getIconColor() {
    switch (notification.type) {
      case NotificationType.news:
        return Colors.green;
      case NotificationType.reportUpdate:
        return Colors.orange;
      case NotificationType.reportComment:
        return Colors.blue;
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.general:
        return Colors.purple;
    }
  }

  String _getFormattedTime() {
    final now = DateTime.now();
    final difference = now.difference(notification.createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} يوم${difference.inDays > 1 ? '' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ساعة${difference.inHours > 1 ? '' : ''}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} دقيقة${difference.inMinutes > 1 ? '' : ''}';
    } else {
      return 'الآن';
    }
  }
}
