import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'logger_service.dart';
import 'simple_fcm_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final logger = LoggerService();
  logger.logInfo("🔥 Background message received: ${message.messageId}");
  logger.logInfo("📱 Title: ${message.notification?.title}");
  logger.logInfo("📱 Body: ${message.notification?.body}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final LoggerService _logger = LoggerService();

  bool _isInitialized = false;
  String? _cachedFcmToken;

  bool get isInitialized => _isInitialized;
  String? get cachedFcmToken => _cachedFcmToken;

  /// Initialize the notification service
  Future<void> init() async {
    if (_isInitialized) {
      _logger.logInfo('📱 NotificationService already initialized');
      return;
    }

    try {
      _logger.logInfo('🚀 Initializing NotificationService...');

      // Initialize Local Notifications
      await _initializeLocalNotifications();

      // Setup Firebase Messaging
      await _setupFirebaseMessaging();

      // Get initial FCM token
      await _initializeFcmToken();

      _isInitialized = true;
      _logger.logInfo('✅ NotificationService initialization completed');
    } catch (e) {
      _logger.logError('❌ NotificationService initialization failed: $e');
      rethrow;
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      const iosSettings = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onSelectNotification,
      );

      _logger.logInfo('✅ Local notifications initialized');
    } catch (e) {
      _logger.logError('❌ Local notifications initialization failed: $e');
      rethrow;
    }
  }

  /// Setup Firebase Messaging with cross-platform support
  Future<void> _setupFirebaseMessaging() async {
    try {
      _logger.logInfo('🔧 Setting up Firebase Messaging...');

      // Request permissions
      final isAuthorized = await _requestNotificationPermissions();
      if (!isAuthorized) {
        _logger.logWarning('❌ Push notifications not authorized');
        return;
      }

      // Setup message handlers
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Handle initial message (app opened from terminated state)
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _logger.logInfo('📲 App opened from notification');
        _handleMessageOpenedApp(initialMessage);
      }

      // Setup token refresh listener
      _setupTokenRefreshListener();

      _logger.logInfo('✅ Firebase Messaging setup completed');
    } catch (e) {
      _logger.logError('❌ Firebase Messaging setup failed: $e');
      rethrow;
    }
  }

  /// Request notification permissions
  Future<bool> _requestNotificationPermissions() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final isAuthorized =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      _logger.logInfo(
        '📱 Notification permission: ${settings.authorizationStatus}',
      );
      return isAuthorized;
    } catch (e) {
      _logger.logError('❌ Permission request failed: $e');
      return false;
    }
  }

  /// Initialize and get FCM token
  Future<void> _initializeFcmToken() async {
    try {
      _logger.logInfo('🔄 Initializing FCM token with SimpleFcmService...');

      // Initialize SimpleFcmService
      final simpleFcmService = SimpleFcmService();
      await simpleFcmService.init();

      // Get cached token
      final token = simpleFcmService.getCachedToken();
      if (token != null) {
        _cachedFcmToken = token;
        _logger.logInfo('✅ FCM token initialized successfully');
      } else {
        _logger.logWarning('⚠️ FCM token is null after initialization');
      }
    } catch (e) {
      _logger.logError('❌ FCM token initialization failed: $e');
    }
  }

  /// Get FCM token for push notifications
  Future<String?> getFcmToken() async {
    try {
      // Use SimpleFcmService instead
      final simpleFcmService = SimpleFcmService();
      final token = await simpleFcmService.getFcmTokenAndRegister();

      if (token != null) {
        _cachedFcmToken = token;
        _logger.logInfo('✅ FCM Token received: ${token.substring(0, 20)}...');
      } else {
        _logger.logWarning('⚠️ FCM Token is null');
      }

      return token;
    } catch (e) {
      _logger.logError('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Setup token refresh listener
  void _setupTokenRefreshListener() {
    // SimpleFcmService already handles token refresh
    // Just update our cached token when it changes
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _logger.logInfo(
        '🔄 FCM Token refreshed: ${newToken.substring(0, 20)}...',
      );
      _cachedFcmToken = newToken;
      // SimpleFcmService will handle the registration automatically
    });
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) async {
    _logger.logInfo('');
    _logger.logInfo('🎉🎉 PUSH NOTIFICATION RECEIVED! 🎉🎉');
    _logger.logInfo('📱 Title: ${message.notification?.title}');
    _logger.logInfo('� Body: ${message.notification?.body}');
    _logger.logInfo('📱 Data: ${message.data}');
    _logger.logInfo('');

    final notification = message.notification;
    if (notification != null) {
      await _showLocalNotification(
        message.hashCode,
        notification.title ?? 'إشعار',
        notification.body ?? '',
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Handle messages when app is opened from notification
  void _handleMessageOpenedApp(RemoteMessage message) {
    _logger.logInfo('� Notification tapped: ${message.data}');
    _handleNotificationNavigation(message.data);
  }

  /// Show local notification
  Future<void> _showLocalNotification(
    int id,
    String title,
    String body, {
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      _logger.logInfo('✅ Local notification shown: $title');
    } catch (e) {
      _logger.logError('❌ Show notification error: $e');
    }
  }

  /// Handle notification tap
  void _onSelectNotification(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _handleNotificationNavigation(data);
      } catch (e) {
        _logger.logError('❌ Payload parse error: $e');
      }
    }
  }

  /// Handle navigation when notification is tapped
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    try {
      final screen = data['screen'] as String?;
      final id = data['id'];

      _logger.logInfo('🧭 Navigating to: $screen with id: $id');

      // You can implement your own navigation logic here
      // For example, using a navigator key from your app:
      switch (screen) {
        case 'order':
          // Navigate to order details
          // AppNavigator.pushNamed('/orderDetails', arguments: id);
          _logger.logInfo('📲 Navigate to order: $id');
          break;
        case 'chat':
          // Navigate to chat
          // AppNavigator.pushNamed('/chat', arguments: data);
          _logger.logInfo('💬 Navigate to chat with data: $data');
          break;
        default:
          _logger.logInfo('🏠 Navigate to home or default screen');
      }
    } catch (e) {
      _logger.logError('❌ Navigation error: $e');
    }
  }
}
