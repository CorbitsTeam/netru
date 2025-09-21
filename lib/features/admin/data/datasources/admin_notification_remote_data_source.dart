import '../../../../core/network/api_client.dart';
import '../../../../core/services/supabase_edge_functions_service.dart';
import '../models/admin_notification_model.dart';

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
    int? page,
    int? limit,
    String? search,
    String? type,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'select': '''
          id, title, body, type, status, target_users, target_groups,
          data, created_by, sent_count, delivered_count, failed_count,
          scheduled_at, sent_at, created_at, updated_at
        ''',
        'order': 'created_at.desc',
      };

      if (page != null && limit != null) {
        queryParams['offset'] = page * limit;
        queryParams['limit'] = limit;
      }

      if (type != null) {
        queryParams['type'] = 'eq.$type';
      }

      if (status != null) {
        queryParams['status'] = 'eq.$status';
      }

      if (search != null && search.isNotEmpty) {
        queryParams['or'] = 'title.ilike.*$search*,body.ilike.*$search*';
      }

      if (startDate != null) {
        queryParams['created_at'] = 'gte.${startDate.toIso8601String()}';
      }

      if (endDate != null) {
        if (queryParams.containsKey('created_at')) {
          queryParams['created_at'] =
              '${queryParams['created_at']}&lte.${endDate.toIso8601String()}';
        } else {
          queryParams['created_at'] = 'lte.${endDate.toIso8601String()}';
        }
      }

      final response = await apiClient.dio.get(
        '${ApiEndpoints.rest}/admin_notifications',
        queryParameters: queryParams,
      );

      return (response.data as List)
          .map((json) => AdminNotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  @override
  Future<AdminNotificationModel> getNotificationById(
    String notificationId,
  ) async {
    try {
      final response = await apiClient.dio.get(
        '${ApiEndpoints.rest}/admin_notifications',
        queryParameters: {
          'id': 'eq.$notificationId',
          'select': '''
            id, title, body, type, status, target_users, target_groups,
            data, created_by, sent_count, delivered_count, failed_count,
            scheduled_at, sent_at, created_at, updated_at
          ''',
        },
      );

      final notifications = response.data as List;
      if (notifications.isEmpty) {
        throw Exception('Notification not found');
      }

      return AdminNotificationModel.fromJson(notifications.first);
    } catch (e) {
      throw Exception('Failed to fetch notification: $e');
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
      final notificationData = {
        'title': title,
        'body': body,
        'type': type,
        'status': scheduledAt != null ? 'scheduled' : 'draft',
        'target_users': userIds,
        'target_groups': userGroups,
        'data': data,
        'scheduled_at': scheduledAt?.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await apiClient.dio.post(
        '${ApiEndpoints.rest}/admin_notifications',
        data: notificationData,
      );

      return AdminNotificationModel.fromJson(response.data.first);
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

      // Update notification record in database
      await apiClient.dio.post(
        '${ApiEndpoints.rest}/admin_notifications',
        data: {
          'title': title,
          'body': body,
          'type': type ?? 'general',
          'status': 'sent',
          'target_users': userIds,
          'sent_count': userIds.length,
          'sent_at': DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
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

      // Update notification record in database
      await apiClient.dio.post(
        '${ApiEndpoints.rest}/admin_notifications',
        data: {
          'title': title,
          'body': body,
          'type': type ?? 'general',
          'status': 'sent',
          'target_groups': userGroups,
          'data': {
            ...?data,
            if (governorate != null) 'governorate': governorate,
            if (city != null) 'city': city,
          },
          'sent_at': DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
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
      final updateData = Map<String, dynamic>.from(updates);
      updateData['updated_at'] = DateTime.now().toIso8601String();

      await apiClient.dio.patch(
        '${ApiEndpoints.rest}/admin_notifications',
        queryParameters: {'id': 'eq.$notificationId'},
        data: updateData,
      );

      return await getNotificationById(notificationId);
    } catch (e) {
      throw Exception('Failed to update notification: $e');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await apiClient.dio.delete(
        '${ApiEndpoints.rest}/admin_notifications',
        queryParameters: {'id': 'eq.$notificationId'},
      );
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getNotificationStatistics() async {
    try {
      // Get total notifications
      final totalResponse = await apiClient.dio.get(
        '${ApiEndpoints.rest}/admin_notifications',
        queryParameters: {'select': 'count()'},
      );

      // Get notifications by status
      final statusResponse = await apiClient.dio.post(
        '${ApiEndpoints.rest}/rpc/get_notifications_by_status',
      );

      // Get notifications by type
      final typeResponse = await apiClient.dio.post(
        '${ApiEndpoints.rest}/rpc/get_notifications_by_type',
      );

      // Get delivery statistics
      final deliveryResponse = await apiClient.dio.post(
        '${ApiEndpoints.rest}/rpc/get_notification_delivery_stats',
      );

      return {
        'total_notifications': totalResponse.data?.length ?? 0,
        'by_status': statusResponse.data ?? {},
        'by_type': typeResponse.data ?? {},
        'delivery_stats': deliveryResponse.data ?? {},
      };
    } catch (e) {
      throw Exception('Failed to get notification statistics: $e');
    }
  }

  @override
  Future<List<AdminNotificationModel>> getScheduledNotifications() async {
    try {
      final response = await apiClient.dio.get(
        '${ApiEndpoints.rest}/admin_notifications',
        queryParameters: {
          'status': 'eq.scheduled',
          'scheduled_at': 'gte.${DateTime.now().toIso8601String()}',
          'select': '''
            id, title, body, type, status, target_users, target_groups,
            data, created_by, sent_count, delivered_count, failed_count,
            scheduled_at, sent_at, created_at, updated_at
          ''',
          'order': 'scheduled_at.asc',
        },
      );

      return (response.data as List)
          .map((json) => AdminNotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get scheduled notifications: $e');
    }
  }
}
