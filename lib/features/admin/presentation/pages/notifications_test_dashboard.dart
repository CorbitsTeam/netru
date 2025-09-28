import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/admin_notification_entity.dart';
import '../cubit/admin_notifications_cubit.dart';
import '../../../../core/services/simple_notification_service.dart';
import '../../../../core/di/injection_container.dart' as di;

/// صفحة اختبار شاملة لنظام الإشعارات المحسن
class NotificationsTestDashboard extends StatefulWidget {
  const NotificationsTestDashboard({super.key});

  @override
  State<NotificationsTestDashboard> createState() =>
      _NotificationsTestDashboardState();
}

class _NotificationsTestDashboardState extends State<NotificationsTestDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final SimpleNotificationService _notificationService =
      di.sl<SimpleNotificationService>();

  String _status = 'جاهز للاختبار';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load notifications on start
    context.read<AdminNotificationsCubit>().loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('مركز اختبار الإشعارات'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'إنشاء إشعارات', icon: Icon(Icons.add_alert)),
            Tab(text: 'قائمة الإشعارات', icon: Icon(Icons.list)),
            Tab(text: 'الإحصائيات', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCreateNotificationsTab(),
          _buildNotificationsListTab(),
          _buildStatisticsTab(),
        ],
      ),
    );
  }

  Widget _buildCreateNotificationsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status card
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 32.sp,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(height: 8.h),
                Text(
                  'حالة النظام',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _status,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Test buttons grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 1.2,
            children: [
              _buildTestButton(
                'إشعار نجح البلاغ',
                Icons.check_circle,
                Colors.green,
                () => _testReportSuccessNotification(),
              ),
              _buildTestButton(
                'تحديث حالة البلاغ',
                Icons.update,
                Colors.orange,
                () => _testReportUpdateNotification(),
              ),
              _buildTestButton(
                'إشعار نظام عام',
                Icons.settings,
                Colors.blue,
                () => _testSystemNotification(),
              ),
              _buildTestButton(
                'إشعار عاجل',
                Icons.priority_high,
                Colors.red,
                () => _testUrgentNotification(),
              ),
              _buildTestButton(
                'إشعار خبر جديد',
                Icons.article,
                Colors.purple,
                () => _testNewsNotification(),
              ),
              _buildTestButton(
                'إشعار محلي',
                Icons.phone_android,
                Colors.teal,
                () => _testLocalNotification(),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          if (_isLoading) const LinearProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildNotificationsListTab() {
    return BlocBuilder<AdminNotificationsCubit, AdminNotificationsState>(
      builder: (context, state) {
        if (state is AdminNotificationsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminNotificationsLoaded) {
          final notifications = state.notifications;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AdminNotificationsCubit>().refresh();
            },
            child:
                notifications.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text('لا توجد إشعارات حتى الآن'),
                        ],
                      ),
                    )
                    : ListView.separated(
                      padding: EdgeInsets.all(16.w),
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return _buildNotificationTestCard(notification);
                      },
                    ),
          );
        }

        if (state is AdminNotificationsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('خطأ: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<AdminNotificationsCubit>().loadNotifications();
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildStatisticsTab() {
    return BlocBuilder<AdminNotificationsCubit, AdminNotificationsState>(
      builder: (context, state) {
        if (state is AdminNotificationsLoaded) {
          final stats = state.statistics;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Statistics cards
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                      'إجمالي الإشعارات',
                      '${stats['total'] ?? 0}',
                      Icons.notifications,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'المرسلة',
                      '${stats['sent'] ?? 0}',
                      Icons.send,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'قيد الانتظار',
                      '${stats['pending'] ?? 0}',
                      Icons.schedule,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'الفاشلة',
                      '${stats['failed'] ?? 0}',
                      Icons.error,
                      Colors.red,
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // Refresh button
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<AdminNotificationsCubit>().loadStatistics();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('تحديث الإحصائيات'),
                ),
              ],
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildTestButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.all(16.w),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32.sp),
          SizedBox(height: 8.h),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
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
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32.sp, color: color),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTestCard(AdminNotificationEntity notification) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
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
              Icon(
                _getNotificationIcon(notification.notificationType),
                color: _getNotificationColor(notification.notificationType),
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _getNotificationColor(
                    notification.notificationType,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  notification.notificationType.arabicName,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: _getNotificationColor(notification.notificationType),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (notification.isSent)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'مُرسل',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'قيد الانتظار',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            notification.title,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            notification.body,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.access_time, size: 14.sp, color: Colors.grey[500]),
              SizedBox(width: 4.w),
              Text(
                _formatDateTime(notification.createdAt),
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
              ),
              if (notification.userName != null) ...[
                SizedBox(width: 16.w),
                Icon(Icons.person, size: 14.sp, color: Colors.grey[500]),
                SizedBox(width: 4.w),
                Text(
                  notification.userName!,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Test notification methods
  Future<void> _testReportSuccessNotification() async {
    await _runTest('إشعار نجاح البلاغ', () async {
      await _notificationService.sendSuccessNotification(
        message: 'تم استلام بلاغكم بنجاح وسيتم المراجعة قريباً ✅',
      );
    });
  }

  Future<void> _testReportUpdateNotification() async {
    await _runTest('تحديث حالة البلاغ', () async {
      await _notificationService.sendReportStatusNotification(
        reportId: 'test-${DateTime.now().millisecondsSinceEpoch}',
        reportStatus: 'under_investigation',
        reportOwnerName: 'أحمد محمد (اختبار)',
        caseNumber: 'TEST-${DateTime.now().millisecondsSinceEpoch}',
        investigatorName: 'المحقق سالم العلي',
      );
    });
  }

  Future<void> _testSystemNotification() async {
    await _runTest('إشعار النظام', () async {
      // Create a system notification using the cubit
      await context.read<AdminNotificationsCubit>().createNotification(
        userId: 'system-user',
        title: '🔧 إشعار نظام اختبار',
        body: 'هذا إشعار نظام تجريبي للتأكد من عمل النظام بشكل صحيح',
        type: NotificationType.system,
        priority: NotificationPriority.high,
      );
    });
  }

  Future<void> _testUrgentNotification() async {
    await _runTest('إشعار عاجل', () async {
      await context.read<AdminNotificationsCubit>().createNotification(
        userId: 'urgent-user',
        title: '🚨 إشعار عاجل - اختبار',
        body: 'هذا إشعار عاجل لاختبار الأولوية العالية في النظام',
        type: NotificationType.general,
        priority: NotificationPriority.urgent,
      );
    });
  }

  Future<void> _testNewsNotification() async {
    await _runTest('إشعار خبر جديد', () async {
      await context.read<AdminNotificationsCubit>().createNotification(
        userId: 'news-user',
        title: '📰 خبر جديد - اختبار',
        body: 'تم نشر خبر جديد في منصة نترو. اطلع على آخر الأخبار والتحديثات',
        type: NotificationType.news,
        priority: NotificationPriority.normal,
      );
    });
  }

  Future<void> _testLocalNotification() async {
    await _runTest('إشعار محلي', () async {
      await _notificationService.showLocalNotification(
        title: '📱 إشعار محلي - اختبار',
        body: 'هذا إشعار محلي يظهر مباشرة على الجهاز بدون خادم',
      );
    });
  }

  Future<void> _runTest(
    String testName,
    Future<void> Function() testFunction,
  ) async {
    setState(() {
      _isLoading = true;
      _status = 'جاري تشغيل: $testName...';
    });

    try {
      await testFunction();
      setState(() {
        _status = '✅ نجح: $testName';
      });

      // Refresh notifications list
      if (mounted) {
        context.read<AdminNotificationsCubit>().refresh();
      }

      _showSuccessMessage('تم إرسال $testName بنجاح');
    } catch (e) {
      setState(() {
        _status = '❌ فشل: $testName - $e';
      });
      _showErrorMessage('فشل في إرسال $testName: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
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

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.news:
        return Colors.blue;
      case NotificationType.reportUpdate:
        return Colors.orange;
      case NotificationType.reportComment:
        return Colors.purple;
      case NotificationType.system:
        return Colors.red;
      case NotificationType.general:
        return Colors.green;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
