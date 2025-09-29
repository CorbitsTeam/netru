import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/admin_notification_entity.dart';
import '../cubit/admin_notifications_cubit.dart';
import '../widgets/mobile_admin_drawer.dart';
import '../widgets/simple_notification_details_dialog.dart';

class SimpleAdminNotificationsPage extends StatefulWidget {
  const SimpleAdminNotificationsPage({super.key});

  @override
  State<SimpleAdminNotificationsPage> createState() =>
      _SimpleAdminNotificationsPageState();
}

class _SimpleAdminNotificationsPageState
    extends State<SimpleAdminNotificationsPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  NotificationType _selectedType = NotificationType.general;
  TargetType _selectedTarget = TargetType.all;
  bool _showCreateForm = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<AdminNotificationsCubit>().loadNotificationsFromDatabase();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<AdminNotificationsCubit>().loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'إدارة الإشعارات',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<AdminNotificationsCubit>().refresh(),
          ),
        ],
      ),
      drawer: const MobileAdminDrawer(),
      body: BlocConsumer<AdminNotificationsCubit, AdminNotificationsState>(
        listener: (context, state) {
          if (state is AdminNotificationsError) {
            log('Error: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is AdminNotificationsSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'تم إرسال الإشعار بنجاح لـ ${state.recipientCount} مستخدم',
                ),
                backgroundColor: AppColors.success,
              ),
            );
            _clearForm();
            setState(() => _showCreateForm = false);
          }
        },
        builder: (context, state) {
          if (state is AdminNotificationsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (state is AdminNotificationsLoaded) {
            return SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Cards
                  _buildStatsSection(state.statistics),

                  SizedBox(height: 24.h),

                  // Create Notification Section
                  _buildCreateSection(),

                  SizedBox(height: 24.h),

                  // Notifications List
                  _buildNotificationsList(state.notifications),
                ],
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: 64.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 16.h),
                Text(
                  'مرحباً بك في إدارة الإشعارات',
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsSection(Map<String, int> statistics) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.bar_chart,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'إحصائيات سريعة',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'الإجمالي',
                  '${statistics['total'] ?? 0}',
                  Icons.notifications_outlined,
                  AppColors.primary,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildStatItem(
                  'تم الإرسال',
                  '${statistics['sent'] ?? 0}',
                  Icons.send_outlined,
                  AppColors.success,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'قيد الانتظار',
                  '${statistics['pending'] ?? 0}',
                  Icons.schedule_outlined,
                  AppColors.warning,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildStatItem(
                  'مقروءة',
                  '${statistics['read'] ?? 0}',
                  Icons.mark_email_read_outlined,
                  AppColors.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCreateSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.add_alert,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'إنشاء إشعار جديد',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed:
                    () => setState(() => _showCreateForm = !_showCreateForm),
                icon: Icon(
                  _showCreateForm
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          if (_showCreateForm) ...[SizedBox(height: 20.h), _buildCreateForm()],
        ],
      ),
    );
  }

  Widget _buildCreateForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        _buildTextField(
          controller: _titleController,
          label: 'عنوان الإشعار',
          hint: 'أدخل عنوان الإشعار',
          icon: Icons.title,
        ),

        SizedBox(height: 16.h),

        // Body
        _buildTextField(
          controller: _bodyController,
          label: 'نص الإشعار',
          hint: 'أدخل نص الإشعار',
          icon: Icons.message,
          maxLines: 3,
        ),

        SizedBox(height: 16.h),

        // Type and Target
        Row(
          children: [
            Expanded(
              child: _buildDropdown<NotificationType>(
                label: 'النوع',
                value: _selectedType,
                items:
                    NotificationType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getTypeArabicName(type)),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildDropdown<TargetType>(
                label: 'المستهدفين',
                value: _selectedTarget,
                items:
                    TargetType.values.map((target) {
                      return DropdownMenuItem(
                        value: target,
                        child: Text(_getTargetArabicName(target)),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => _selectedTarget = value!),
              ),
            ),
          ],
        ),

        SizedBox(height: 24.h),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _sendNotification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send, color: Colors.white),
                    SizedBox(width: 8.w),
                    Text(
                      'إرسال الإشعار',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12.w),
            OutlinedButton(
              onPressed: _clearForm,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'مسح',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButton<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            isExpanded: true,
            underline: const SizedBox(),
            style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsList(List<AdminNotificationEntity> notifications) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.list_alt,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'آخر الإشعارات (${notifications.length})',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          if (notifications.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(40.w),
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 48.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'لا توجد إشعارات حتى الآن',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                return _buildNotificationCard(notifications[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AdminNotificationEntity notification) {
    return GestureDetector(
      onTap: () => _showNotificationDetails(notification),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: _getTypeColor(
                      notification.notificationType,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Icon(
                    _getTypeIcon(notification.notificationType),
                    size: 16.sp,
                    color: _getTypeColor(notification.notificationType),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusBadge(notification),
              ],
            ),

            SizedBox(height: 8.h),

            Text(
              notification.body,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 12.h),

            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 4.w),
                Text(
                  _formatDateTime(notification.createdAt),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (!notification.isSent)
                  TextButton(
                    onPressed: () => _resendNotification(notification),
                    child: Text(
                      'إرسال',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AdminNotificationEntity notification) {
    Color color;
    String label;

    if (notification.isSent) {
      color = AppColors.success;
      label = 'مرسل';
    } else if (notification.sentAt != null) {
      color = AppColors.warning;
      label = 'مجدول';
    } else {
      color = AppColors.textSecondary;
      label = 'مسودة';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
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

  String _getTargetArabicName(TargetType target) {
    switch (target) {
      case TargetType.all:
        return 'جميع المستخدمين';
      case TargetType.governorate:
        return 'محافظة معينة';
      case TargetType.userType:
        return 'نوع مستخدم معين';
      case TargetType.specificUsers:
        return 'مستخدمين محددين';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  void _sendNotification() {
    if (_titleController.text.trim().isEmpty ||
        _bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى ملء جميع الحقول المطلوبة'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final notificationData = BulkNotificationData(
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      type: _selectedType,
      priority: NotificationPriority.normal,
      targetType: _selectedTarget,
      targetValue: _selectedTarget == TargetType.all ? 'all' : null,
      sendImmediately: true,
    );

    context.read<AdminNotificationsCubit>().sendBulkNotificationToAll(
      notificationData,
    );
  }

  void _resendNotification(AdminNotificationEntity notification) {
    final notificationData = BulkNotificationData(
      title: notification.title,
      body: notification.body,
      type: notification.notificationType,
      priority: notification.priority,
      targetType: TargetType.all,
      targetValue: 'all',
      sendImmediately: true,
    );

    context.read<AdminNotificationsCubit>().sendBulkNotificationToAll(
      notificationData,
    );
  }

  void _clearForm() {
    _titleController.clear();
    _bodyController.clear();
    setState(() {
      _selectedType = NotificationType.general;
      _selectedTarget = TargetType.all;
    });
  }

  void _showNotificationDetails(AdminNotificationEntity notification) {
    showDialog(
      context: context,
      builder:
          (context) =>
              SimpleNotificationDetailsDialog(notification: notification),
    );
  }
}
