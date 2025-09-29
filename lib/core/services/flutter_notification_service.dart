import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'logger_service.dart';

/// Enhanced Flutter FCM Service using Firebase v1 API
/// خدمة الإشعارات المحسّنة باستخدام Firebase v1 API
class FlutterNotificationService {
  static final FlutterNotificationService _instance =
      FlutterNotificationService._internal();
  factory FlutterNotificationService() => _instance;
  FlutterNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final LoggerService _logger = LoggerService();
  String? _deviceToken;

  /// Initialize notifications for this app or device
  /// تهيئة الإشعارات للتطبيق أو الجهاز
  Future<void> initNotifications() async {
    try {
      // Request permission
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Get device token
      String? deviceToken = await _firebaseMessaging.getToken();
      _deviceToken = deviceToken;

      _logger.logInfo("📱 Firebase Messaging Device Token: $deviceToken");

      // Handle background notifications
      handleBackgroundNotifications();

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((token) {
        _deviceToken = token;
        _logger.logInfo("🔄 FCM Token refreshed: $token");
        // TODO: Update token in database
      });
    } catch (e) {
      _logger.logError("❌ Failed to initialize notifications: $e");
    }
  }

  /// Get current device token
  /// الحصول على رمز الجهاز الحالي
  String? get deviceToken => _deviceToken;

  /// Handle notifications when received
  /// التعامل مع الإشعارات عند استلامها
  void handleMessages(RemoteMessage? message) {
    if (message != null) {
      _logger.logInfo(
        "📱 Received notification: ${message.notification?.title}",
      );

      // Handle notification data
      if (message.data.isNotEmpty) {
        _logger.logInfo("📋 Notification data: ${message.data}");

        // Navigate based on notification type
        _handleNotificationNavigation(message.data);
      }
    }
  }

  /// Handle notifications in case app is terminated
  /// التعامل مع الإشعارات عند إغلاق التطبيق
  void handleBackgroundNotifications() async {
    // Handle notification when app is terminated
    FirebaseMessaging.instance.getInitialMessage().then(handleMessages);

    // Handle notification when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessages);

    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.logInfo(
        "📱 Foreground notification: ${message.notification?.title}",
      );
      // Show local notification or handle as needed
    });
  }

  /// Handle notification navigation based on type
  /// التعامل مع التنقل بناءً على نوع الإشعار
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final String? type = data['type'];
    final String? reportId = data['report_id'];

    switch (type) {
      case 'report_status_update':
        // Navigate to report details
        _logger.logInfo("🔄 Navigating to report: $reportId");
        break;
      case 'new_report':
        // Navigate to reports list
        _logger.logInfo("📋 Navigating to reports list");
        break;
      default:
        _logger.logInfo("📱 Unknown notification type: $type");
    }
  }

  /// Get Firebase access token using service account
  /// الحصول على رمز الوصول لـ Firebase باستخدام حساب الخدمة
  Future<String?> getAccessToken() async {
    // Service account configuration
    // يجب الحصول على هذه البيانات من Firebase Console
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "your_project_id_here", // ضع معرف مشروعك هنا
      "private_key_id": "your_private_key_id_here",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nyour_private_key_here\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-xxxxx@your_project_id.iam.gserviceaccount.com",
      "client_id": "your_client_id_here",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xxxxx%40your_project_id.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com",
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/firebase.messaging",
    ];

    try {
      http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
      );

      auth.AccessCredentials credentials = await auth
          .obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client,
          );

      client.close();

      final accessToken = credentials.accessToken.data;
      _logger.logInfo(
        "🔑 Access Token obtained: ${accessToken.substring(0, 20)}...",
      );
      return accessToken;
    } catch (e) {
      _logger.logError("❌ Error getting access token: $e");
      return null;
    }
  }

  /// Create FCM v1 message body
  /// إنشاء محتوى رسالة FCM v1
  Map<String, dynamic> getMessageBody({
    required String fcmToken,
    required String title,
    required String body,
    required String userId,
    String? type,
    String? reportId,
    String? caseNumber,
  }) {
    return {
      "message": {
        "token": fcmToken,
        "notification": {"title": title, "body": body},
        "android": {
          "ttl": "3600s",
          "priority": "HIGH",
          "notification": {
            "title": title,
            "body": body,
            "sound": "default",
            "channel_id": "default",
            "notification_priority": "PRIORITY_MAX",
          },
        },
        "apns": {
          "headers": {
            "apns-expiration":
                "${DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000}",
          },
          "payload": {
            "aps": {
              "alert": {"title": title, "body": body},
              "sound": "default",
              "badge": 1,
              "content-available": 1,
            },
          },
        },
        "data": {
          "type": type ?? "general",
          "user_id": userId,
          "report_id": reportId ?? "",
          "case_number": caseNumber ?? "",
          "timestamp": DateTime.now().toIso8601String(),
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
        },
      },
    };
  }

  /// Send notification using Firebase v1 API
  /// إرسال إشعار باستخدام Firebase v1 API
  Future<bool> sendNotification({
    required String fcmToken,
    required String title,
    required String body,
    required String userId,
    String? type,
    String? reportId,
    String? caseNumber,
  }) async {
    try {
      // Get access token
      final accessToken = await getAccessToken();
      if (accessToken == null) {
        _logger.logError("❌ Failed to get access token");
        return false;
      }

      // Firebase project ID - يجب تحديثه بمعرف مشروعك
      const String projectId = "your_project_id_here"; // ضع معرف مشروعك هنا
      const String fcmV1Url =
          "https://fcm.googleapis.com/v1/projects/$projectId/messages:send";

      // Create message body
      final messageBody = getMessageBody(
        fcmToken: fcmToken,
        title: title,
        body: body,
        userId: userId,
        type: type,
        reportId: reportId,
        caseNumber: caseNumber,
      );

      // Send notification
      Dio dio = Dio();
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Authorization'] = 'Bearer $accessToken';

      _logger.logInfo(
        "🚀 Sending notification to: ${fcmToken.substring(0, 20)}...",
      );

      final response = await dio.post(fcmV1Url, data: messageBody);

      _logger.logInfo('📊 Response Status: ${response.statusCode}');
      _logger.logInfo('📄 Response Data: ${response.data}');

      if (response.statusCode == 200) {
        _logger.logInfo("✅ Notification sent successfully");
        return true;
      } else {
        _logger.logError(
          "❌ Failed to send notification: ${response.statusCode}",
        );
        return false;
      }
    } catch (e) {
      _logger.logError("❌ Error sending notification: $e");
      return false;
    }
  }

  /// Send notification to multiple tokens
  /// إرسال إشعار لعدة أجهزة
  Future<List<bool>> sendNotificationToMultipleTokens({
    required List<String> fcmTokens,
    required String title,
    required String body,
    required String userId,
    String? type,
    String? reportId,
    String? caseNumber,
  }) async {
    List<bool> results = [];

    for (String token in fcmTokens) {
      final result = await sendNotification(
        fcmToken: token,
        title: title,
        body: body,
        userId: userId,
        type: type,
        reportId: reportId,
        caseNumber: caseNumber,
      );
      results.add(result);
    }

    final successCount = results.where((r) => r).length;
    _logger.logInfo("📊 Notifications sent: $successCount/${fcmTokens.length}");

    return results;
  }
}
