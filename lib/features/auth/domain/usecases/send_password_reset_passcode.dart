import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SendPasswordResetTokenUseCase
    implements UseCase<bool, SendPasswordResetTokenParams> {
  final AuthRepository repository;

  SendPasswordResetTokenUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(
    SendPasswordResetTokenParams params,
  ) async {
    return await repository.sendPasswordResetToken(params.email);
  }
}

class SendPasswordResetTokenParams extends Equatable {
  final String email;

  const SendPasswordResetTokenParams({required this.email});

  @override
  List<Object> get props => [email];
}
