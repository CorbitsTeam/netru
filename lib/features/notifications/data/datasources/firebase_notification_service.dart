import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract class FirebaseNotificationService {
  Future<String?> getFcmToken();
  Future<bool> sendPushNotification({
    required List<String> fcmTokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  });
  Stream<RemoteMessage> get onMessageReceived;
  Stream<RemoteMessage> get onMessageOpenedApp;
  Future<void> requestPermission();
  Future<void> subscribeToTopic(String topic);
  Future<void> unsubscribeFromTopic(String topic);
}

class FirebaseNotificationServiceImpl implements FirebaseNotificationService {
  final FirebaseMessaging _firebaseMessaging;
  final Dio _dio;
  final String _serverKey;

  FirebaseNotificationServiceImpl({
    required FirebaseMessaging firebaseMessaging,
    required Dio dio,
    required String serverKey,
  }) : _firebaseMessaging = firebaseMessaging,
       _dio = dio,
       _serverKey = serverKey;

  @override
  Future<String?> getFcmToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('خطأ في الحصول على FCM Token: $e');
      return null;
    }
  }

  @override
  Future<void> requestPermission() async {
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

      debugPrint('User granted permission: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('خطأ في طلب إذن الإشعارات: $e');
    }
  }

  @override
  Stream<RemoteMessage> get onMessageReceived => FirebaseMessaging.onMessage;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  @override
  Future<bool> sendPushNotification({
    required List<String> fcmTokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      if (fcmTokens.isEmpty) {
        debugPrint('لا توجد رموز FCM للإرسال إليها');
        return false;
      }

      // Send to multiple tokens (max 1000 per request)
      final batches = _createBatches(fcmTokens, 1000);
      bool allSuccessful = true;

      for (final batch in batches) {
        final success = await _sendBatchNotification(
          fcmTokens: batch,
          title: title,
          body: body,
          data: data,
        );
        if (!success) allSuccessful = false;
      }

      return allSuccessful;
    } catch (e) {
      debugPrint('خطأ في إرسال الإشعار: $e');
      return false;
    }
  }

  Future<bool> _sendBatchNotification({
    required List<String> fcmTokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final payload = {
        'registration_ids': fcmTokens,
        'notification': {
          'title': title,
          'body': body,
          'sound': 'default',
          'badge': '1',
        },
        'data': data ?? {},
        'priority': 'high',
        'content_available': true,
      };

      final response = await _dio.post(
        'https://fcm.googleapis.com/fcm/send',
        data: jsonEncode(payload),
        options: Options(
          headers: {
            'Authorization': 'key=$_serverKey',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final result = response.data;
        debugPrint(
          'إشعار مرسل بنجاح: ${result['success']} نجح، ${result['failure']} فشل',
        );
        return result['failure'] == 0;
      } else {
        debugPrint('فشل في إرسال الإشعار: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('خطأ في إرسال الإشعار: $e');
      return false;
    }
  }

  List<List<T>> _createBatches<T>(List<T> items, int batchSize) {
    final batches = <List<T>>[];
    for (int i = 0; i < items.length; i += batchSize) {
      final end = (i + batchSize < items.length) ? i + batchSize : items.length;
      batches.add(items.sublist(i, end));
    }
    return batches;
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('تم الاشتراك في موضوع: $topic');
    } catch (e) {
      debugPrint('خطأ في الاشتراك في الموضوع: $e');
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('تم إلغاء الاشتراك من موضوع: $topic');
    } catch (e) {
      debugPrint('خطأ في إلغاء الاشتراك من الموضوع: $e');
    }
  }

  /// Send notification to a specific topic
  Future<bool> sendTopicNotification({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final payload = {
        'to': '/topics/$topic',
        'notification': {
          'title': title,
          'body': body,
          'sound': 'default',
          'badge': '1',
        },
        'data': data ?? {},
        'priority': 'high',
        'content_available': true,
      };

      final response = await _dio.post(
        'https://fcm.googleapis.com/fcm/send',
        data: jsonEncode(payload),
        options: Options(
          headers: {
            'Authorization': 'key=$_serverKey',
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('خطأ في إرسال إشعار الموضوع: $e');
      return false;
    }
  }
}

/// Handle background message when app is terminated
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('تم استقبال رسالة في الخلفية: ${message.messageId}');
  debugPrint('العنوان: ${message.notification?.title}');
  debugPrint('المحتوى: ${message.notification?.body}');
  debugPrint('البيانات: ${message.data}');
}
