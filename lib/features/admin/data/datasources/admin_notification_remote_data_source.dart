import '../../../../core/network/api_client.dart';
import '../../../../core/services/supabase_edge_functions_service.dart';
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

  AdminNotificationRemoteDataSourceImpl({
    required this.apiClient,
    required this.edgeFunctionsService,
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
      // Get notifications with user information
      var query = Supabase.instance.client.from('notifications').select('''
            id, user_id, title, title_ar, body, body_ar, 
            notification_type, reference_id, reference_type, data,
            is_read, is_sent, priority, fcm_message_id, 
            created_at, read_at, sent_at,
            users!user_id (
              id, name, full_name, email, user_type
            )
          ''');

      // Apply filters
      if (type != null && type.isNotEmpty) {
        query = query.eq('notification_type', type);
      }

      if (search != null && search.isNotEmpty) {
        query = query.or('title.ilike.%$search%,body.ilike.%$search%');
      }

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      // Apply status filter based on is_read and is_sent
      if (status != null) {
        switch (status) {
          case 'read':
            query = query.eq('is_read', true);
            break;
          case 'unread':
            query = query.eq('is_read', false);
            break;
          case 'sent':
            query = query.eq('is_sent', true);
            break;
          case 'pending':
            query = query.eq('is_sent', false);
            break;
        }
      }

      final finalQuery = query
          .order('created_at', ascending: false)
          .range((page! - 1) * limit!, page * limit - 1);

      final response = await finalQuery;

      // Convert notifications to AdminNotificationModel format
      final notifications =
          (response as List<dynamic>).map((notification) {
            // Extract user info from the joined data
            final userData = notification['users'];
            if (userData != null) {
              notification['user_name'] =
                  userData['full_name'] ??
                  userData['name'] ??
                  userData['email'];
            }

            return AdminNotificationModel.fromJson(notification);
          }).toList();

      return notifications;
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  @override
  Future<AdminNotificationModel> getNotificationById(
    String notificationId,
  ) async {
    try {
      final response =
          await Supabase.instance.client
              .from('notifications')
              .select('''
            *,
            users!notifications_user_id_fkey(first_name, last_name)
          ''')
              .eq('id', notificationId)
              .single();

      // Add user name from joined data
      final userData = response['users'];
      if (userData != null) {
        response['user_name'] =
            '${userData['first_name']} ${userData['last_name']}';
      }

      return AdminNotificationModel.fromJson(response);
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
      // For now, create a simple notification record
      // In production, this would create in admin_notifications table
      final notificationData = {
        'user_id': 'admin', // Placeholder admin user
        'title': title,
        'body': body,
        'notification_type': type,
        'data': data ?? {},
        'is_read': false,
        'is_sent': scheduledAt == null, // Send immediately if not scheduled
        'priority': 'normal',
        'created_at': DateTime.now().toIso8601String(),
      };

      final response =
          await Supabase.instance.client
              .from('notifications')
              .insert(notificationData)
              .select()
              .single();

      return AdminNotificationModel.fromJson(response);
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
      await edgeFunctionsService.sendBulkNotifications(
        userIds: userIds,
        title: title,
        body: body,
        data: data,
        type: type ?? 'general',
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
      await edgeFunctionsService.sendNotificationToGroups(
        userGroups: userGroups,
        title: title,
        body: body,
        data: data,
        type: type ?? 'general',
        governorate: governorate,
        city: city,
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
      await Supabase.instance.client
          .from('notifications')
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getNotificationStatistics() async {
    try {
      // Get all notifications for statistics
      final allNotifications = await Supabase.instance.client
          .from('notifications')
          .select('notification_type, is_sent');

      // Count totals and by status
      int total = allNotifications.length;
      int sent = 0;
      int pending = 0;
      final typeMap = <String, int>{};

      for (final item in allNotifications) {
        // Count by status
        if (item['is_sent'] == true) {
          sent++;
        } else {
          pending++;
        }

        // Count by type
        final type = item['notification_type'] as String? ?? 'general';
        typeMap[type] = (typeMap[type] ?? 0) + 1;
      }

      // If no data, return sample statistics
      if (total == 0) {
        return {
          'total': 0,
          'sent': 0,
          'pending': 0,
          'failed': 0,
          'scheduled': 0,
          'by_type': <String, int>{},
        };
      }

      return {
        'total': total,
        'sent': sent,
        'pending': pending,
        'failed': 0, // For now
        'scheduled': 0, // For now
        'by_type': typeMap,
      };
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
