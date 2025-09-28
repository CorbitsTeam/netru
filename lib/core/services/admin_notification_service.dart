import 'package:supabase_flutter/supabase_flutter.dart';
import 'logger_service.dart';
import 'notification_template_service.dart';

/// Service for sending notifications to admin users
class AdminNotificationService {
  static final AdminNotificationService _instance =
      AdminNotificationService._internal();
  factory AdminNotificationService() => _instance;
  AdminNotificationService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final LoggerService _logger = LoggerService();

  /// Send notification to all admin users about a new report
  Future<void> sendNewReportNotificationToAdmins({
    required String reportId,
    required String reporterName,
    required String reportType,
    String? reportSummary,
    String? caseNumber,
  }) async {
    try {
      _logger.logInfo(
        '📧 Sending new report notification to admins for report: $reportId',
      );

      // Get all admin users
      final adminUsers = await _getAdminUsers();

      if (adminUsers.isEmpty) {
        _logger.logWarning('⚠️ No admin users found to notify');
        return;
      }

      _logger.logInfo('👥 Found ${adminUsers.length} admin users to notify');

      // Create notification for each admin
      final notifications = <Map<String, dynamic>>[];

      for (final admin in adminUsers) {
        final adminId = admin['id'] as String;

        // Generate notification content using template service
        final template = NotificationTemplateService.newReportSubmitted(
          reporterName: reporterName,
          caseNumber: caseNumber ?? reportId.substring(0, 8).toUpperCase(),
          reportType: reportType,
          reportSummary: reportSummary,
          reportId: reportId,
        );

        final notification = {
          'user_id': adminId,
          'title': template['title']!,
          'body': template['body']!,
          'notification_type': 'alert',
          'reference_id': reportId,
          'reference_type': 'report',
          'priority': 'high',
          'is_read': false,
          'data': {
            'report_id': reportId,
            'action': 'new_report_submitted',
            'reporter_name': reporterName,
            'report_type': reportType,
            'case_number': caseNumber ?? reportId.substring(0, 8).toUpperCase(),
          },
        };

        notifications.add(notification);
      }

      // Insert notifications in batch
      await _insertNotificationsBatch(notifications);

      // Try to send push notifications to admins if they have FCM tokens
      await _sendPushNotificationsToAdmins(adminUsers, notifications.first);

      _logger.logInfo(
        '✅ Successfully sent new report notifications to ${adminUsers.length} admins',
      );
    } catch (e) {
      _logger.logError(
        '❌ Failed to send new report notification to admins: $e',
      );
      // Don't throw exception to avoid breaking report submission
    }
  }

  /// Send notification to specific admin about report assignment
  Future<void> sendReportAssignmentNotification({
    required String reportId,
    required String adminId,
    required String investigatorName,
    String? notes,
    String? caseNumber,
  }) async {
    try {
      _logger.logInfo(
        '📧 Sending report assignment notification to admin: $adminId',
      );

      final template = NotificationTemplateService.reportAssignmentToUser(
        reporterName: 'المسؤول',
        caseNumber: caseNumber ?? reportId.substring(0, 8).toUpperCase(),
        investigatorName: investigatorName,
        investigatorTitle: 'محقق مختص',
        contactInfo: 'يمكن التواصل عبر التطبيق',
        expectedDuration: '48 ساعة',
      );

      final notification = {
        'user_id': adminId,
        'title': template['title']!,
        'body': template['body']!,
        'notification_type': 'alert',
        'reference_id': reportId,
        'reference_type': 'report',
        'priority': 'normal',
        'is_read': false,
        'data': {
          'report_id': reportId,
          'action': 'investigator_assigned',
          'investigator_name': investigatorName,
          'case_number': caseNumber ?? reportId.substring(0, 8).toUpperCase(),
        },
      };

      await _insertSingleNotification(notification);

      _logger.logInfo('✅ Successfully sent assignment notification to admin');
    } catch (e) {
      _logger.logError('❌ Failed to send assignment notification: $e');
    }
  }

