import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class VerifyPasswordResetTokenUseCase
    implements UseCase<bool, VerifyPasswordResetTokenParams> {
  final AuthRepository repository;

  VerifyPasswordResetTokenUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(
    VerifyPasswordResetTokenParams params,
  ) async {
    return await repository.verifyPasswordResetToken(
      params.email,
      params.token,
    );
  }
}

class VerifyPasswordResetTokenParams extends Equatable {
  final String email;
  final String token;

  const VerifyPasswordResetTokenParams({
    required this.email,
    required this.token,
  });

  @override
  List<Object> get props => [email, token];
}
