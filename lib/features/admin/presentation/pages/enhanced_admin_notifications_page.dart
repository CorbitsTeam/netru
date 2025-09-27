import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/admin_notification_entity.dart';
import '../cubit/admin_notifications_cubit.dart';
import '../widgets/mobile_admin_drawer.dart';
import '../widgets/notification_analytics_widget.dart';
import '../widgets/notification_creation_dialog.dart';
import '../widgets/notification_details_dialog.dart';
import '../widgets/notification_filters_widget.dart';

class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({super.key});

  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);

    // Load initial data
    context.read<AdminNotificationsCubit>().loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'إدارة الإشعارات',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: _showAnalytics,
            tooltip: 'الإحصائيات',
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _showCreateNotificationDialog,
            tooltip: 'إشعار جديد',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AdminNotificationsCubit>().refresh(),
            tooltip: 'تحديث',
          ),
        ],
      ),
      drawer: const MobileAdminDrawer(),
      body: BlocConsumer<AdminNotificationsCubit, AdminNotificationsState>(
        listener: (context, state) {
          if (state is AdminNotificationsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is AdminNotificationsSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${state.message} - تم الإرسال لـ ${state.recipientCount} مستخدم',
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is AdminNotificationsSending) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text(state.message),
                  ],
                ),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminNotificationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminNotificationsLoaded) {
            return Column(
              children: [
                _buildStatsCards(state.statistics),
                const SizedBox(height: 8),
                NotificationFiltersWidget(
                  filters: state.filters,
                  onFiltersChanged: (filters) {
                    context.read<AdminNotificationsCubit>().applyFilters(
                      filters,
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildBulkActionsPanel(state.selectedNotificationIds),
                Expanded(child: _buildTabSection(state)),
              ],
            );
          }

          return const Center(child: Text('مرحباً بك في إدارة الإشعارات'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateNotificationDialog,
        backgroundColor: const Color(0xFF2E7D32),
        label: const Text('إشعار جديد', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.notification_add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatsCards(Map<String, int> statistics) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'إجمالي الإشعارات',
              '${statistics['total'] ?? 0}',
              Icons.notifications_outlined,
              const Color(0xFF1976D2),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              'تم الإرسال',
              '${statistics['sent'] ?? 0}',
              Icons.send_outlined,
              const Color(0xFF388E3C),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              'مجدول',
              '${statistics['scheduled'] ?? 0}',
              Icons.schedule_outlined,
              const Color(0xFFFF9800),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              'فشل',
              '${statistics['failed'] ?? 0}',
              Icons.error_outline,
              const Color(0xFFD32F2F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28.sp),
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
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBulkActionsPanel(List<String> selectedIds) {
    if (selectedIds.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'تم تحديد ${selectedIds.length} إشعار',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _bulkSend,
                icon: const Icon(Icons.send, color: Colors.white),
                tooltip: 'إرسال المحدد',
              ),
              IconButton(
                onPressed: _bulkDelete,
                icon: const Icon(Icons.delete, color: Colors.white),
                tooltip: 'حذف المحدد',
              ),
              IconButton(
                onPressed: () {
                  context.read<AdminNotificationsCubit>().clearAllSelections();
                },
                icon: const Icon(Icons.close, color: Colors.white),
                tooltip: 'إلغاء التحديد',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection(AdminNotificationsLoaded state) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF2E7D32),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF2E7D32),
            labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: 'الكل (${state.notifications.length})'),
              Tab(text: 'مجدول (${state.scheduledNotifications.length})'),
              Tab(text: 'مسودات (${state.draftNotifications.length})'),
              Tab(text: 'الإحصائيات'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildNotificationsList(
                state.notifications,
                state.selectedNotificationIds,
              ),
              _buildNotificationsList(
                state.scheduledNotifications,
                state.selectedNotificationIds,
              ),
              _buildNotificationsList(
                state.draftNotifications,
                state.selectedNotificationIds,
              ),
              const NotificationAnalyticsWidget(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsList(
    List<AdminNotificationEntity> notifications,
    List<String> selectedIds,
  ) {
    if (notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا توجد إشعارات',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<AdminNotificationsCubit>().refresh();
      },
      child: ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.all(16.w),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          final isSelected = selectedIds.contains(notification.id);

          return _buildNotificationCard(notification, isSelected);
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    AdminNotificationEntity notification,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () => _viewNotificationDetails(notification),
      onLongPress: () {
        context.read<AdminNotificationsCubit>().toggleNotificationSelection(
          notification.id,
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E8) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border:
              isSelected
                  ? Border.all(color: const Color(0xFF2E7D32), width: 2)
                  : null,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
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
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getTypeColor(notification.notificationType),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    notification.notificationType.arabicName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                _buildStatusBadge(notification),
                if (isSelected) ...[
                  SizedBox(width: 8.w),
                  const Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
                ],
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              notification.title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              notification.body,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.access_time, size: 16.sp, color: Colors.grey[500]),
                SizedBox(width: 4.w),
                Text(
                  _formatDate(notification.createdAt),
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _showNotificationActions(notification),
                  icon: const Icon(Icons.more_vert),
                  iconSize: 20.sp,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AdminNotificationEntity notification) {
    String label;
    Color color;

    if (notification.isSent) {
      label = 'مرسل';
      color = Colors.green;
    } else if (notification.sentAt != null) {
      label = 'مجدول';
      color = Colors.orange;
    } else if (notification.fcmMessageId != null) {
      label = 'معالج';
      color = Colors.blue;
    } else {
      label = 'مسودة';
      color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

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

  void _showAnalytics() {
    context.read<AdminNotificationsCubit>().loadStatistics();
    showDialog(
      context: context,
      builder:
          (dialogContext) => BlocProvider.value(
            value: context.read<AdminNotificationsCubit>(),
            child: const Dialog(
              child: SizedBox(
                width: 500,
                height: 600,
                child: NotificationAnalyticsWidget(),
              ),
            ),
          ),
    );
  }

  void _showCreateNotificationDialog() {
    final cubit = context.read<AdminNotificationsCubit>();
    showDialog(
      context: context,
      builder:
          (dialogContext) => NotificationCreationDialog(
            onNotificationCreated: (data) {
              cubit.sendBulkNotification(data);
            },
          ),
    );
  }

  void _viewNotificationDetails(AdminNotificationEntity notification) {
    showDialog(
      context: context,
      builder:
          (context) => NotificationDetailsDialog(notification: notification),
    );
  }

  void _showNotificationActions(AdminNotificationEntity notification) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.visibility),
                  title: const Text('عرض التفاصيل'),
                  onTap: () {
                    Navigator.pop(context);
                    _viewNotificationDetails(notification);
                  },
                ),
                if (!notification.isSent) ...[
                  ListTile(
                    leading: const Icon(Icons.send),
                    title: const Text('إرسال الآن'),
                    onTap: () {
                      Navigator.pop(context);
                      _sendNotificationNow(notification);
                    },
                  ),
                ],
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('حذف', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteNotification(notification);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _sendNotificationNow(AdminNotificationEntity notification) {
    // Implementation for sending individual notification
  }

  void _deleteNotification(AdminNotificationEntity notification) {
    // Implementation for deleting notification
  }

  void _bulkSend() {
    // Implementation for bulk send
  }

  void _bulkDelete() {
    // Implementation for bulk delete
  }
}
