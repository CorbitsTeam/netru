import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'logger_service.dart';
import 'notification_template_service.dart';

/// Enhanced notification service that uses Edge Functions and database persistence
/// للتعامل مع إرسال الإشعارات لمقدمي البلاغات عند تحديث حالة البلاغ
class ReportNotificationService {
  static final ReportNotificationService _instance =
      ReportNotificationService._internal();
  factory ReportNotificationService() => _instance;
  ReportNotificationService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final LoggerService _logger = LoggerService();
  final Uuid _uuid = const Uuid();

  /// Send notification to report submitter when status changes
  /// إرسال إشعار لمقدم البلاغ عند تغيير حالة البلاغ
  Future<void> sendReportStatusNotification({
    required String reportId,
    required String newStatus,
    required String caseNumber,
    String? adminNotes,
    String? investigatorName,
    String? estimatedTime,
  }) async {
    try {
      _logger.logInfo(
        '🔔 Sending report status notification for report: $reportId',
      );

      // 1. الحصول على بيانات البلاغ ومقدم البلاغ
      final reportData = await _getReportAndUserData(reportId);
      if (reportData == null) {
        _logger.logError(
          '❌ Could not find report or user data for report: $reportId',
        );
        return;
      }

      _logger.logInfo(
        '📊 Report data found - User ID: ${reportData['user_id']}, Case: ${reportData['case_number']}',
      );

      // 2. الحصول على FCM token للمستخدم
      final fcmTokens = await _getUserFcmTokens(reportData['user_id']);
      if (fcmTokens.isEmpty) {
        _logger.logWarning(
          '⚠️ No FCM tokens found for user: ${reportData['user_id']} - will save to database only',
        );
      } else {
        _logger.logInfo(
          '📱 Found ${fcmTokens.length} FCM token(s) for user: ${reportData['user_id']}',
        );
      }

      // 3. إنشاء محتوى الإشعار باستخدام templates
      final notificationContent = _createNotificationContent(
        status: newStatus,
        caseNumber: caseNumber,
        reporterName: reportData['reporter_first_name'],
        investigatorName: investigatorName,
        estimatedTime: estimatedTime,
        adminNotes: adminNotes,
      );

      // 4. حفظ الإشعار في قاعدة البيانات
      final notificationId = await _saveNotificationToDatabase(
        userId: reportData['user_id'],
        title: notificationContent['title']!,
        body: notificationContent['body']!,
        reportId: reportId,
        notificationType: _getNotificationTypeFromStatus(newStatus),
        priority: _getPriorityFromStatus(newStatus),
        additionalData: {
          'case_number': caseNumber,
          'new_status': newStatus,
          'investigator_name': investigatorName,
          'estimated_time': estimatedTime,
          if (adminNotes != null) 'admin_notes': adminNotes,
        },
      );

      // 5. إرسال push notifications لجميع أجهزة المستخدم
      bool anyNotificationSent = false;
      for (final token in fcmTokens) {
        final sent = await _sendPushNotificationViaEdgeFunction(
          fcmToken: token['fcm_token'],
          title: notificationContent['title']!,
          body: notificationContent['body']!,
          data: {
            'notification_id': notificationId,
            'report_id': reportId,
            'case_number': caseNumber,
            'new_status': newStatus,
            'type': 'report_status_update',
          },
        );
        if (sent) anyNotificationSent = true;
      }

      // 6. تحديث حالة الإرسال في قاعدة البيانات
      await _updateNotificationSentStatus(notificationId, anyNotificationSent);

      _logger.logInfo('✅ Report status notification completed successfully');
    } catch (e) {
      _logger.logError('❌ Error sending report status notification: $e');
      rethrow;
    }
  }

  /// Get report data along with user information
  /// الحصول على بيانات البلاغ مع معلومات المستخدم
  Future<Map<String, dynamic>?> _getReportAndUserData(String reportId) async {
    try {
      final response =
          await _supabase
              .from('reports')
              .select('''
            id,
            user_id,
            reporter_first_name,
            reporter_last_name,
            reporter_phone,
            case_number,
            report_status,
            report_details,
            submitted_at
          ''')
              .eq('id', reportId)
              .single();

      return response;
    } catch (e) {
      _logger.logError('❌ Error fetching report data: $e');
      return null;
    }
  }

