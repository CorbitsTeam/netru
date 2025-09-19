import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/fcm_token_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';
import '../datasources/firebase_notification_service.dart';
import '../models/notification_model.dart';
import '../models/fcm_token_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final FirebaseNotificationService firebaseService;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.firebaseService,
  });

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    required String userId,
    int? limit,
    int? offset,
    bool? unreadOnly,
  }) async {
    try {
      final notifications = await remoteDataSource.getNotifications(
        userId: userId,
        limit: limit,
        offset: offset,
        unreadOnly: unreadOnly,
      );
      return Right(notifications);
    } catch (e) {
      return Left(ServerFailure('خطأ في جلب الإشعارات: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount(String userId) async {
    try {
      final count = await remoteDataSource.getUnreadCount(userId);
      return Right(count);
    } catch (e) {
      return Left(ServerFailure('خطأ في جلب عدد الإشعارات غير المقروءة: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> markAsRead(String notificationId) async {
    try {
      final result = await remoteDataSource.markAsRead(notificationId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('خطأ في تحديث حالة الإشعار: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> markAllAsRead(String userId) async {
    try {
      final result = await remoteDataSource.markAllAsRead(userId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('خطأ في تحديث جميع الإشعارات: $e'));
    }
  }

  @override
  Future<Either<Failure, NotificationEntity>> sendNotification(
    NotificationEntity notification,
  ) async {
    try {
      final notificationModel = NotificationModel.fromEntity(notification);
      final createdNotification = await remoteDataSource.createNotification(
        notificationModel,
      );

      // Get user FCM tokens and send push notification
      final fcmTokens = await remoteDataSource.getUserFcmTokens(
        notification.userId,
      );

      if (fcmTokens.isNotEmpty) {
        final tokenStrings = fcmTokens.map((token) => token.fcmToken).toList();
        await firebaseService.sendPushNotification(
          fcmTokens: tokenStrings,
          title: notification.getLocalizedTitle(),
          body: notification.getLocalizedBody(),
          data: notification.data,
        );
      }

      return Right(createdNotification);
    } catch (e) {
      return Left(ServerFailure('خطأ في إرسال الإشعار: $e'));
    }
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> sendBulkNotifications(
    List<NotificationEntity> notifications,
  ) async {
    try {
      final notificationModels =
          notifications
              .map((notification) => NotificationModel.fromEntity(notification))
              .toList();

      final createdNotifications = await remoteDataSource
          .createBulkNotifications(notificationModels);

      // Group notifications by user and send push notifications
      final userNotifications = <String, List<NotificationModel>>{};
      for (final notification in createdNotifications) {
        userNotifications[notification.userId] ??= [];
        userNotifications[notification.userId]!.add(notification);
      }

      for (final entry in userNotifications.entries) {
        final userId = entry.key;
        final userNotifs = entry.value;

        // Get user FCM tokens
        final fcmTokens = await remoteDataSource.getUserFcmTokens(userId);

        if (fcmTokens.isNotEmpty) {
          final tokenStrings =
              fcmTokens.map((token) => token.fcmToken).toList();

          // Send notification for each notification (could be optimized to batch)
          for (final notification in userNotifs) {
            await firebaseService.sendPushNotification(
              fcmTokens: tokenStrings,
              title: notification.getLocalizedTitle(),
              body: notification.getLocalizedBody(),
              data: notification.data,
            );
          }
        }
      }

      return Right(createdNotifications);
    } catch (e) {
      return Left(ServerFailure('خطأ في إرسال الإشعارات المتعددة: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteNotification(
    String notificationId,
  ) async {
    try {
      final result = await remoteDataSource.deleteNotification(notificationId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('خطأ في حذف الإشعار: $e'));
    }
  }

  @override
  Future<Either<Failure, FcmTokenEntity>> registerFcmToken(
    FcmTokenEntity token,
  ) async {
    try {
      final tokenModel = FcmTokenModel.fromEntity(token);
      final registeredToken = await remoteDataSource.registerFcmToken(
        tokenModel,
      );
      return Right(registeredToken);
    } catch (e) {
      return Left(ServerFailure('خطأ في تسجيل رمز FCM: $e'));
    }
  }

  @override
  Future<Either<Failure, FcmTokenEntity>> updateFcmToken(
    FcmTokenEntity token,
  ) async {
    try {
      final tokenModel = FcmTokenModel.fromEntity(token);
      final updatedToken = await remoteDataSource.updateFcmToken(tokenModel);
      return Right(updatedToken);
    } catch (e) {
      return Left(ServerFailure('خطأ في تحديث رمز FCM: $e'));
    }
  }

  @override
  Future<Either<Failure, List<FcmTokenEntity>>> getUserFcmTokens(
    String userId,
  ) async {
    try {
      final tokens = await remoteDataSource.getUserFcmTokens(userId);
      return Right(tokens);
    } catch (e) {
      return Left(ServerFailure('خطأ في جلب رموز FCM: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deactivateFcmToken(String tokenId) async {
    try {
      final result = await remoteDataSource.deactivateFcmToken(tokenId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('خطأ في إلغاء تفعيل رمز FCM: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> sendPushNotification({
    required List<String> fcmTokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final result = await firebaseService.sendPushNotification(
        fcmTokens: fcmTokens,
        title: title,
        body: body,
        data: data,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('خطأ في إرسال الإشعار المباشر: $e'));
    }
  }

  @override
  Stream<List<NotificationEntity>> subscribeToNotifications(String userId) {
    return remoteDataSource
        .subscribeToNotifications(userId)
        .map((notifications) => notifications.cast<NotificationEntity>());
  }
}
