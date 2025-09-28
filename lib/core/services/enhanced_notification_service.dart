import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:netru_app/core/utils/user_data_helper.dart';
import 'logger_service.dart';
import 'notification_template_service.dart';
import 'simple_notification_service.dart';

/// Enhanced notification service that handles both user and admin notifications
/// with database persistence and proper FCM integration
class EnhancedNotificationService {
  static final EnhancedNotificationService _instance =
      EnhancedNotificationService._internal();
  factory EnhancedNotificationService() => _instance;
  EnhancedNotificationService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final LoggerService _logger = LoggerService();
  final SimpleNotificationService _simpleNotificationService =
      SimpleNotificationService();

  /// Send notification to current user when they successfully submit a report
  Future<void> sendReportSubmissionSuccessNotification({
    required String reportId,
    required String reportType,
    required String reporterName,
    String? caseNumber,
  }) async {
    try {
      _logger.logInfo('📧 Sending report submission success notification');

      // Get current user
      final userHelper = UserDataHelper();
      final currentUser = userHelper.getCurrentUser();

      if (currentUser == null) {
        _logger.logWarning('⚠️ No current user found for notification');
        return;
      }

      final userId = currentUser.id;
      final actualCaseNumber =
          caseNumber ?? reportId.substring(0, 8).toUpperCase();

      // Generate notification using template
      final template = NotificationTemplateService.reportSubmissionSuccess(
        reporterName: reporterName,
        caseNumber: actualCaseNumber,
        reportType: reportType,
        expectedProcessingTime: '48 ساعة',
      );

      // Create notification data
      final notificationData = {
        'user_id': userId,
        'title': template['title']!,
        'body': template['body']!,
        'notification_type': 'report_submitted',
        'reference_id': reportId,
        'reference_type': 'report',
        'priority': 'normal',
        'is_read': false,
        'data': {
          'report_id': reportId,
          'case_number': actualCaseNumber,
          'report_type': reportType,
          'action': 'report_submitted_successfully',
        },
      };

      // Insert notification into database
      await _insertNotificationWithRetry(notificationData);

      // Send local notification
      await _simpleNotificationService.showLocalNotification(
        title: template['title']!,
        body: template['body']!,
        data: notificationData['data'] as Map<String, dynamic>?,
      );

      _logger.logInfo('✅ Report submission success notification sent to user');
    } catch (e) {
      _logger.logError('❌ Failed to send report submission notification: $e');
    }
  }

  /// Send notification to all admin users when a new report is submitted
  Future<void> sendNewReportNotificationToAdmins({
    required String reportId,
    required String reporterName,
    required String reportType,
    String? reportSummary,
    String? caseNumber,
    String? nationalId,
  }) async {
    try {
      _logger.logInfo('📧 Sending new report notification to all admins');

      // Get all admin users
      final adminUsers = await _getAdminUsers();

      if (adminUsers.isEmpty) {
        _logger.logWarning('⚠️ No admin users found to notify');
        return;
      }

      final actualCaseNumber =
          caseNumber ?? reportId.substring(0, 8).toUpperCase();

      // Generate notification template for admins
      final template = NotificationTemplateService.newReportSubmittedForAdmin(
        reporterName: reporterName,
        reportType: reportType,
        caseNumber: actualCaseNumber,
        reportSummary: reportSummary,
        nationalId: nationalId,
      );

      // Create notifications for each admin
      final notifications = <Map<String, dynamic>>[];

      for (final admin in adminUsers) {
        final adminId = admin['id'] as String;

        final notificationData = {
          'user_id': adminId,
          'title': template['title']!,
          'body': template['body']!,
          'notification_type': 'new_report_for_admin',
          'reference_id': reportId,
          'reference_type': 'report',
          'priority': 'high',
          'is_read': false,
          'data': {
            'report_id': reportId,
            'case_number': actualCaseNumber,
            'reporter_name': reporterName,
            'reporter_national_id': nationalId,
            'report_type': reportType,
            'action': 'new_report_submitted',
            'admin_action_required': true,
          },
        };

        notifications.add(notificationData);
      }

      // Insert all notifications in batch
      await _insertNotificationsBatch(notifications);

      // Send local notifications to active admins (if any admin is currently logged in)
      await _sendLocalNotificationToActiveAdmins(template, notifications.first);

      _logger.logInfo(
        '✅ New report notifications sent to ${adminUsers.length} admins',
      );
    } catch (e) {
      _logger.logError('❌ Failed to send admin notifications: $e');
    }
  }

  /// Send notification when report status is updated
  Future<void> sendReportStatusUpdateNotification({
    required String reportId,
    required String newStatus,
    String? investigatorName,
    String? notes,
    String? caseNumber,
  }) async {
    try {
      _logger.logInfo('📧 Sending report status update notification');

      // Get report details to find the owner
      final reportResponse =
          await _supabase
              .from('reports')
              .select(
                'user_id, reporter_first_name, reporter_last_name, case_number',
              )
              .eq('id', reportId)
              .single();

      final userId = reportResponse['user_id'] as String?;
      final reporterName =
          '${reportResponse['reporter_first_name']} ${reportResponse['reporter_last_name']}';
      final actualCaseNumber =
          reportResponse['case_number'] as String? ??
          caseNumber ??
          reportId.substring(0, 8).toUpperCase();

      if (userId == null) {
        _logger.logWarning(
          '⚠️ Report has no associated user (anonymous report)',
        );
        return;
      }

      // Generate notification template
      final template = NotificationTemplateService.reportStatusUpdate(
        status: newStatus,
        reporterName: reporterName,
        caseNumber: actualCaseNumber,
        investigatorName: investigatorName,
        estimatedTime: '48 ساعة',
        additionalInfo: notes,
      );

      // Create notification data
      final notificationData = {
        'user_id': userId,
        'title': template['title']!,
        'body': template['body']!,
        'notification_type': 'report_status_update',
        'reference_id': reportId,
        'reference_type': 'report',
        'priority': 'normal',
        'is_read': false,
        'data': {
          'report_id': reportId,
          'case_number': actualCaseNumber,
          'old_status': 'previous_status', // Could be tracked separately
          'new_status': newStatus,
          'investigator_name': investigatorName,
          'action': 'status_updated',
        },
      };

      // Insert notification into database
      await _insertNotificationWithRetry(notificationData);

      // Send using simple notification service
      await _simpleNotificationService.sendNotificationToUser(
        userId: userId,
        title: template['title']!,
        body: template['body']!,
        type: 'report_status_update',
        data: notificationData['data'] as Map<String, dynamic>?,
      );

      _logger.logInfo('✅ Report status update notification sent successfully');
    } catch (e) {
      _logger.logError('❌ Failed to send status update notification: $e');
    }
  }

