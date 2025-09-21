import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../di/injection_container.dart';
import '../../features/notifications/domain/entities/fcm_token_entity.dart';
import '../../features/notifications/domain/usecases/register_fcm_token.dart';
import '../../features/auth/domain/entities/login_user_entity.dart';
import '../utils/user_data_helper.dart';
import 'logger_service.dart';

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
      _logger.logInfo('🔄 Getting FCM token...');

      final token = await getFcmToken();
      if (token != null) {
        _logger.logInfo('✅ FCM token obtained successfully');
      } else {
        _logger.logWarning('⚠️ FCM token is null');
      }
    } catch (e) {
      _logger.logError('❌ FCM token initialization failed: $e');
    }
  }

  /// Get FCM token for push notifications
  Future<String?> getFcmToken() async {
    try {
      // Get the token
      final token = await _firebaseMessaging.getToken();

      if (token != null) {
        _cachedFcmToken = token;
        _logger.logInfo('✅ FCM Token received: ${token.substring(0, 20)}...');

        // Register token with backend
        await _registerTokenWithBackend(token);
      } else {
        _logger.logWarning('⚠️ FCM Token is null');
      }

      return token;
    } catch (e) {
      _logger.logError('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Register FCM token with backend
  Future<void> _registerTokenWithBackend(String token) async {
    try {
      // Get current user
      final userHelper = UserDataHelper();
      final currentUser = userHelper.getCurrentUser();

      if (currentUser == null) {
        _logger.logWarning('⚠️ No user logged in, skipping token registration');
        return;
      }

      _logger.logInfo('🔍 Debug - Current user for FCM token:');
      _logger.logInfo('   User ID: ${currentUser.id}');
      _logger.logInfo('   User Type: ${currentUser.userType}');
      _logger.logInfo('   Identifier: ${currentUser.identifier}');

      // Check Supabase session
      await _ensureSupabaseSession(currentUser);

      // Get device info
      final deviceInfo = await _getDeviceInfo();
      final packageInfo = await PackageInfo.fromPlatform();

      // Create FCM token entity
      final fcmTokenEntity = FcmTokenEntity(
        id: '', // Will be generated by backend
        userId: currentUser.id,
        fcmToken: token,
        deviceType: _getDeviceType(),
        deviceId: deviceInfo,
        appVersion: packageInfo.version,
        isActive: true,
        lastUsed: DateTime.now(),
        createdAt: DateTime.now(),
      );

      _logger.logInfo('🔍 Attempting to register FCM token...');
      _logger.logInfo('   Token: ${token.substring(0, 20)}...');
      _logger.logInfo('   User ID: ${currentUser.id}');
      _logger.logInfo('   Device Type: ${_getDeviceType()}');

      // Register with backend
      final registerUseCase = sl<RegisterFcmTokenUseCase>();
      final result = await registerUseCase(
        RegisterFcmTokenParams(token: fcmTokenEntity),
      );

      result.fold(
        (failure) {
          _logger.logError(
            '❌ Failed to register FCM token: ${failure.message}',
          );
          _logger.logError(
            '💡 This might be a Row Level Security (RLS) policy issue',
          );
          _logger.logError(
            '💡 Check if user authentication is properly set in Supabase context',
          );
        },
        (success) {
          _logger.logInfo('✅ FCM token registered successfully');
          _logger.logInfo('   Token ID: ${success.id}');
        },
      );
    } catch (e) {
      _logger.logError('❌ Error registering FCM token: $e');
      _logger.logError(
        '💡 If this is a RLS policy error, check authentication context',
      );
    }
  }

  /// Ensure Supabase session is valid for the current user
  Future<void> _ensureSupabaseSession(LoginUserEntity currentUser) async {
    try {
      final supabaseClient = Supabase.instance.client;
      final currentSession = supabaseClient.auth.currentSession;

      _logger.logInfo('🔍 Checking Supabase session...');

      if (currentSession == null) {
        _logger.logWarning('⚠️ No Supabase session found');
        _logger.logInfo(
          '💡 Custom authentication system doesn\'t create Supabase Auth sessions',
        );
        _logger.logInfo(
          '💡 FCM token registration might fail due to RLS policies',
        );
        _logger.logInfo(
          '💡 Consider creating a service account or disabling RLS for user_fcm_tokens table',
        );
        return;
      }

      if (currentSession.user.id != currentUser.id) {
        _logger.logWarning('⚠️ Supabase session user ID mismatch');
        _logger.logWarning('   Session User ID: ${currentSession.user.id}');
        _logger.logWarning('   Current User ID: ${currentUser.id}');
        _logger.logInfo('💡 This is expected with custom authentication');
        return;
      }

      _logger.logInfo('✅ Valid Supabase session found');
      _logger.logInfo('   User ID: ${currentSession.user.id}');
      _logger.logInfo('   Session expires: ${currentSession.expiresAt}');

      // Check if session is near expiry (less than 5 minutes)
      if (currentSession.expiresAt != null) {
        final expiresAt = DateTime.fromMillisecondsSinceEpoch(
          currentSession.expiresAt! * 1000,
        );
        final timeUntilExpiry = expiresAt.difference(DateTime.now());

        if (timeUntilExpiry.inMinutes < 5) {
          _logger.logWarning(
            '⚠️ Session expires soon: ${timeUntilExpiry.inMinutes} minutes',
          );
          _logger.logInfo('🔄 Attempting to refresh session...');

          await supabaseClient.auth.refreshSession();
          _logger.logInfo('✅ Session refreshed successfully');
        }
      }
    } catch (e) {
      _logger.logError('❌ Error checking Supabase session: $e');
      _logger.logInfo('💡 If using custom authentication, consider:');
      _logger.logInfo('   1. Creating service account for FCM operations');
      _logger.logInfo('   2. Disabling RLS for user_fcm_tokens table');
      _logger.logInfo(
        '   3. Using custom RLS policies that work with your auth system',
      );
    }
  }

  /// Get device type based on platform
  DeviceType _getDeviceType() {
    if (kIsWeb) return DeviceType.web;
    if (Platform.isAndroid) return DeviceType.android;
    if (Platform.isIOS) return DeviceType.ios;
    return DeviceType.android; // Default fallback
  }

  /// Get device ID/info
  Future<String> _getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        return 'android_device_${DateTime.now().millisecondsSinceEpoch}';
      } else if (Platform.isIOS) {
        return 'ios_device_${DateTime.now().millisecondsSinceEpoch}';
      }

      return 'unknown_device_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      _logger.logError('❌ Error getting device info: $e');
      return 'unknown_device_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Setup token refresh listener
  void _setupTokenRefreshListener() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _logger.logInfo(
        '🔄 FCM Token refreshed: ${newToken.substring(0, 20)}...',
      );
      _cachedFcmToken = newToken;
      _registerTokenWithBackend(newToken);
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
