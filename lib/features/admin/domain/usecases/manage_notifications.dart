import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/admin_notification_entity.dart';
import '../repositories/admin_notification_repository.dart';

class SendBulkNotification
    implements UseCase<bool, SendBulkNotificationParams> {
  final AdminNotificationRepository repository;

  SendBulkNotification(this.repository);

  @override
  Future<Either<Failure, bool>> call(SendBulkNotificationParams params) async {
    return await repository.sendBulkNotification(params.request);
  }
}

class GetAllNotifications
    implements UseCase<List<AdminNotificationEntity>, GetNotificationsParams> {
  final AdminNotificationRepository repository;

  GetAllNotifications(this.repository);

  @override
  Future<Either<Failure, List<AdminNotificationEntity>>> call(
    GetNotificationsParams params,
  ) async {
    return await repository.getAllNotifications(
      page: params.page,
      limit: params.limit,
      type: params.type,
      priority: params.priority,
      isRead: params.isRead,
      isSent: params.isSent,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class CreateNotification
    implements UseCase<AdminNotificationEntity, CreateNotificationParams> {
  final AdminNotificationRepository repository;

  CreateNotification(this.repository);

  @override
  Future<Either<Failure, AdminNotificationEntity>> call(
    CreateNotificationParams params,
  ) async {
    return await repository.createNotification(
      userId: params.userId,
      title: params.title,
      titleAr: params.titleAr,
      body: params.body,
      bodyAr: params.bodyAr,
      type: params.type,
      priority: params.priority,
      referenceId: params.referenceId,
      referenceType: params.referenceType,
      data: params.data,
    );
  }
}

class GetNotificationStats implements UseCase<Map<String, int>, NoParams> {
  final AdminNotificationRepository repository;

  GetNotificationStats(this.repository);

  @override
  Future<Either<Failure, Map<String, int>>> call(NoParams params) async {
    return await repository.getNotificationStats();
  }
}

class GetGovernoratesList implements UseCase<List<String>, NoParams> {
  final AdminNotificationRepository repository;

  GetGovernoratesList(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) async {
    return await repository.getGovernoratesList();
  }
}

class GetUserNotifications
    implements
        UseCase<List<AdminNotificationEntity>, GetUserNotificationsParams> {
  final AdminNotificationRepository repository;

  GetUserNotifications(this.repository);

  @override
  Future<Either<Failure, List<AdminNotificationEntity>>> call(
    GetUserNotificationsParams params,
  ) async {
    return await repository.getUserNotifications(
      userId: params.userId,
      page: params.page,
      limit: params.limit,
    );
  }
}

// Parameters classes
class SendBulkNotificationParams extends Equatable {
  final BulkNotificationRequest request;

  const SendBulkNotificationParams({required this.request});

  @override
  List<Object> get props => [request];
}

class GetNotificationsParams extends Equatable {
  final int? page;
  final int? limit;
  final NotificationType? type;
  final NotificationPriority? priority;
  final bool? isRead;
  final bool? isSent;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetNotificationsParams({
    this.page,
    this.limit,
    this.type,
    this.priority,
    this.isRead,
    this.isSent,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [
    page,
    limit,
    type,
    priority,
    isRead,
    isSent,
    startDate,
    endDate,
  ];
}

class CreateNotificationParams extends Equatable {
  final String userId;
  final String title;
  final String? titleAr;
  final String body;
  final String? bodyAr;
  final NotificationType type;
  final NotificationPriority priority;
  final String? referenceId;
  final ReferenceType? referenceType;
  final Map<String, dynamic>? data;

  const CreateNotificationParams({
    required this.userId,
    required this.title,
    this.titleAr,
    required this.body,
    this.bodyAr,
    required this.type,
    this.priority = NotificationPriority.normal,
    this.referenceId,
    this.referenceType,
    this.data,
  });

  @override
  List<Object?> get props => [
    userId,
    title,
    titleAr,
    body,
    bodyAr,
    type,
    priority,
    referenceId,
    referenceType,
    data,
  ];
}

class GetUserNotificationsParams extends Equatable {
  final String userId;
  final int? page;
  final int? limit;

  const GetUserNotificationsParams({
    required this.userId,
    this.page,
    this.limit,
  });

  @override
  List<Object?> get props => [userId, page, limit];
}