  /// Get all admin users from the database
  Future<List<Map<String, dynamic>>> _getAdminUsers() async {
    try {
      final response = await _supabase
          .from('users')
          .select('id, email, full_name')
          .eq('user_type', 'admin')
          .eq('is_active', true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.logError('❌ Failed to fetch admin users: $e');
      return [];
    }
  }

  /// Insert multiple notifications in a single batch
  Future<void> _insertNotificationsBatch(
    List<Map<String, dynamic>> notifications,
  ) async {
    try {
      // Try using RPC function first
      try {
        await _supabase.rpc(
          'create_bulk_notifications',
          params: {'notifications_data': notifications},
        );
        return;
      } catch (rpcError) {
        _logger.logWarning(
          'RPC function failed, using direct insert: $rpcError',
        );
      }

      // Fallback to direct insert
      await _supabase.from('notifications').insert(notifications);
    } catch (e) {
      _logger.logError('❌ Failed to insert notifications batch: $e');
      rethrow;
    }
  }

  /// Insert a single notification
  Future<void> _insertSingleNotification(
    Map<String, dynamic> notification,
  ) async {
    try {
      // Try using RPC function first
      try {
        await _supabase.rpc('create_notification', params: notification);
        return;
      } catch (rpcError) {
        _logger.logWarning(
          'RPC function failed, using direct insert: $rpcError',
        );
      }

      // Fallback to direct insert
      await _supabase.from('notifications').insert(notification);
    } catch (e) {
      _logger.logError('❌ Failed to insert single notification: $e');
      rethrow;
    }
  }

  /// Send push notifications to admins who have FCM tokens
  Future<void> _sendPushNotificationsToAdmins(
    List<Map<String, dynamic>> adminUsers,
    Map<String, dynamic> notificationData,
  ) async {
    try {
      for (final admin in adminUsers) {
        final adminId = admin['id'] as String;

        // Get FCM tokens for this admin
        final tokens = await _supabase
            .from('user_fcm_tokens')
            .select('fcm_token')
            .eq('user_id', adminId)
            .eq('is_active', true);

        if (tokens.isNotEmpty) {
          // Here you could integrate with your FCM service
          // For now, just log that we would send push notifications
          _logger.logInfo(
            '🔔 Would send push notification to admin $adminId with ${tokens.length} tokens',
          );
        }
      }
    } catch (e) {
      _logger.logError('❌ Failed to send push notifications to admins: $e');
    }
  }

  /// Send notification when report status changes
  Future<void> sendReportStatusUpdateNotification({
    required String reportId,
    required String userId,
    required String newStatus,
    String? investigatorName,
    String? notes,
    String? caseNumber,
  }) async {
    try {
      _logger.logInfo(
        '📧 Sending status update notification for report: $reportId',
      );

      final template = NotificationTemplateService.reportStatusUpdate(
        status: newStatus,
        reporterName: 'المواطن الكريم',
        caseNumber: caseNumber ?? reportId.substring(0, 8).toUpperCase(),
        investigatorName: investigatorName,
        estimatedTime: '48 ساعة',
        additionalInfo: notes,
      );

      final notification = {
        'user_id': userId,
        'title': template['title']!,
        'body': template['body']!,
        'notification_type': 'info',
        'reference_id': reportId,
        'reference_type': 'report',
        'priority': 'normal',
        'is_read': false,
        'data': {
          'report_id': reportId,
          'action': 'status_updated',
          'new_status': newStatus,
          'investigator_name': investigatorName,
          'case_number': caseNumber ?? reportId.substring(0, 8).toUpperCase(),
        },
      };

      await _insertSingleNotification(notification);

      _logger.logInfo('✅ Successfully sent status update notification');
    } catch (e) {
      _logger.logError('❌ Failed to send status update notification: $e');
    }
  }
}
