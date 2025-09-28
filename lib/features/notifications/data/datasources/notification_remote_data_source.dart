import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import '../models/fcm_token_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({
    required String userId,
    int? limit,
    int? offset,
    bool? unreadOnly,
  });

  Future<int> getUnreadCount(String userId);

  Future<bool> markAsRead(String notificationId);

  Future<bool> markAllAsRead(String userId);

  Future<NotificationModel> createNotification(NotificationModel notification);

  Future<List<NotificationModel>> createBulkNotifications(
    List<NotificationModel> notifications,
  );

  Future<bool> deleteNotification(String notificationId);

  Future<FcmTokenModel> registerFcmToken(FcmTokenModel token);

  Future<FcmTokenModel> updateFcmToken(FcmTokenModel token);

  Future<List<FcmTokenModel>> getUserFcmTokens(String userId);

  Future<bool> deactivateFcmToken(String tokenId);

  Stream<List<NotificationModel>> subscribeToNotifications(String userId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final SupabaseClient supabaseClient;

  NotificationRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<NotificationModel>> getNotifications({
    required String userId,
    int? limit,
    int? offset,
    bool? unreadOnly,
  }) async {
    try {
      // Try RLS bypass function first
      try {
        final response = await supabaseClient.rpc(
          'get_user_notifications_with_bypass',
          params: {
            'target_user_id': userId,
            'page_limit': limit ?? 20,
            'page_offset': offset ?? 0,
            'unread_only': unreadOnly ?? false,
          },
        );

        return (response as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      } catch (bypassError) {
        print('RLS bypass function failed for get notifications: $bypassError');
      }

      // Try standard RLS function
      try {
        final response = await supabaseClient.rpc(
          'get_user_notifications',
          params: {
            'target_user_id': userId,
            'page_limit': limit ?? 20,
            'page_offset': offset ?? 0,
            'unread_only': unreadOnly ?? false,
          },
        );

        return (response as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      } catch (rpcError) {
        // Fallback to direct query with better error handling
        var queryBuilder = supabaseClient
            .from('notifications')
            .select('*')
            .eq('user_id', userId);

        if (unreadOnly == true) {
          queryBuilder = queryBuilder.eq('is_read', false);
        }

        var query = queryBuilder.order('created_at', ascending: false);

        if (limit != null) {
          query = query.limit(limit);
        }

        if (offset != null) {
          query = query.range(offset, offset + (limit ?? 20) - 1);
        }

        final response = await query;

        return (response as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      // Return empty list instead of throwing exception for better UX
      print('خطأ في جلب الإشعارات: $e');
      return [];
    }
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    try {
      // Try RLS bypass function first
      try {
        final response = await supabaseClient.rpc(
          'get_unread_notifications_count_with_bypass',
          params: {'target_user_id': userId},
        );

        return response as int;
      } catch (bypassError) {
        print('RLS bypass function failed for unread count: $bypassError');
      }

      // Try standard function
      final response = await supabaseClient.rpc(
        'get_unread_notifications_count',
        params: {'target_user_id': userId},
      );

      return response as int;
    } catch (e) {
      // Fallback to direct query if function doesn't exist
      try {
        final response = await supabaseClient
            .from('notifications')
            .select()
            .eq('user_id', userId)
            .eq('is_read', false);

        return (response as List).length;
      } catch (fallbackError) {
        throw Exception(
          'خطأ في جلب عدد الإشعارات غير المقروءة: $fallbackError',
        );
      }
    }
  }

  @override
  Future<bool> markAsRead(String notificationId) async {
    try {
      await supabaseClient.rpc(
        'mark_notification_read',
        params: {'notification_id': notificationId},
      );

      return true;
    } catch (e) {
      // Fallback to direct update if function doesn't exist
      try {
        await supabaseClient
            .from('notifications')
            .update({
              'is_read': true,
              'read_at': DateTime.now().toIso8601String(),
            })
            .eq('id', notificationId);

        return true;
      } catch (fallbackError) {
        throw Exception('خطأ في تحديث حالة الإشعار: $fallbackError');
      }
    }
  }

  @override
  Future<bool> markAllAsRead(String userId) async {
    try {
      await supabaseClient.rpc(
        'mark_all_notifications_read',
        params: {'target_user_id': userId},
      );

      return true;
    } catch (e) {
      // Fallback to direct update if function doesn't exist
      try {
        await supabaseClient
            .from('notifications')
            .update({
              'is_read': true,
              'read_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('is_read', false);

        return true;
      } catch (fallbackError) {
        throw Exception('خطأ في تحديث جميع الإشعارات: $fallbackError');
      }
    }
  }

  @override
  Future<NotificationModel> createNotification(
    NotificationModel notification,
  ) async {
    try {
      // Try RLS bypass function first
      try {
        final response = await supabaseClient.rpc(
          'create_notification_bypass_rls',
          params: {
            'p_user_id': notification.userId,
            'p_title': notification.title,
            'p_title_ar': notification.titleAr,
            'p_body': notification.body,
            'p_body_ar': notification.bodyAr,
            'p_type': notification.type.toString().split('.').last,
            'p_reference_id': notification.referenceId,
            'p_reference_type':
                notification.referenceType?.toString().split('.').last,
            'p_priority': notification.priority.toString().split('.').last,
            'p_data': notification.data,
          },
        );

        if (response is Map<String, dynamic>) {
          return NotificationModel.fromJson(response);
        }
      } catch (bypassError) {
        print('RLS bypass function failed: $bypassError');
      }

      // Try standard RPC function
      try {
        final response = await supabaseClient.rpc(
          'create_notification',
          params: notification.toInsertJson(),
        );

        if (response is Map<String, dynamic>) {
          return NotificationModel.fromJson(response);
        } else if (response is List && response.isNotEmpty) {
          return NotificationModel.fromJson(response.first);
        }
      } catch (rpcError) {
        print('Standard RPC failed: $rpcError');
      }

      // Try alternative RPC function
      try {
        final response = await supabaseClient.rpc(
          'insert_user_notification',
          params: {
            'p_user_id': notification.userId,
            'p_title': notification.title,
            'p_title_ar': notification.titleAr,
            'p_body': notification.body,
            'p_body_ar': notification.bodyAr,
            'p_type': notification.type.toString().split('.').last,
            'p_reference_id': notification.referenceId,
            'p_reference_type':
                notification.referenceType?.toString().split('.').last,
            'p_priority': notification.priority.toString().split('.').last,
            'p_data': notification.data,
          },
        );

        if (response is Map<String, dynamic>) {
          return NotificationModel.fromJson(response);
        } else if (response is List && response.isNotEmpty) {
          return NotificationModel.fromJson(response.first);
        }
      } catch (rpcError2) {
        print('Alternative RPC failed, trying direct insert: $rpcError2');
      }

      // Fallback to direct insert with better error handling
      final response =
          await supabaseClient
              .from('notifications')
              .insert(notification.toInsertJson())
              .select()
              .single();

      return NotificationModel.fromJson(response);
    } catch (e) {
      print('خطأ في إنشاء الإشعار: $e');

      // If it's an RLS error, try to create a simplified notification
      if (e.toString().contains('42501') ||
          e.toString().contains('row-level security')) {
        print(
          'RLS policy blocking insert, creating simplified notification...',
        );
        try {
          // Create a minimal notification record
          final simpleData = {
            'user_id': notification.userId,
            'title': notification.title,
            'body': notification.body,
            'notification_type': notification.type.toString().split('.').last,
          };

          final response =
              await supabaseClient
                  .from('notifications')
                  .insert(simpleData)
                  .select()
                  .single();

          return NotificationModel.fromJson(response);
        } catch (simplifiedError) {
          print('Even simplified insert failed: $simplifiedError');
        }
      }

      throw Exception('خطأ في إنشاء الإشعار: $e');
    }
  }

  @override
  Future<List<NotificationModel>> createBulkNotifications(
    List<NotificationModel> notifications,
  ) async {
    try {
      // Try RLS bypass function for bulk insert first
      try {
        final insertData =
            notifications
                .map((notification) => notification.toInsertJson())
                .toList();
        final response = await supabaseClient.rpc(
          'create_bulk_notifications_bypass_rls',
          params: {'notifications_data': insertData},
        );

        if (response is List) {
          return response
              .map((json) => NotificationModel.fromJson(json))
              .toList();
        }
      } catch (bypassError) {
        print('Bulk RLS bypass failed: $bypassError');
      }

      // Try standard RPC function for bulk insert
      try {
        final insertData =
            notifications
                .map((notification) => notification.toInsertJson())
                .toList();
        final response = await supabaseClient.rpc(
          'create_bulk_notifications',
          params: {'notifications_data': insertData},
        );

        if (response is List) {
          return response
              .map((json) => NotificationModel.fromJson(json))
              .toList();
        }
      } catch (rpcError) {
        print('Bulk RPC failed, using individual inserts: $rpcError');
      }

      // Fallback to individual inserts
      final createdNotifications = <NotificationModel>[];

      for (final notification in notifications) {
        try {
          final created = await createNotification(notification);
          createdNotifications.add(created);
        } catch (e) {
          print(
            'Failed to create individual notification: ${notification.title} - $e',
          );
          // Continue with other notifications
        }
      }

      if (createdNotifications.isEmpty) {
        throw Exception('Failed to create any notifications');
      }

      return createdNotifications;
    } catch (e) {
      print('خطأ في إنشاء الإشعارات المتعددة: $e');
      throw Exception('خطأ في إنشاء الإشعارات المتعددة: $e');
    }
  }

  @override
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await supabaseClient
          .from('notifications')
          .delete()
          .eq('id', notificationId);

      return true;
    } catch (e) {
      throw Exception('خطأ في حذف الإشعار: $e');
    }
  }

  @override
  Future<FcmTokenModel> registerFcmToken(FcmTokenModel token) async {
    try {
      final response =
          await supabaseClient
              .from('user_fcm_tokens')
              .upsert(token.toInsertJson())
              .select()
              .single();

      return FcmTokenModel.fromJson(response);
    } catch (e) {
      throw Exception('خطأ في تسجيل رمز FCM: $e');
    }
  }

  @override
  Future<FcmTokenModel> updateFcmToken(FcmTokenModel token) async {
    try {
      final response =
          await supabaseClient
              .from('user_fcm_tokens')
              .update({
                'last_used': DateTime.now().toIso8601String(),
                'is_active': token.isActive,
                'app_version': token.appVersion,
              })
              .eq('id', token.id)
              .select()
              .single();

      return FcmTokenModel.fromJson(response);
    } catch (e) {
      throw Exception('خطأ في تحديث رمز FCM: $e');
    }
  }

  @override
  Future<List<FcmTokenModel>> getUserFcmTokens(String userId) async {
    try {
      final response = await supabaseClient
          .from('user_fcm_tokens')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true);

      return (response as List)
          .map((json) => FcmTokenModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('خطأ في جلب رموز FCM: $e');
    }
  }

  @override
  Future<bool> deactivateFcmToken(String tokenId) async {
    try {
      await supabaseClient
          .from('user_fcm_tokens')
          .update({'is_active': false})
          .eq('id', tokenId);

      return true;
    } catch (e) {
      throw Exception('خطأ في إلغاء تفعيل رمز FCM: $e');
    }
  }

  @override
  Stream<List<NotificationModel>> subscribeToNotifications(String userId) {
    return supabaseClient
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map(
          (data) =>
              data.map((json) => NotificationModel.fromJson(json)).toList(),
        );
  }
}
