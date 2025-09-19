import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

class GetUnreadNotificationsCountUseCase
    implements UseCase<int, GetUnreadNotificationsCountParams> {
  final NotificationRepository repository;

  GetUnreadNotificationsCountUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(
    GetUnreadNotificationsCountParams params,
  ) async {
    return await repository.getUnreadCount(params.userId);
  }
}

class GetUnreadNotificationsCountParams extends Equatable {
  final String userId;

  const GetUnreadNotificationsCountParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
