import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/fcm_token_entity.dart';
import '../repositories/notification_repository.dart';

class RegisterFcmTokenUseCase
    implements UseCase<FcmTokenEntity, RegisterFcmTokenParams> {
  final NotificationRepository repository;

  RegisterFcmTokenUseCase(this.repository);

  @override
  Future<Either<Failure, FcmTokenEntity>> call(
    RegisterFcmTokenParams params,
  ) async {
    return await repository.registerFcmToken(params.token);
  }
}

class RegisterFcmTokenParams extends Equatable {
  final FcmTokenEntity token;

  const RegisterFcmTokenParams({required this.token});

  @override
  List<Object> get props => [token];
}
