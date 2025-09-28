import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordWithTokenUseCase
    implements UseCase<bool, ResetPasswordWithTokenParams> {
  final AuthRepository repository;

  ResetPasswordWithTokenUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(
    ResetPasswordWithTokenParams params,
  ) async {
    return await repository.resetPasswordWithToken(
      params.email,
      params.token,
      params.newPassword,
    );
  }
}

class ResetPasswordWithTokenParams extends Equatable {
  final String email;
  final String token;
  final String newPassword;

  const ResetPasswordWithTokenParams({
    required this.email,
    required this.token,
    required this.newPassword,
  });

  @override
  List<Object> get props => [email, token, newPassword];
}
