// import 'dart:convert';
// import 'dart:io';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import '../../app.dart';
//
// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print("🔥 Background message: ${message.messageId}");
// }
//
// class NotificationService {
//   static final NotificationService _notificationService = NotificationService._internal();
//   factory NotificationService() => _notificationService;
//   NotificationService._internal();
//
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//   bool _isInitialized = false;
//   bool get isInitialized => _isInitialized;
//
//   Future<void> init() async {
//     try {
//       // ✅ تهيئة Local Notifications
//       const AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('@mipmap/ic_launcher');
//
//       final DarwinInitializationSettings initializationSettingsIOS =
//       DarwinInitializationSettings(
//         requestSoundPermission: true,
//         requestBadgePermission: true,
//         requestAlertPermission: true,
//       );
//
//       final InitializationSettings initializationSettings = InitializationSettings(
//         android: initializationSettingsAndroid,
//         iOS: initializationSettingsIOS,
//       );
//
//       await flutterLocalNotificationsPlugin.initialize(
//         initializationSettings,
//         onDidReceiveNotificationResponse: _onSelectNotification,
//       );
//
//       print("✅ Local notifications initialized");
//
//       // ✅ إعداد Firebase
//       await _setupFirebaseMessaging();
//
//       _isInitialized = true;
//       print("✅ NotificationService completed");
//
//     } catch (e) {
//       print("❌ NotificationService init error: $e");
//     }
//   }
//
//   Future<void> _setupFirebaseMessaging() async {
//     try {
//       if (!Platform.isIOS) return;
//
//       final messaging = FirebaseMessaging.instance;
//       print("🔧 Setting up Firebase Messaging...");
//
//       // ✅ طلب الصلاحيات أولاً
//       final settings = await messaging.requestPermission(
//         alert: true,
//         badge: true,
//         sound: true,
//         provisional: false,
//       );
//
//       print("📱 Permission: ${settings.authorizationStatus}");
//
//       if (settings.authorizationStatus != AuthorizationStatus.authorized &&
//           settings.authorizationStatus != AuthorizationStatus.provisional) {
//         print("❌ Push notifications not authorized");
//         return;
//       }
//
//       print("✅ Push notifications authorized!");
//
//       // ✅ إعداد Handlers
//       FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
//       FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);
//       FirebaseMessaging.onMessageOpenedApp.listen(_firebaseMessagingOpenedHandler);
//
//       // ✅ معالجة initial message
//       final initialMessage = await messaging.getInitialMessage();
//       if (initialMessage != null) {
//         _firebaseMessagingOpenedHandler(initialMessage);
//       }
//
//       // ✅ محاولة الحصول على Token بطريقة محسنة
//       await _getTokensWithProperSetup(messaging);
//
//       print("✅ Firebase Messaging setup completed");
//
//     } catch (e) {
//       print("❌ Firebase setup error: $e");
//     }
//   }
//
//   Future<void> _getTokensWithProperSetup(FirebaseMessaging messaging) async {
//     try {
//       print("🔄 Starting token acquisition...");
//
//       // ✅ انتظار قصير للتهيئة
//       await Future.delayed(Duration(seconds: 1));
//
//       // ✅ محاولة الحصول على APNs Token أولاً
//       String? apnsToken;
//       for (int i = 0; i < 10; i++) {
//         try {
//           apnsToken = await messaging.getAPNSToken().timeout(Duration(seconds: 2));
//           if (apnsToken != null) {
//             print("✅ APNs Token: ${apnsToken.substring(0, 30)}...");
//             break;
//           }
//         } catch (e) {
//           if (i == 9) {
//             print("⚠️ APNs token not available after 10 attempts");
//             print("🔧 This might be due to:");
//             print("   - APNs Certificate expired in Firebase");
//             print("   - Missing push notification entitlements");
//             print("   - Network connectivity issues");
//           }
//         }
//
//         await Future.delayed(Duration(seconds: 1));
//         print("⏳ APNs attempt ${i + 1}/10...");
//       }
//
//       // ✅ محاولة الحصول على FCM Token
//       if (apnsToken != null) {
//         // انتظار إضافي بعد الحصول على APNs token
//         await Future.delayed(Duration(seconds: 2));
//
//         for (int i = 0; i < 5; i++) {
//           try {
//             final fcmToken = await messaging.getToken().timeout(Duration(seconds: 10));
//             if (fcmToken != null && fcmToken.isNotEmpty) {
//               print("");
//               print("🎉🎉🎉 SUCCESS! FCM TOKEN RECEIVED! 🎉🎉🎉");
//               print("📱 Your iPhone is ready for push notifications!");
//               print("");
//               print("🔔 FCM Token:");
//               print("=" * 80);
//               print(fcmToken);
//               print("=" * 80);
//               print("");
//               print("🧪 TEST STEPS:");
//               print("1. Copy the token above");
//               print("2. Go to: https://console.firebase.google.com/");
//               print("3. Select your project: quickwash-a4b06");
//               print("4. Go to Cloud Messaging → Send your first message");
//               print("5. Choose 'Send test message'");
//               print("6. Paste the FCM token");
//               print("7. Add title and body");
//               print("8. Click 'Test' button");
//               print("9. Check your iPhone for the notification! 📱");
//               print("");
//
//               // ✅ Token refresh listener
//               FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
//                 print("🔄 FCM Token refreshed: ${newToken.substring(0, 30)}...");
//               });
//
//               return;
//             }
//           } catch (e) {
//             print("⚠️ FCM attempt ${i + 1}/5 failed: $e");
//           }
//
//           if (i < 4) {
//             await Future.delayed(Duration(seconds: 3));
//           }
//         }
//       } else {
//         print("❌ Cannot get FCM token without APNs token");
//         print("");
//         print("🔧 TROUBLESHOOTING STEPS:");
//         print("1. Check Firebase Console → Project Settings → Cloud Messaging");
//         print("2. Verify APNs Authentication Key or Certificate is valid");
//         print("3. Ensure Bundle ID matches: sa.quickwash.app");
//         print("4. Check if APNs certificate expired (your cert expires Aug 23, 2026)");
//         print("5. Try uploading a new APNs Authentication Key (.p8 file)");
//         print("");
//         print("📋 Firebase Project Details:");
//         print("   Project ID: quickwash-a4b06");
//         print("   Bundle ID: sa.quickwash.app");
//         print("   App ID: 1:683030921634:ios:d378888c892ab058b072fb");
//         print("");
//       }
//
//       print("❌ Failed to get FCM token");
//
//     } catch (e) {
//       print("❌ Token acquisition error: $e");
//     }
//   }
//
//   void _firebaseMessagingForegroundHandler(RemoteMessage message) async {
//     print("");
//     print("🎉🎉 PUSH NOTIFICATION RECEIVED! 🎉🎉");
//     print("📱 Title: ${message.notification?.title}");
//     print("📱 Body: ${message.notification?.body}");
//     print("📱 Data: ${message.data}");
//     print("");
//
//     final notification = message.notification;
//     if (notification != null) {
//       await _showNotification(
//         message.hashCode,
//         notification.title ?? 'إشعار',
//         notification.body ?? '',
//         null,
//         jsonEncode(message.data),
//       );
//     }
//   }
//
//   void _firebaseMessagingOpenedHandler(RemoteMessage message) {
//     print("📲 Notification tapped: ${message.data}");
//     _handlePayloadNavigation(message.data);
//   }
//
//   Future<void> _showNotification(int id, String title, String body, String? imagePath, String? payload) async {
//     try {
//       final androidDetails = AndroidNotificationDetails(
//         'high_importance_channel',
//         'High Importance Notifications',
//         importance: Importance.max,
//         priority: Priority.high,
//       );
//
//       final iOSDetails = DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       );
//
//       await flutterLocalNotificationsPlugin.show(
//         id, title, body,
//         NotificationDetails(android: androidDetails, iOS: iOSDetails),
//         payload: payload,
//       );
//     } catch (e) {
//       print("❌ Show notification error: $e");
//     }
//   }
//
//   void _onSelectNotification(NotificationResponse response) {
//     if (response.payload != null) {
//       try {
//         final data = jsonDecode(response.payload!);
//         _handlePayloadNavigation(data);
//       } catch (e) {
//         print("❌ Payload parse error: $e");
//       }
//     }
//   }
//
//   void _handlePayloadNavigation(Map<String, dynamic> data) {
//     final screen = data['screen'];
//     final id = data['id'];
//
//     switch (screen) {
//       case 'order':
//         navigatorKey.currentState?.pushNamed('/orderDetails', arguments: id);
//         break;
//       case 'chat':
//         navigatorKey.currentState?.pushNamed('/chat', arguments: data);
//         break;
//     }
//   }
//
//
// }
