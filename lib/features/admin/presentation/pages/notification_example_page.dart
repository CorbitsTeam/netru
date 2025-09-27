import 'package:flutter/material.dart';
import '../../../../core/services/simple_notification_service.dart';
import '../../../../core/di/injection_container.dart' as di;

/// مثال على استخدام نظام الإشعارات الجديد
class NotificationExamplePage extends StatefulWidget {
  const NotificationExamplePage({super.key});

  @override
  State<NotificationExamplePage> createState() =>
      _NotificationExamplePageState();
}

class _NotificationExamplePageState extends State<NotificationExamplePage> {
  final SimpleNotificationService _notificationService =
      di.sl<SimpleNotificationService>();
  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _loadUnreadCount();
  }

  Future<void> _loadNotifications() async {
    final notifications = await _notificationService.getUserNotifications();
    setState(() {
      _notifications = notifications;
    });
  }

  Future<void> _loadUnreadCount() async {
    final count = await _notificationService.getUnreadNotificationsCount();
    setState(() {
      _unreadCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الإشعارات ($_unreadCount غير مقروء)'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // أزرار الاختبار
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _sendTestNotification,
                  child: const Text('إرسال إشعار تجريبي'),
                ),
                ElevatedButton(
                  onPressed: _sendSuccessNotification,
                  child: const Text('إشعار نجاح'),
                ),
                ElevatedButton(
                  onPressed: _sendErrorNotification,
                  child: const Text('إشعار خطأ'),
                ),
                ElevatedButton(
                  onPressed: _sendReportUpdateNotification,
                  child: const Text('تحديث بلاغ'),
                ),
              ],
            ),
          ),

          const Divider(),

          // قائمة الإشعارات
          Expanded(
            child:
                _notifications.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'لا توجد إشعارات',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        return _buildNotificationItem(notification);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final isRead = notification['is_read'] as bool? ?? false;
    final title = notification['title'] as String? ?? 'بدون عنوان';
    final body = notification['body'] as String? ?? 'بدون محتوى';
    final createdAt = DateTime.tryParse(
      notification['created_at'] as String? ?? '',
    );
    final type = notification['type'] as String? ?? 'general';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isRead ? Colors.white : Colors.blue.shade50,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isRead ? Colors.grey : Colors.blue,
          child: Icon(_getNotificationIcon(type), color: Colors.white),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(body),
            if (createdAt != null)
              Text(
                _formatDateTime(createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        trailing:
            !isRead
                ? Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                )
                : null,
        onTap: () => _markAsRead(notification['id'] as String),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'report_update':
        return Icons.update;
      case 'success':
        return Icons.check_circle;
      case 'error':
        return Icons.error;
      case 'general':
      default:
        return Icons.notifications;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _markAsRead(String notificationId) async {
    await _notificationService.markNotificationAsRead(notificationId);
    _loadNotifications();
    _loadUnreadCount();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم تمييز الإشعار كمقروء')));
  }

  Future<void> _sendTestNotification() async {
    await _notificationService.showLocalNotification(
      title: '🔔 إشعار تجريبي',
      body: 'هذا إشعار تجريبي لاختبار النظام الجديد',
      data: {'type': 'test', 'timestamp': DateTime.now().toString()},
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم إرسال إشعار تجريبي')));
  }

  Future<void> _sendSuccessNotification() async {
    await _notificationService.sendSuccessNotification(
      message: 'تمت العملية بنجاح! ✅',
    );
  }

  Future<void> _sendErrorNotification() async {
    await _notificationService.sendErrorNotification(
      message: 'حدث خطأ أثناء العملية ❌',
    );
  }

  Future<void> _sendReportUpdateNotification() async {
    await _notificationService.sendReportStatusNotification(
      reportId: 'test-report-123',
      reportStatus: 'under_investigation',
      reportOwnerName: 'أحمد محمد',
      caseNumber: '2025001',
      investigatorName: 'المحقق سالم',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرسال إشعار تحديث البلاغ')),
    );
  }
}
