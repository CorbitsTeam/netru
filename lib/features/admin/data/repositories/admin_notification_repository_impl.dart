import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/admin_notification_entity.dart';
import '../../domain/repositories/admin_notification_repository.dart';
import '../datasources/admin_notification_remote_data_source.dart';

class AdminNotificationRepositoryImpl implements AdminNotificationRepository {
  final AdminNotificationRemoteDataSource remoteDataSource;

  AdminNotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AdminNotificationEntity>>> getAllNotifications({
    int? page,
    int? limit,
    NotificationType? type,
    NotificationPriority? priority,
    bool? isRead,
    bool? isSent,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final notifications = await remoteDataSource.getAllNotifications(
        page: page,
        limit: limit,
        type: type?.value,
        status: _getStatusFilter(isRead, isSent),
        startDate: startDate,
        endDate: endDate,
      );

      return Right(notifications);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminNotificationEntity>> getNotificationById(
    String notificationId,
  ) async {
    try {
      final notification = await remoteDataSource.getNotificationById(
        notificationId,
      );
      return Right(notification);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> sendBulkNotification(
    BulkNotificationRequest request,
  ) async {
    try {
      switch (request.targetType) {
        case TargetType.all:
          await _sendToAllUsers(request);
          break;
        case TargetType.governorate:
          await _sendToGovernorate(request);
          break;
        case TargetType.userType:
          await _sendToUserType(request);
          break;
        case TargetType.specificUsers:
          await _sendToSpecificUsers(request);
          break;
      }
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final notification = await remoteDataSource.createNotification(
        title: title,
        body: body,
        type: type.value,
        userIds: [userId],
        data: data,
      );

      return Right(notification);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> markNotificationAsRead(
    String notificationId,
  ) async {
    try {
      await remoteDataSource.updateNotification(notificationId, {
        'is_read': true,
        'read_at': DateTime.now().toIso8601String(),
      });
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteNotification(
    String notificationId,
  ) async {
    try {
      await remoteDataSource.deleteNotification(notificationId);
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getNotificationStats() async {
    try {
      final stats = await remoteDataSource.getNotificationStatistics();
      return Right(Map<String, int>.from(stats));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getNotificationHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
  }) async {
    try {
      final history = await remoteDataSource.getAllNotifications(
        startDate: startDate,
        endDate: endDate,
      );

      return Right(
        history.map((notification) => notification.toJson()).toList(),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getGovernoratesList() async {
    try {
      // This should be implemented in the data source to fetch from governorates table
      const governorates = [
        'القاهرة',
        'الجيزة',
        'الإسكندرية',
        'الدقهلية',
        'الشرقية',
        'القليوبية',
        'كفر الشيخ',
        'الغربية',
        'المنوفية',
        'البحيرة',
        'الإسماعيلية',
        'بورسعيد',
        'السويس',
        'شمال سيناء',
        'جنوب سيناء',
        'البحر الأحمر',
        'الوادي الجديد',
        'مطروح',
        'أسوان',
        'الأقصر',
        'قنا',
        'سوهاج',
        'أسيوط',
        'المنيا',
        'بني سويف',
        'الفيوم',
      ];

      return const Right(governorates);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AdminNotificationEntity>>> getUserNotifications({
    required String userId,
    int? page,
    int? limit,
  }) async {
    try {
      final notifications = await remoteDataSource.getAllNotifications(
        page: page,
        limit: limit,
        // Filter by user ID would need to be implemented in the data source
      );

      return Right(notifications);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Helper methods for different target types
  Future<void> _sendToAllUsers(BulkNotificationRequest request) async {
    await remoteDataSource.sendNotificationToGroups(
      userGroups: ['all'],
      title: request.title,
      body: request.body,
      data: request.data,
      type: request.notificationType.value,
    );
  }

  Future<void> _sendToGovernorate(BulkNotificationRequest request) async {
    await remoteDataSource.sendNotificationToGroups(
      userGroups: ['governorate'],
      title: request.title,
      body: request.body,
      data: request.data,
      type: request.notificationType.value,
      governorate: request.targetValue.toString(),
    );
  }

  Future<void> _sendToUserType(BulkNotificationRequest request) async {
    await remoteDataSource.sendNotificationToGroups(
      userGroups: [request.targetValue.toString()],
      title: request.title,
      body: request.body,
      data: request.data,
      type: request.notificationType.value,
    );
  }

  Future<void> _sendToSpecificUsers(BulkNotificationRequest request) async {
    List<String> userIds = [];

    if (request.targetValue is List) {
      userIds = List<String>.from(request.targetValue);
    } else if (request.targetValue is String) {
      userIds = [request.targetValue];
    }

    await remoteDataSource.sendBulkNotifications(
      userIds: userIds,
      title: request.title,
      body: request.body,
      data: request.data,
      type: request.notificationType.value,
    );
  }

  String? _getStatusFilter(bool? isRead, bool? isSent) {
    if (isRead == true) return 'read';
    if (isRead == false) return 'unread';
    if (isSent == true) return 'sent';
    if (isSent == false) return 'pending';
    return null;
  }
}