  /// Get all admin users from database
  Future<List<Map<String, dynamic>>> _getAdminUsers() async {
    try {
      final response = await _supabase
          .from('users')
          .select('id, email, full_name, user_type')
          .eq('user_type', 'admin')
          .eq('is_active', true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.logError('❌ Failed to fetch admin users: $e');
      return [];
    }
  }

  /// Insert a single notification with retry logic
  Future<void> _insertNotificationWithRetry(
    Map<String, dynamic> notification,
  ) async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        // Try using RPC function first (if available)
        try {
          await _supabase.rpc('create_notification', params: notification);
          _logger.logInfo('✅ Notification inserted using RPC function');
          return;
        } catch (rpcError) {
          _logger.logWarning(
            'RPC function failed, using direct insert: $rpcError',
          );
        }

        // Fallback to direct insert
        await _supabase.from('notifications').insert(notification);
        _logger.logInfo('✅ Notification inserted using direct insert');
        return;
      } catch (e) {
        retryCount++;
        _logger.logWarning(
          '❌ Notification insert attempt $retryCount failed: $e',
        );

        if (retryCount >= maxRetries) {
          _logger.logError(
            '❌ Failed to insert notification after $maxRetries attempts',
          );
          throw e;
        }

        // Wait before retry
        await Future.delayed(Duration(milliseconds: 500 * retryCount));
      }
    }
  }

  /// Insert multiple notifications in batch
  Future<void> _insertNotificationsBatch(
    List<Map<String, dynamic>> notifications,
  ) async {
    try {
      // Try using batch RPC function first
      try {
        await _supabase.rpc(
          'create_bulk_notifications',
          params: {'notifications_data': notifications},
        );
        _logger.logInfo('✅ Bulk notifications inserted using RPC function');
        return;
      } catch (rpcError) {
        _logger.logWarning(
          'Bulk RPC function failed, using direct insert: $rpcError',
        );
      }

      // Fallback to direct batch insert
      await _supabase.from('notifications').insert(notifications);
      _logger.logInfo('✅ Bulk notifications inserted using direct insert');
    } catch (e) {
      _logger.logError('❌ Failed to insert bulk notifications: $e');

      // Fallback: insert one by one
      _logger.logInfo('🔄 Trying individual inserts as fallback...');
      int successCount = 0;

      for (final notification in notifications) {
        try {
          await _insertNotificationWithRetry(notification);
          successCount++;
        } catch (individualError) {
          _logger.logError(
            '❌ Failed to insert individual notification: $individualError',
          );
        }
      }

      _logger.logInfo(
        '📊 Individual fallback complete: $successCount/${notifications.length} notifications inserted',
      );
    }
  }

  /// Send local notification to currently active admins
  Future<void> _sendLocalNotificationToActiveAdmins(
    Map<String, String> template,
    Map<String, dynamic> notificationData,
  ) async {
    try {
      // Check if any admin is currently logged in (simple approach)
      final currentUser = _supabase.auth.currentUser;
      if (currentUser != null) {
        // Get user details to check if they're an admin
        final userResponse =
            await _supabase
                .from('users')
                .select('user_type')
                .eq('id', currentUser.id)
                .single();

        final userType = userResponse['user_type'] as String?;
        if (userType == 'admin') {
          // Send local notification to the current admin
          await _simpleNotificationService.showLocalNotification(
            title: template['title']!,
            body: template['body']!,
            data: notificationData['data'] as Map<String, dynamic>?,
          );
          _logger.logInfo('📱 Local notification sent to current admin user');
        }
      }
    } catch (e) {
      _logger.logError('❌ Failed to send local notification to admins: $e');
    }
  }

  /// Send a general notification to a specific user
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    String type = 'general',
    String? referenceId,
    String? referenceType,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final notificationData = {
        'user_id': userId,
        'title': title,
        'body': body,
        'notification_type': type,
        'reference_id': referenceId,
        'reference_type': referenceType,
        'priority': 'normal',
        'is_read': false,
        'data': additionalData,
      };

      await _insertNotificationWithRetry(notificationData);

      // Also send through simple notification service
      await _simpleNotificationService.sendNotificationToUser(
        userId: userId,
        title: title,
        body: body,
        type: type,
        data: additionalData,
      );

      _logger.logInfo('✅ General notification sent to user: $userId');
    } catch (e) {
      _logger.logError('❌ Failed to send general notification: $e');
    }
  }

  /// Initialize the enhanced notification service
  Future<void> init() async {
    try {
      await _simpleNotificationService.init();
      _logger.logInfo('✅ EnhancedNotificationService initialized');
    } catch (e) {
      _logger.logError('❌ EnhancedNotificationService init failed: $e');
    }
  }
}
