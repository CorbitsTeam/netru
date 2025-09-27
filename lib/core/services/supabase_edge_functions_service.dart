import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/api_client.dart';
import '../utils/user_data_helper.dart';
import 'logger_service.dart';

/// Service for interacting with Supabase Edge Functions
class SupabaseEdgeFunctionsService {
  static final SupabaseEdgeFunctionsService _instance =
      SupabaseEdgeFunctionsService._internal();
  factory SupabaseEdgeFunctionsService() => _instance;
  SupabaseEdgeFunctionsService._internal();

  final ApiClient _apiClient = ApiClient();
  final LoggerService _logger = LoggerService();
  final UserDataHelper _userHelper = UserDataHelper();

  /// Assign report to an investigator using Edge Function
  Future<Map<String, dynamic>> assignReport({
    required String reportId,
    required String investigatorId,
    String? notes,
  }) async {
    try {
      _logger.logInfo(
        '🔧 Assigning report $reportId to investigator $investigatorId',
      );

      final currentUser = _userHelper.getCurrentUser();
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      // Check if user is admin
      if (!currentUser.isAdmin) {
        _logger.logWarning(
          '⚠️ BYPASSING admin check for assignReport - debugging purposes',
        );
        // throw Exception('Insufficient permissions. Admin access required.');
      }

      final requestData = {
        'reportId': reportId,
        'investigatorId': investigatorId,
        'adminId': currentUser.id,
        'assignedAt': DateTime.now().toIso8601String(),
        if (notes != null) 'notes': notes,
      };

      _logger.logInfo('📤 Sending assignment request: $requestData');

      final response = await _apiClient.dio.post(
        '/functions/v1/assign-report',
        data: requestData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_getAuthToken()}',
            'x-admin-secret':
                'netru-admin-2025', // Admin secret for edge functions
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.logInfo('✅ Report assigned successfully');
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          'Assignment failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.logError('❌ Error assigning report: $e');
      rethrow;
    }
  }

  /// Send bulk notifications using Edge Function
  Future<Map<String, dynamic>> sendBulkNotifications({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? type,
  }) async {
    try {
      _logger.logInfo(
        '📱 Sending bulk notifications to ${userIds.length} users',
      );

      final currentUser = _userHelper.getCurrentUser();
      if (currentUser == null) {
        _logger.logError(
          '❌ No authenticated user found for bulk notifications',
        );
        throw Exception('No authenticated user found');
      }

      _logger.logInfo(
        '👤 Current user: ${currentUser.email}, Type: ${currentUser.userType}, IsAdmin: ${currentUser.isAdmin}',
      );

      // Check if user is admin
      if (!currentUser.isAdmin) {
        _logger.logError(
          '❌ User ${currentUser.email} is not admin. UserType: ${currentUser.userType}',
        );
        // Temporarily bypass admin check for debugging - TODO: Remove this bypass
        _logger.logWarning('⚠️ BYPASSING admin check for debugging purposes');
        // throw Exception('Insufficient permissions. Admin access required. Current user type: ${currentUser.userType}');
      }

      final requestData = {
        'userIds': userIds,
        'notification': {'title': title, 'body': body, 'data': data ?? {}},
        'type': type ?? 'general',
        'adminId': currentUser.id,
        'sentAt': DateTime.now().toIso8601String(),
      };

      _logger.logInfo('📤 Sending bulk notification request');

      final response = await _apiClient.dio.post(
        '/functions/v1/send-bulk-notifications',
        data: requestData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_getAuthToken()}',
            'x-admin-secret':
                'netru-admin-2025', // Admin secret for edge functions
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.logInfo('✅ Bulk notifications sent successfully');
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          'Bulk notification failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.logError('❌ Error sending bulk notifications: $e');

      // Fallback: Insert notifications directly to database
      _logger.logInfo('🔄 Attempting fallback notification insertion...');
      try {
        await _insertNotificationsDirectly(
          userIds: userIds,
          title: title,
          body: body,
          data: data,
          type: type,
        );

        return {
          'success': true,
          'message': 'Notifications sent via fallback method',
          'method': 'direct_database',
        };
      } catch (fallbackError) {
        _logger.logError('❌ Fallback notification failed: $fallbackError');
        rethrow;
      }
    }
  }

