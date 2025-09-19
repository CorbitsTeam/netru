import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class SendNotificationUseCase
    implements UseCase<NotificationEntity, SendNotificationParams> {
  final NotificationRepository repository;

  SendNotificationUseCase(this.repository);

  @override
  Future<Either<Failure, NotificationEntity>> call(
    SendNotificationParams params,
  ) async {
    return await repository.sendNotification(params.notification);
  }
}

class SendNotificationParams extends Equatable {
  final NotificationEntity notification;

  const SendNotificationParams({required this.notification});

  @override
  List<Object> get props => [notification];
}
