import '../../../../core/network/api_client.dart';
import '../../../../core/services/supabase_edge_functions_service.dart';
import '../../../../core/services/admin_notifications_service.dart';
import '../models/admin_notification_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AdminNotificationRemoteDataSource {
  Future<List<AdminNotificationModel>> getAllNotifications({
    int? page,
    int? limit,
    String? search,
    String? type,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<AdminNotificationModel> getNotificationById(String notificationId);

  Future<AdminNotificationModel> createNotification({
    required String title,
    required String body,
    required String type,
    List<String>? userIds,
    List<String>? userGroups,
    Map<String, dynamic>? data,
    DateTime? scheduledAt,
  });

  Future<void> sendBulkNotifications({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? type,
  });

  Future<void> sendNotificationToGroups({
    required List<String> userGroups,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? type,
    String? governorate,
    String? city,
  });

  Future<AdminNotificationModel> updateNotification(
    String notificationId,
    Map<String, dynamic> updates,
  );

  Future<void> deleteNotification(String notificationId);

  Future<Map<String, dynamic>> getNotificationStatistics();

  Future<List<AdminNotificationModel>> getScheduledNotifications();
}

class AdminNotificationRemoteDataSourceImpl
    implements AdminNotificationRemoteDataSource {
  final ApiClient apiClient;
  final SupabaseEdgeFunctionsService edgeFunctionsService;
  final AdminNotificationsService adminNotificationsService;

  AdminNotificationRemoteDataSourceImpl({
    required this.apiClient,
    required this.edgeFunctionsService,
    required this.adminNotificationsService,
  });

  @override
  Future<List<AdminNotificationModel>> getAllNotifications({
    int? page = 1,
    int? limit = 20,
    String? type,
    String? status,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final supabase = Supabase.instance.client;

      // Use the new admin-notifications Edge Function
      final queryParams = <String, String>{
        'action': 'get_notifications',
        'page': (page ?? 1).toString(),
        'limit': (limit ?? 20).toString(),
      };

      if (type != null) queryParams['type'] = type;
      if (status != null) queryParams['status'] = status;
      if (search != null) queryParams['search'] = search;

      final response = await supabase.functions.invoke(
        'admin-notifications',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final List<dynamic> notificationsJson = response.data['data'] ?? [];

        return notificationsJson.map((json) {
          // Transform the response to match our model structure
          final transformedJson = {
            'id': json['id'],
            'user_id': json['user_id'],
            'user_name': json['users']?['full_name'],
            'title': json['title'],
            'title_ar': json['title_ar'],
            'body': json['body'],
            'body_ar': json['body_ar'],
            'notification_type': json['notification_type'],
            'reference_id': json['reference_id'],
            'reference_type': json['reference_type'],
            'data': json['data'],
            'is_read': json['is_read'],
            'is_sent': json['fcm_message_id'] != null,
            'priority': json['priority'] ?? 'normal',
            'fcm_message_id': json['fcm_message_id'],
            'created_at': json['created_at'],
            'read_at': json['read_at'],
            'sent_at':
                json['fcm_message_id'] != null ? json['created_at'] : null,
          };

          return AdminNotificationModel.fromJson(transformedJson);
        }).toList();
      } else {
        throw Exception(
          response.data['error'] ?? 'Failed to fetch notifications',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  @override
  Future<AdminNotificationModel> getNotificationById(
    String notificationId,
  ) async {
    try {
      final result = await adminNotificationsService.getNotifications(
        userId: notificationId, // This might need adjustment based on API
      );

      final notifications = result['data'] as List<dynamic>? ?? [];
      if (notifications.isEmpty) {
        throw Exception('Notification not found');
      }

      return AdminNotificationModel.fromJson(notifications.first);
    } catch (e) {
      throw Exception('Failed to get notification by ID: $e');
    }
  }

  @override
  Future<AdminNotificationModel> createNotification({
    required String title,
    required String body,
    required String type,
    List<String>? userIds,
    List<String>? userGroups,
    Map<String, dynamic>? data,
    DateTime? scheduledAt,
  }) async {
    try {
      // If userIds is provided, create for first user
      // For bulk notifications, use sendBulkNotifications instead
      String targetUserId = 'admin'; // Default admin user
      if (userIds != null && userIds.isNotEmpty) {
        targetUserId = userIds.first;
      }

      final result = await adminNotificationsService.createNotification(
        userId: targetUserId,
        title: title,
        body: body,
        notificationType: type,
        data: data,
      );

      final notificationData = result['data'] ?? result;
      return AdminNotificationModel.fromJson(notificationData);
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  @override
  Future<void> sendBulkNotifications({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? type,
  }) async {
    try {
      await adminNotificationsService.sendBulkNotification(
        title: title,
        body: body,
        notificationType: type ?? 'general',
        targetType: 'specific_users',
        targetValue: userIds,
        data: data,
      );
    } catch (e) {
      throw Exception('Failed to send bulk notifications: $e');
    }
  }

  @override
  Future<void> sendNotificationToGroups({
    required List<String> userGroups,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? type,
    String? governorate,
    String? city,
  }) async {
    try {
      await adminNotificationsService.sendBulkNotification(
        title: title,
        body: body,
        notificationType: type ?? 'general',
        targetType: 'user_type',
        targetValue: userGroups.first, // Use first group for now
        data: data,
      );
    } catch (e) {
      throw Exception('Failed to send group notifications: $e');
    }
  }

  @override
  Future<AdminNotificationModel> updateNotification(
    String notificationId,
    Map<String, dynamic> updates,
  ) async {
    try {
      // Since AdminNotificationsService doesn't have updateNotification,
      // use direct database query for now
      await Supabase.instance.client
          .from('notifications')
          .update(updates)
          .eq('id', notificationId);

      return await getNotificationById(notificationId);
    } catch (e) {
      throw Exception('Failed to update notification: $e');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await adminNotificationsService.deleteNotification(notificationId);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getNotificationStatistics() async {
    try {
      final result = await adminNotificationsService.getStatistics();
      return result['data'] ?? result;
    } catch (e) {
      // Return empty statistics in case of error
      return {
        'total': 0,
        'sent': 0,
        'pending': 0,
        'failed': 0,
        'scheduled': 0,
        'by_type': <String, int>{},
      };
    }
  }

  @override
  Future<List<AdminNotificationModel>> getScheduledNotifications() async {
    try {
      // For now, return empty list since we're using notifications table
      // In the future, this will query admin_notifications table for scheduled items
      return [];
    } catch (e) {
      throw Exception('Failed to get scheduled notifications: $e');
    }
  }
}
