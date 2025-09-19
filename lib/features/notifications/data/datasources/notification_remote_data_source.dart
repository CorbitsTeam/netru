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
      var queryBuilder = supabaseClient
          .from('notifications')
          .select()
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
    } catch (e) {
      throw Exception('خطأ في جلب الإشعارات: $e');
    }
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await supabaseClient.rpc(
        'get_unread_notifications_count',
        params: {'target_user_id': userId},
      );

      return response as int;
    } catch (e) {
      throw Exception('خطأ في جلب عدد الإشعارات غير المقروءة: $e');
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
      throw Exception('خطأ في تحديث حالة الإشعار: $e');
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
      throw Exception('خطأ في تحديث جميع الإشعارات: $e');
    }
  }

  @override
  Future<NotificationModel> createNotification(
    NotificationModel notification,
  ) async {
    try {
      final response =
          await supabaseClient
              .from('notifications')
              .insert(notification.toInsertJson())
              .select()
              .single();

      return NotificationModel.fromJson(response);
    } catch (e) {
      throw Exception('خطأ في إنشاء الإشعار: $e');
    }
  }

  @override
  Future<List<NotificationModel>> createBulkNotifications(
    List<NotificationModel> notifications,
  ) async {
    try {
      final insertData =
          notifications
              .map((notification) => notification.toInsertJson())
              .toList();

      final response =
          await supabaseClient
              .from('notifications')
              .insert(insertData)
              .select();

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
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
