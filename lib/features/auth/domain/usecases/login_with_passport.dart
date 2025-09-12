import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginWithPassportUseCase {
  final AuthRepository _repository;

  LoginWithPassportUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(
    LoginWithPassportParams params,
  ) async {
    return await _repository.loginWithPassport(
      params.passportNumber,
      params.password,
    );
  }
}

class LoginWithPassportParams {
  final String passportNumber;
  final String password;

  LoginWithPassportParams({
    required this.passportNumber,
    required this.password,
  });
}
