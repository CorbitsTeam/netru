import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginWithNationalIdUseCase {
  final AuthRepository _repository;

  LoginWithNationalIdUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(
    LoginWithNationalIdParams params,
  ) async {
    return await _repository.loginWithNationalId(
      params.nationalId,
      params.password,
    );
  }
}

class LoginWithNationalIdParams {
  final String nationalId;
  final String password;

  LoginWithNationalIdParams({required this.nationalId, required this.password});
}
