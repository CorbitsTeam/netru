import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_notification_entity.dart';

abstract class AdminNotificationRepository {
  Future<Either<Failure, List<AdminNotificationEntity>>> getAllNotifications({
    int? page,
    int? limit,
    NotificationType? type,
    NotificationPriority? priority,
    bool? isRead,
    bool? isSent,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, AdminNotificationEntity>> getNotificationById(
    String notificationId,
  );

  Future<Either<Failure, bool>> sendBulkNotification(
    BulkNotificationRequest request,
  );

  Future<Either<Failure, AdminNotificationEntity>> createNotification({
    required String userId,
    required String title,
    String? titleAr,
    required String body,
    String? bodyAr,
    required NotificationType type,
    NotificationPriority priority = NotificationPriority.normal,
    String? referenceId,
    ReferenceType? referenceType,
    Map<String, dynamic>? data,
  });

  Future<Either<Failure, bool>> markNotificationAsRead(String notificationId);

  Future<Either<Failure, bool>> deleteNotification(String notificationId);

  Future<Either<Failure, Map<String, int>>> getNotificationStats();

  Future<Either<Failure, List<Map<String, dynamic>>>> getNotificationHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
  });

  Future<Either<Failure, List<String>>> getGovernoratesList();

  Future<Either<Failure, List<AdminNotificationEntity>>> getUserNotifications({
    required String userId,
    int? page,
    int? limit,
  });
}
