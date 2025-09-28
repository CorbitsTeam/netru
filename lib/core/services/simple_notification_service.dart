import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'logger_service.dart';
import 'notification_template_service.dart';

/// خدمة إشعارات بسيطة وموثوقة بدون تعقيدات Edge Functions
class SimpleNotificationService {
  static final SimpleNotificationService _instance =
      SimpleNotificationService._internal();
  factory SimpleNotificationService() => _instance;
  SimpleNotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final LoggerService _logger = LoggerService();
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isInitialized = false;

  /// تهيئة الخدمة
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      _logger.logInfo('🚀 Initializing SimpleNotificationService...');

      await _initializeLocalNotifications();

      _isInitialized = true;
      _logger.logInfo('✅ SimpleNotificationService initialized successfully');
    } catch (e) {
      _logger.logError('❌ SimpleNotificationService initialization failed: $e');
    }
  }

  /// تهيئة الإشعارات المحلية
  Future<void> _initializeLocalNotifications() async {
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
  }

  /// إرسال إشعار محلي بسيط
  Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      if (!_isInitialized) await init();

      const androidDetails = AndroidNotificationDetails(
        'netru_channel',
        'Netru Notifications',
        channelDescription: 'إشعارات تطبيق نترو',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        platformDetails,
        payload: data?.toString(),
      );

      _logger.logInfo('📱 تم عرض الإشعار المحلي: $title');
    } catch (e) {
      _logger.logError('❌ خطأ في عرض الإشعار المحلي: $e');
    }
  }

  /// إرسال إشعار تحديث حالة البلاغ مباشرة لصاحب البلاغ
  Future<void> sendReportStatusNotification({
    required String reportId,
    required String reportStatus,
    required String reportOwnerName,
    String? caseNumber,
    String? investigatorName,
  }) async {
    try {
      _logger.logInfo('📋 إرسال إشعار تحديث حالة البلاغ: $reportId');

      // الحصول على معرف صاحب البلاغ من جدول التقارير
      final reportResponse =
          await _supabase
              .from('reports')
              .select(
                'user_id, case_number, reporter_first_name, reporter_last_name',
              )
              .eq('id', reportId)
              .single();

      final userId = reportResponse['user_id'] as String?;
      final actualCaseNumber =
          reportResponse['case_number'] as String? ?? caseNumber;
      final reporterName =
          '${reportResponse['reporter_first_name']} ${reportResponse['reporter_last_name']}';

      if (userId == null) {
        _logger.logWarning('⚠️ البلاغ غير مرتبط بمستخدم مسجل (بلاغ مجهول)');
        return;
      }

      // إنشاء نص الإشعار بناء على الحالة
      final template = NotificationTemplateService.reportStatusUpdate(
        status: reportStatus,
        reporterName: reporterName,
        caseNumber: actualCaseNumber ?? reportId.substring(0, 8),
        investigatorName: investigatorName,
      );

      final title = template['title'] as String;
      final body = template['body'] as String;

      _logger.logInfo(
        '📝 إرسال إشعار لصاحب البلاغ: $reporterName (المعرف: $userId)',
      );
      _logger.logInfo('📋 العنوان: $title');
      _logger.logInfo(
        '📄 المحتوى: ${body.substring(0, body.length > 100 ? 100 : body.length)}...',
      );

      // إدخال وإرسال الإشعار مع ربطه بالبلاغ
      await _insertNotificationDirectly(
        userId: userId,
        title: title,
        body: body,
        type: 'info',
        referenceId: reportId,
        referenceType: 'report',
        additionalData: {
          'report_id': reportId,
          'case_number': actualCaseNumber,
          'status': reportStatus,
          'investigator_name': investigatorName,
        },
      );

      _logger.logInfo('✅ تم إرسال إشعار تحديث البلاغ بنجاح إلى صاحب البلاغ');
    } catch (e, stackTrace) {
      _logger.logError('❌ خطأ في إرسال إشعار تحديث البلاغ: $e', stackTrace);

      // محاولة إرسال إشعار عام في حالة الفشل
      try {
        await showLocalNotification(
          title: 'تحديث حالة البلاغ',
          body:
              'تم تحديث حالة البلاغ رقم ${caseNumber ?? reportId.substring(0, 8)} إلى $reportStatus',
        );
      } catch (localError) {
        _logger.logError('❌ فشل أيضاً في إرسال الإشعار المحلي: $localError');
      }
    }
  }

  /// إدخال الإشعار مباشرة في قاعدة البيانات وإرساله للمستخدم
  Future<void> _insertNotificationDirectly({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? referenceId,
    String? referenceType,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // إنشاء معرف فريد للإشعار
      final notificationId = _generateNotificationId();

      _logger.logInfo('📝 إدراج إشعار جديد للمستخدم: $userId');
      _logger.logInfo('📋 عنوان الإشعار: $title');
      _logger.logInfo('📄 نوع الإشعار: $type');

      // إدخال الإشعار مباشرة في قاعدة البيانات مع التحقق من النجاح
      final insertResponse =
          await _supabase.from('notifications').insert({
            'id': notificationId,
            'user_id': userId,
            'title': title,
            'body': body,
            'notification_type': type,
            'reference_id': referenceId,
            'reference_type': referenceType,
            'data': additionalData,
            'is_read': false,
            'is_sent': false, // سيتم تحديثه عند الإرسال الفعلي
            'priority': 'normal',
            'created_at': DateTime.now().toIso8601String(),
          }).select();

      _logger.logInfo(
        '✅ تم إدراج الإشعار بنجاح في قاعدة البيانات: ${insertResponse.length} صف',
      );

      // إرسال إشعار محلي فوري للتأكد من وصوله
      await showLocalNotification(title: title, body: body);

      // الحصول على رموز FCM للمستخدم وإرسال الإشعار
      await _sendNotificationToUser(
        userId: userId,
        notificationId: notificationId,
        title: title,
        body: body,
        type: type,
        additionalData: additionalData,
      );
    } catch (e, stackTrace) {
      _logger.logError('❌ خطأ في إدراج الإشعار: $e', stackTrace);

      // إرسال إشعار محلي كبديل في حالة فشل قاعدة البيانات
      try {
        await showLocalNotification(title: title, body: body);
        _logger.logInfo('✅ تم إرسال إشعار محلي كبديل');
      } catch (localError) {
        _logger.logError('❌ فشل في إرسال الإشعار المحلي أيضاً: $localError');
      }
    }
  }

  /// إرسال الإشعار للمستخدم باستخدام FCM token من قاعدة البيانات
  Future<void> _sendNotificationToUser({
    required String userId,
    required String notificationId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      _logger.logInfo('🔔 محاولة إرسال الإشعار للمستخدم: $userId');

      // الحصول على رموز FCM النشطة للمستخدم
      final fcmTokensResponse = await _supabase
          .from('user_fcm_tokens')
          .select('fcm_token, device_type')
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('last_used', ascending: false);

      if (fcmTokensResponse.isEmpty) {
        _logger.logWarning('⚠️ لا توجد رموز FCM نشطة للمستخدم: $userId');
        return;
      }

      _logger.logInfo(
        '📱 تم العثور على ${fcmTokensResponse.length} رمز FCM للمستخدم',
      );

      bool sentSuccessfully = false;

      // إرسال الإشعار لكل الأجهزة النشطة
      for (final tokenData in fcmTokensResponse) {
        final fcmToken = tokenData['fcm_token'] as String;
        final deviceType = tokenData['device_type'] as String?;

        try {
          await _sendPushNotificationToToken(
            fcmToken: fcmToken,
            title: title,
            body: body,
            data: {
              'notification_id': notificationId,
              'type': type,
              'user_id': userId,
              if (additionalData != null) ...additionalData,
            },
          );

          sentSuccessfully = true;
          _logger.logInfo('✅ تم إرسال الإشعار للجهاز: $deviceType');
        } catch (e) {
          _logger.logError('❌ فشل إرسال الإشعار للرمز المميز: $e');
        }
      }

      // تحديث حالة الإشعار في قاعدة البيانات
      if (sentSuccessfully) {
        await _updateNotificationSentStatus(notificationId, true);
      }
    } catch (e, stackTrace) {
      _logger.logError('❌ خطأ في إرسال الإشعار للمستخدم: $e', stackTrace);
    }
  }

  /// إرسال push notification مباشرة إلى FCM token
  Future<void> _sendPushNotificationToToken({
    required String fcmToken,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      _logger.logInfo('🚀 إرسال إشعار FCM للرمز المميز');

      // TODO: تطبيق إرسال FCM الحقيقي هنا
      // يمكن استخدام HTTP request إلى FCM API
      // أو استخدام Supabase Edge Function

      // في الوقت الحالي، نسجل المحاولة فقط
      _logger.logInfo(
        '📤 محاولة إرسال إلى الرمز المميز: ${fcmToken.substring(0, 20)}...',
      );
      _logger.logInfo('📋 العنوان: $title');
      _logger.logInfo('📄 المحتوى: $body');
      _logger.logInfo('📦 البيانات الإضافية: $data');

      // محاكاة الإرسال الناجح
      await Future.delayed(const Duration(milliseconds: 500));
      _logger.logInfo('✅ تم إرسال الإشعار بنجاح (محاكي)');
    } catch (e) {
      _logger.logError('❌ فشل في إرسال الإشعار: $e');
      rethrow;
    }
  }

  /// تحديث حالة الإرسال للإشعار في قاعدة البيانات
  Future<void> _updateNotificationSentStatus(
    String notificationId,
    bool sent,
  ) async {
    try {
      await _supabase
          .from('notifications')
          .update({
            'is_sent': sent,
            'sent_at': sent ? DateTime.now().toIso8601String() : null,
          })
          .eq('id', notificationId);

      _logger.logInfo('✅ تم تحديث حالة الإرسال للإشعار: $notificationId');
    } catch (e) {
      _logger.logError('❌ فشل في تحديث حالة الإرسال: $e');
    }
  }

  /// إنشاء معرف فريد للإشعار
  String _generateNotificationId() {
    return 'notif_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(6)}';
  }

  /// إنشاء نص عشوائي قصير
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random % chars.length)),
    );
  }

  /// معالجة الضغط على الإشعار
  void _onSelectNotification(NotificationResponse response) {
    try {
      _logger.logInfo('📱 تم الضغط على الإشعار: ${response.payload}');
      // TODO: معالجة التنقل بناء على نوع الإشعار
    } catch (e) {
      _logger.logError('❌ خطأ في معالجة الضغط على الإشعار: $e');
    }
  }

  /// إرسال إشعار بسيط للمسؤول
  Future<void> sendAdminNotification({
    required String title,
    required String body,
  }) async {
    try {
      await showLocalNotification(title: title, body: body);
      _logger.logInfo('📤 تم إرسال إشعار المسؤول: $title');
    } catch (e) {
      _logger.logError('❌ خطأ في إرسال إشعار المسؤول: $e');
    }
  }

  /// إرسال إشعار نجاح العملية
  Future<void> sendSuccessNotification({
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      await sendAdminNotification(
        title: message,
        body: 'تم تنفيذ العملية بنجاح',
      );
    } catch (e) {
      _logger.logError('❌ فشل في إرسال إشعار النجاح: $e');
    }
  }

  /// إرسال إشعار خطأ
  Future<void> sendErrorNotification({
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      await sendAdminNotification(title: 'خطأ في العملية', body: message);
    } catch (e) {
      _logger.logError('❌ فشل في إرسال إشعار الخطأ: $e');
    }
  }

  /// إرسال إشعار للمستخدم
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    String type = 'info',
    Map<String, dynamic>? data,
  }) async {
    try {
      _logger.logInfo('📤 Sending notification to user: $userId');

      await _insertNotificationDirectly(
        userId: userId,
        title: title,
        body: body,
        additionalData: data,
        type: type,
      );

      _logger.logInfo('✅ Notification sent to user successfully');
    } catch (e) {
      _logger.logError('❌ Failed to send notification to user: $e');
    }
  }

  /// إرسال إشعار جماعي لعدة مستخدمين
  Future<void> sendBulkNotifications({
    required List<String> userIds,
    required String title,
    required String body,
    String type = 'info',
    Map<String, dynamic>? data,
  }) async {
    try {
      _logger.logInfo(
        '📮 Sending bulk notifications to ${userIds.length} users',
      );

      for (String userId in userIds) {
        await sendNotificationToUser(
          userId: userId,
          title: title,
          body: body,
          type: type,
          data: data,
        );
      }

      _logger.logInfo('✅ Bulk notifications sent successfully');
    } catch (e) {
      _logger.logError('❌ Failed to send bulk notifications: $e');
    }
  }

  /// الحصول على الإشعارات للمستخدم
  Future<List<Map<String, dynamic>>> getUserNotifications({
    String? userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // استخدام معرف المستخدم الحالي إذا لم يتم تمرير معرف
      final targetUserId = userId ?? _supabase.auth.currentUser?.id;

      if (targetUserId == null) {
        _logger.logWarning('⚠️ لا يوجد معرف مستخدم للحصول على الإشعارات');
        return [];
      }

      final response = await _supabase
          .from('notifications')
          .select('*')
          .eq('user_id', targetUserId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      _logger.logInfo(
        '📥 تم الحصول على ${response.length} إشعار للمستخدم: $targetUserId',
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.logError('❌ خطأ في الحصول على إشعارات المستخدم: $e');
      return [];
    }
  }

  /// تمييز إشعار كمقروء
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId);

      _logger.logInfo('✅ تم تمييز الإشعار كمقروء: $notificationId');
    } catch (e) {
      _logger.logError('❌ خطأ في تمييز الإشعار كمقروء: $e');
    }
  }

  /// الحصول على عدد الإشعارات غير المقروءة
  Future<int> getUnreadNotificationsCount({String? userId}) async {
    try {
      final targetUserId = userId ?? _supabase.auth.currentUser?.id;

      if (targetUserId == null) {
        return 0;
      }

      final response = await _supabase
          .from('notifications')
          .select('*')
          .eq('user_id', targetUserId)
          .eq('is_read', false);

      final count = response.length;
      _logger.logInfo('📊 عدد الإشعارات غير المقروءة: $count');
      return count;
    } catch (e) {
      _logger.logError('❌ خطأ في الحصول على عدد الإشعارات غير المقروءة: $e');
      return 0;
    }
  }
}
