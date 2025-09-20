import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationPreferencesService {
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _soundEnabledKey = 'notification_sound_enabled';
  static const String _vibrationEnabledKey = 'notification_vibration_enabled';
  static const String _reportsNotificationsKey =
      'reports_notifications_enabled';
  static const String _newsNotificationsKey = 'news_notifications_enabled';
  static const String _securityNotificationsKey =
      'security_notifications_enabled';

  static final NotificationPreferencesService _instance =
      NotificationPreferencesService._internal();
  factory NotificationPreferencesService() => _instance;
  NotificationPreferencesService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // General notification settings
  Future<bool> isNotificationsEnabled() async {
    await init();
    return _prefs!.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await init();
    await _prefs!.setBool(_notificationsEnabledKey, enabled);

    // Handle system permission
    if (enabled) {
      await requestNotificationPermission();
    }
  }

  // Sound settings
  Future<bool> isSoundEnabled() async {
    await init();
    return _prefs!.getBool(_soundEnabledKey) ?? true;
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await init();
    await _prefs!.setBool(_soundEnabledKey, enabled);
  }

  // Vibration settings
  Future<bool> isVibrationEnabled() async {
    await init();
    return _prefs!.getBool(_vibrationEnabledKey) ?? true;
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    await init();
    await _prefs!.setBool(_vibrationEnabledKey, enabled);
  }

  // Category specific notifications
  Future<bool> isReportsNotificationsEnabled() async {
    await init();
    return _prefs!.getBool(_reportsNotificationsKey) ?? true;
  }

  Future<void> setReportsNotificationsEnabled(bool enabled) async {
    await init();
    await _prefs!.setBool(_reportsNotificationsKey, enabled);
  }

  Future<bool> isNewsNotificationsEnabled() async {
    await init();
    return _prefs!.getBool(_newsNotificationsKey) ?? true;
  }

  Future<void> setNewsNotificationsEnabled(bool enabled) async {
    await init();
    await _prefs!.setBool(_newsNotificationsKey, enabled);
  }

  Future<bool> isSecurityNotificationsEnabled() async {
    await init();
    return _prefs!.getBool(_securityNotificationsKey) ?? true;
  }

  Future<void> setSecurityNotificationsEnabled(bool enabled) async {
    await init();
    await _prefs!.setBool(_securityNotificationsKey, enabled);
  }

  // Permission handling
  Future<bool> requestNotificationPermission() async {
    try {
      // Request permission using permission_handler
      final status = await Permission.notification.request();

      if (status.isGranted) {
        // Also request Firebase Messaging permission on iOS
        final messaging = FirebaseMessaging.instance;
        final settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );

        return settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
      }

      return status.isGranted;
    } catch (e) {
      print('Error requesting notification permission: $e');
      return false;
    }
  }

  Future<bool> checkNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking notification permission: $e');
      return false;
    }
  }

  Future<void> openNotificationSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      print('Error opening notification settings: $e');
    }
  }
}
