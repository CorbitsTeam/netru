import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/notification_entity.dart';
import '../entities/fcm_token_entity.dart';

abstract class NotificationRepository {
  /// Get notifications for a specific user
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    required String userId,
    int? limit,
    int? offset,
    bool? unreadOnly,
  });

  /// Get unread notifications count
  Future<Either<Failure, int>> getUnreadCount(String userId);

  /// Mark notification as read
  Future<Either<Failure, bool>> markAsRead(String notificationId);

  /// Mark all notifications as read for a user
  Future<Either<Failure, bool>> markAllAsRead(String userId);

  /// Send notification to a user
  Future<Either<Failure, NotificationEntity>> sendNotification(
    NotificationEntity notification,
  );

  /// Send notification to multiple users
  Future<Either<Failure, List<NotificationEntity>>> sendBulkNotifications(
    List<NotificationEntity> notifications,
  );

  /// Delete notification
  Future<Either<Failure, bool>> deleteNotification(String notificationId);

  /// Register FCM token for push notifications
  Future<Either<Failure, FcmTokenEntity>> registerFcmToken(
    FcmTokenEntity token,
  );

  /// Update FCM token
  Future<Either<Failure, FcmTokenEntity>> updateFcmToken(FcmTokenEntity token);

  /// Get user FCM tokens
  Future<Either<Failure, List<FcmTokenEntity>>> getUserFcmTokens(String userId);

  /// Deactivate FCM token
  Future<Either<Failure, bool>> deactivateFcmToken(String tokenId);

  /// Send push notification via Firebase
  Future<Either<Failure, bool>> sendPushNotification({
    required List<String> fcmTokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  });

  /// Subscribe to notifications real-time updates
  Stream<List<NotificationEntity>> subscribeToNotifications(String userId);
}
