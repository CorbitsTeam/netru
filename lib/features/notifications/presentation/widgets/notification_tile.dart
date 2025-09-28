import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationTile extends StatefulWidget {
  final NotificationEntity notification;
  final VoidCallback? onOpen; // for navigation/opening
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onOpen,
    this.onMarkAsRead,
    this.onDelete,
  });

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile>
    with TickerProviderStateMixin {
  bool _expanded = false;

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
    });

    // Mark as read when expanded
    if (_expanded &&
        !widget.notification.isRead &&
        widget.onMarkAsRead != null) {
      widget.onMarkAsRead!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notification = widget.notification;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Material(
        color: _getCardBackgroundColor(),
        borderRadius: BorderRadius.circular(16.r),
        elevation: notification.isRead ? 1 : 3,
        shadowColor: AppColors.shadow,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color:
                  notification.isRead
                      ? AppColors.borderLight
                      : _getTypeAccentColor().withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(16.r),
            splashColor: _getTypeAccentColor().withOpacity(0.1),
            highlightColor: _getTypeAccentColor().withOpacity(0.05),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: Container(
                padding: EdgeInsets.all(12.r),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notification Icon
                    Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getTypeAccentColor().withOpacity(0.15),
                            _getTypeAccentColor().withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: _getTypeAccentColor().withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        _getIcon(),
                        color: _getTypeAccentColor(),
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: 14.w),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _getTypeAccentColor().withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: _getTypeAccentColor().withOpacity(
                                      0.3,
                                    ),
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  _getTypeLabel(),
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: _getTypeAccentColor(),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (notification.priority ==
                                      NotificationPriority.high ||
                                  notification.priority ==
                                      NotificationPriority.urgent) ...[
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        notification.priority ==
                                                NotificationPriority.urgent
                                            ? AppColors.error.withOpacity(0.1)
                                            : AppColors.warning.withOpacity(
                                              0.1,
                                            ),
                                    borderRadius: BorderRadius.circular(6.r),
                                    border: Border.all(
                                      color:
                                          notification.priority ==
                                                  NotificationPriority.urgent
                                              ? AppColors.error.withOpacity(0.3)
                                              : AppColors.warning.withOpacity(
                                                0.3,
                                              ),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        notification.priority ==
                                                NotificationPriority.urgent
                                            ? Icons.priority_high_rounded
                                            : Icons.flag_rounded,
                                        size: 10.sp,
                                        color:
                                            notification.priority ==
                                                    NotificationPriority.urgent
                                                ? AppColors.error
                                                : AppColors.warning,
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        notification.priority ==
                                                NotificationPriority.urgent
                                            ? 'عاجل'
                                            : 'مهم',
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              notification.priority ==
                                                      NotificationPriority
                                                          .urgent
                                                  ? AppColors.error
                                                  : AppColors.warning,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 8.h),

                          // Title
                          Text(
                            notification.getLocalizedTitle(),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight:
                                  notification.isRead
                                      ? FontWeight.w600
                                      : FontWeight.w700,
                              color:
                                  notification.isRead
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                              height: 1.4,
                              letterSpacing: 0.2,
                            ),
                            maxLines: _expanded ? 5 : 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6.h),

                          // Body (show more when expanded)
                          Text(
                            notification.getLocalizedBody(),
                            style: TextStyle(
                              fontSize: 13.sp,
                              color:
                                  notification.isRead
                                      ? AppColors.textTertiary
                                      : AppColors.textSecondary,
                              height: 1.5,
                              letterSpacing: 0.1,
                            ),
                            maxLines: _expanded ? 10 : 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 12.h),

                          // Time and actions
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: AppColors.borderLight,
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 12.sp,
                                      color: AppColors.textTertiary,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      _getFormattedTime(),
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: AppColors.textTertiary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Row(
                                children: [
                                  if (_expanded && widget.onOpen != null)
                                    TextButton(
                                      onPressed: widget.onOpen,
                                      child: const Text('فتح'),
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
                        width: 10.w,
                        height: 10.h,
                        margin: EdgeInsets.only(top: 6.h, left: 8.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getTypeAccentColor(),
                              _getTypeAccentColor().withOpacity(0.8),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _getTypeAccentColor().withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Get background color based on read status and type
  Color _getCardBackgroundColor() {
    if (widget.notification.isRead) {
      return AppColors.surface;
    }
    return _getTypeAccentColor().withOpacity(0.02);
  }

  // Get type-specific accent color
  Color _getTypeAccentColor() {
    switch (widget.notification.type) {
      case NotificationType.news:
        return AppColors.success;
      case NotificationType.reportUpdate:
        return AppColors.warning;
      case NotificationType.reportComment:
        return AppColors.info;
      case NotificationType.system:
        return AppColors.secondary;
      case NotificationType.general:
        return AppColors.primary;
    }
  }

  // Get type label in Arabic
  String _getTypeLabel() {
    switch (widget.notification.type) {
      case NotificationType.news:
        return 'أخبار';
      case NotificationType.reportUpdate:
        return 'تحديث بلاغ';
      case NotificationType.reportComment:
        return 'تعليق';
      case NotificationType.system:
        return 'النظام';
      case NotificationType.general:
        return 'عام';
    }
  }

  // Get icon based on notification type
  IconData _getIcon() {
    switch (widget.notification.type) {
      case NotificationType.news:
        return Icons.newspaper_rounded;
      case NotificationType.reportUpdate:
        return Icons.assignment_turned_in_rounded;
      case NotificationType.reportComment:
        return Icons.comment_rounded;
      case NotificationType.system:
        return Icons.admin_panel_settings_rounded;
      case NotificationType.general:
        return Icons.notifications_active_rounded;
    }
  }

  String _getFormattedTime() {
    final now = DateTime.now();
    final difference = now.difference(widget.notification.createdAt);

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