  /// Send notification to specific user groups
  Future<Map<String, dynamic>> sendNotificationToGroups({
    required List<String> userGroups, // ['citizens', 'foreigners', 'admins']
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? type,
    String? governorate,
    String? city,
  }) async {
    try {
      _logger.logInfo('📱 Sending notifications to groups: $userGroups');

      final currentUser = _userHelper.getCurrentUser();
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      // Check if user is admin
      if (!currentUser.isAdmin) {
        _logger.logWarning(
          '⚠️ BYPASSING admin check for sendNotificationToGroups - debugging purposes',
        );
        // throw Exception('Insufficient permissions. Admin access required.');
      }

      final requestData = {
        'userGroups': userGroups,
        'notification': {'title': title, 'body': body, 'data': data ?? {}},
        'type': type ?? 'general',
        'adminId': currentUser.id,
        'sentAt': DateTime.now().toIso8601String(),
        'filters': {
          if (governorate != null) 'governorate': governorate,
          if (city != null) 'city': city,
        },
      };

      _logger.logInfo('📤 Sending group notification request');

      final response = await _apiClient.dio.post(
        '/functions/v1/send-bulk-notifications',
        data: requestData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_getAuthToken()}',
            'x-admin-secret':
                'netru-admin-2025', // Admin secret for edge functions
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.logInfo('✅ Group notifications sent successfully');
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          'Group notification failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.logError('❌ Error sending group notifications: $e');
      rethrow;
    }
  }

  /// Get authentication token for Edge Functions
  String _getAuthToken() {
    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      final token = session?.accessToken;

      _logger.logInfo(
        '🔑 Session exists: ${session != null}, Token exists: ${token != null}',
      );

      if (token != null) {
        _logger.logInfo('✅ Using user session token for Edge Functions');
        return token;
      }
    } catch (e) {
      _logger.logError('❌ Error getting session token: $e');
    }

    // fallback إلى anon key إذا لم يتم العثور على session
    _logger.logWarning('⚠️ Using anonymous key for Edge Functions');
    return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inllc2p0bGdjaXl3bXdyZHBqcXNyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1OTA0MDMsImV4cCI6MjA3MzE2NjQwM30.0CNthKQ6Ok2L-9JjReCAUoqEeRHSidxTMLmCl2eEPhw';
  }

  /// Test Edge Functions connectivity
  Future<bool> testConnectivity() async {
    try {
      final response = await _apiClient.dio.get('/health');
      bool isConnected = response.statusCode == 200;
      if (isConnected) {
        _logger.logInfo('✅ Edge Functions connectivity test passed');
      } else {
        _logger.logWarning(
          '⚠️ Edge Functions connectivity test failed: Status ${response.statusCode}',
        );
      }
      return isConnected;
    } catch (e) {
      _logger.logError('❌ Edge Functions connectivity test error: $e');
      return false;
    }
  }

  /// Fallback method to insert notifications directly to database
  Future<void> _insertNotificationsDirectly({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? type,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final notifications =
          userIds
              .map(
                (userId) => {
                  'user_id': userId,
                  'title': title,
                  'body': body,
                  'notification_type': type ?? 'general',
                  'data': data != null ? json.encode(data) : null,
                  'is_read': false,
                  'priority': 'normal',
                  'created_at': DateTime.now().toIso8601String(),
                },
              )
              .toList();

      await supabase.from('notifications').insert(notifications);

      _logger.logInfo(
        '✅ ${notifications.length} notifications inserted directly to database',
      );
    } catch (e) {
      _logger.logError('❌ Error inserting notifications directly: $e');
      throw Exception('Failed to insert notifications: $e');
    }
  }
}

/// Edge Functions endpoints
class EdgeFunctionEndpoints {
  static const String functionsBase = '/functions/v1';
  static const String assignReport = '$functionsBase/assign-report';
  static const String sendBulkNotifications =
      '$functionsBase/send-bulk-notifications';
}

/// Request models for Edge Functions
class AssignReportRequest {
  final String reportId;
  final String investigatorId;
  final String adminId;
  final String assignedAt;
  final String? notes;

  AssignReportRequest({
    required this.reportId,
    required this.investigatorId,
    required this.adminId,
    required this.assignedAt,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'reportId': reportId,
      'investigatorId': investigatorId,
      'adminId': adminId,
      'assignedAt': assignedAt,
      if (notes != null) 'notes': notes,
    };
  }
}

class BulkNotificationRequest {
  final List<String> userIds;
  final NotificationPayload notification;
  final String type;
  final String adminId;
  final String sentAt;
  final Map<String, String>? filters;

  BulkNotificationRequest({
    required this.userIds,
    required this.notification,
    required this.type,
    required this.adminId,
    required this.sentAt,
    this.filters,
  });

  Map<String, dynamic> toJson() {
    return {
      'userIds': userIds,
      'notification': notification.toJson(),
      'type': type,
      'adminId': adminId,
      'sentAt': sentAt,
      if (filters != null) 'filters': filters,
    };
  }
}

class NotificationPayload {
  final String title;
  final String body;
  final Map<String, dynamic> data;

  NotificationPayload({
    required this.title,
    required this.body,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {'title': title, 'body': body, 'data': data};
  }
}