  /// Get all active FCM tokens for a user
  /// الحصول على جميع FCM tokens النشطة للمستخدم
  Future<List<Map<String, dynamic>>> _getUserFcmTokens(String userId) async {
    try {
      final response = await _supabase
          .from('user_fcm_tokens')
          .select('fcm_token, device_type, device_id')
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('last_used', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.logError('❌ Error fetching FCM tokens: $e');
      return [];
    }
  }

  /// Create notification content based on status
  /// إنشاء محتوى الإشعار حسب الحالة
  Map<String, String> _createNotificationContent({
    required String status,
    required String caseNumber,
    String? reporterName,
    String? investigatorName,
    String? estimatedTime,
    String? adminNotes,
  }) {
    // استخدام static methods من NotificationTemplateService
    final template = NotificationTemplateService.reportStatusUpdate(
      status: status,
      reporterName: reporterName ?? 'المواطن الكريم',
      caseNumber: caseNumber,
      investigatorName: investigatorName,
      estimatedTime: estimatedTime,
      additionalInfo: adminNotes,
    );

    return {'title': template['title']!, 'body': template['body']!};
  }

  /// Save notification to database
  /// حفظ الإشعار في قاعدة البيانات
  Future<String> _saveNotificationToDatabase({
    required String userId,
    required String title,
    required String body,
    required String reportId,
    required String notificationType,
    required String priority,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final notificationId = _uuid.v4();

      final notificationData = {
        'id': notificationId,
        'user_id': userId,
        'title': title,
        'title_ar': title, // نفس العنوان بالعربية
        'body': body,
        'body_ar': body, // نفس المحتوى بالعربية
        'notification_type': notificationType,
        'reference_id': reportId,
        'reference_type': 'report',
        'data': additionalData,
        'is_read': false,
        'is_sent': false, // سيتم تحديثها بعد الإرسال
        'priority': priority,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('notifications').insert(notificationData);

      _logger.logInfo('✅ Notification saved to database: $notificationId');
      return notificationId;
    } catch (e) {
      _logger.logError('❌ Error saving notification to database: $e');
      rethrow;
    }
  }

  /// Send push notification via Edge Function
  /// إرسال push notification عبر Edge Function
  Future<bool> _sendPushNotificationViaEdgeFunction({
    required String fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      _logger.logInfo('🚀 Sending push notification via Edge Function');

      final response = await _supabase.functions.invoke(
        'send-fcm-notification',
        body: {
          'fcm_token': fcmToken,
          'title': title,
          'body': body,
          'data': data ?? {},
        },
      );

      if (response.status == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          _logger.logInfo('✅ Push notification sent successfully');
          return true;
        } else {
          _logger.logError(
            '❌ Push notification failed: ${responseData['error']}',
          );
          return false;
        }
      } else {
        _logger.logError('❌ Edge Function call failed: ${response.status}');
        return false;
      }
    } catch (e) {
      _logger.logError('❌ Error calling Edge Function: $e');
      return false;
    }
  }

  /// Update notification sent status in database
  /// تحديث حالة الإرسال في قاعدة البيانات
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

      _logger.logInfo('✅ Updated notification sent status: $sent');
    } catch (e) {
      _logger.logError('❌ Error updating notification sent status: $e');
    }
  }

  /// Get notification type from status
  /// تحديد نوع الإشعار حسب الحالة
  String _getNotificationTypeFromStatus(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return 'success';
      case 'rejected':
        return 'error';
      case 'under_investigation':
        return 'info';
      case 'received':
        return 'report_success';
      default:
        return 'info';
    }
  }

  /// Get priority from status
  /// تحديد أولوية الإشعار حسب الحالة
  String _getPriorityFromStatus(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'rejected':
        return 'high';
      case 'under_investigation':
        return 'normal';
      case 'received':
        return 'normal';
      default:
        return 'normal';
    }
  }

  /// Send notification when report is first submitted (success notification)
  /// إرسال إشعار عند تقديم البلاغ لأول مرة (إشعار نجاح)
  Future<void> sendReportSubmissionSuccessNotification({
    required String reportId,
    required String userId,
    required String caseNumber,
  }) async {
    try {
      _logger.logInfo('🔔 Sending report submission success notification');

      await sendReportStatusNotification(
        reportId: reportId,
        newStatus: 'received',
        caseNumber: caseNumber,
      );
    } catch (e) {
      _logger.logError('❌ Error sending submission success notification: $e');
      rethrow;
    }
  }

  /// Test notification system (for debugging)
  /// اختبار نظام الإشعارات (للتطوير والاختبار)
  Future<void> testNotificationSystem(String userId) async {
    try {
      _logger.logInfo('🧪 Testing notification system for user: $userId');

      // إنشاء إشعار تجريبي
      final testNotificationId = await _saveNotificationToDatabase(
        userId: userId,
        title: 'اختبار نظام الإشعارات',
        body: 'هذا إشعار تجريبي للتأكد من عمل النظام بشكل صحيح.',
        reportId: _uuid.v4(), // معرف وهمي للاختبار
        notificationType: 'info',
        priority: 'normal',
        additionalData: {
          'test': true,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      _logger.logInfo('✅ Test notification created: $testNotificationId');
    } catch (e) {
      _logger.logError('❌ Error testing notification system: $e');
      rethrow;
    }
  }
}
