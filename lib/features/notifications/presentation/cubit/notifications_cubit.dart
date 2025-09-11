import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netru_app/features/notifications/data/models/notifications_model.dart';
import 'package:netru_app/features/notifications/presentation/cubit/notifications_state.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());

  static const String _notificationsKey = 'notifications_list';
  List<NotificationModel> _notifications = [];

  // تحميل الإشعارات عند بداية التطبيق
  Future<void> loadNotifications() async {
    try {
      emit(NotificationLoading());

      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList(_notificationsKey);

      if (notificationsJson != null && notificationsJson.isNotEmpty) {
        _notifications =
            notificationsJson
                .map((json) => NotificationModel.fromJson(jsonDecode(json)))
                .toList();
      } else {
        // إنشاء إشعارات افتراضية إذا لم توجد
        _notifications = _getDefaultNotifications();
        await _saveNotifications();
      }

      final unreadCount = _notifications.where((n) => !n.isRead).length;
      emit(
        NotificationLoaded(
          notifications: _notifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(const NotificationError('فشل في تحميل الإشعارات'));
    }
  }

  // حفظ الإشعارات في التخزين المحلي
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson =
          _notifications
              .map((notification) => jsonEncode(notification.toJson()))
              .toList();
      await prefs.setStringList(_notificationsKey, notificationsJson);
    } catch (e) {
      emit(const NotificationError('فشل في حفظ الإشعارات'));
    }
  }

  // حذف إشعار
  Future<void> deleteNotification(String id) async {
    try {
      _notifications.removeWhere((notification) => notification.id == id);
      await _saveNotifications();

      final unreadCount = _notifications.where((n) => !n.isRead).length;
      emit(
        NotificationLoaded(
          notifications: _notifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(const NotificationError('فشل في حذف الإشعار'));
    }
  }

  // تمييز جميع الإشعارات كمقروءة
  Future<void> markAllAsRead() async {
    try {
      _notifications =
          _notifications
              .map((notification) => notification.copyWith(isRead: true))
              .toList();

      await _saveNotifications();

      emit(NotificationLoaded(notifications: _notifications, unreadCount: 0));
    } catch (e) {
      emit(const NotificationError('فشل في تحديث الإشعارات'));
    }
  }

  // الحصول على عدد الإشعارات غير المقروءة
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // إنشاء إشعارات افتراضية
  List<NotificationModel> _getDefaultNotifications() {
    return [
      NotificationModel(
        id: '1',
        title: 'أحذر! انت الان في منطقة خطورة عالية',
        subtitle:
            'حافظ على سلامتك وأتبع مناطق السلامة الخضراء على الخريطة الحرارية',
        type: NotificationType.danger,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      NotificationModel(
        id: '2',
        title: 'تم حل البلاغ الخاص بك!',
        subtitle:
            'بلاغك رقم #52110 بخصوص ( السرقة ) تم حله انتظر مكالمة هاتفية للمتابعة شكرا لك في جعل مجتمعنا اكثر امانا.',
        type: NotificationType.success,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        isRead: false,
      ),
      NotificationModel(
        id: '3',
        title: 'تنبيه أمني قريب منك!',
        subtitle:
            'تسجيل بلاغ بجريمة على بعد 500متر من موقعك الرجاء توخي الحذر.',
        type: NotificationType.warning,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        isRead: false,
      ),
      NotificationModel(
        id: '4',
        title: 'أحذر! أنت الآن في منطقة خطورة عالية',
        subtitle:
            'حافظ على سلامتك وأتبع مناطق السلامة الخضراء على الخريطة الحرارية',
        type: NotificationType.danger,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        isRead: true,
      ),
      NotificationModel(
        id: '5',
        title: 'تم حل البلاغ الخاص بك!',
        subtitle:
            'بلاغك رقم #52110 بخصوص ( السرقة ) تم حله انتظر مكالمة هاتفية للمتابعة شكرا لك في جعل مجتمعنا اكثر امانا.',
        type: NotificationType.success,
        createdAt: DateTime.now().subtract(const Duration(hours: 10)),
        isRead: true,
      ),
      NotificationModel(
        id: '6',
        title: 'تنبيه أمني قريب منك!',
        subtitle:
            'تسجيل بلاغ بجريمة على بعد 500متر من موقعك الرجاء توخي الحذر.',
        type: NotificationType.warning,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        isRead: true,
      ),
    ];
  }
}
