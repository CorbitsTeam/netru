import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase
    implements UseCase<List<NotificationEntity>, GetNotificationsParams> {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<NotificationEntity>>> call(
    GetNotificationsParams params,
  ) async {
    return await repository.getNotifications(
      userId: params.userId,
      limit: params.limit,
      offset: params.offset,
      unreadOnly: params.unreadOnly,
    );
  }
}

class GetNotificationsParams extends Equatable {
  final String userId;
  final int? limit;
  final int? offset;
  final bool? unreadOnly;

  const GetNotificationsParams({
    required this.userId,
    this.limit,
    this.offset,
    this.unreadOnly,
  });

  @override
  List<Object?> get props => [userId, limit, offset, unreadOnly];
}
