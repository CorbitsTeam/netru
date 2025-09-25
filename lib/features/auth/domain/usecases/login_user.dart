import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUserUseCase implements UseCase<UserEntity, LoginUserParams> {
  final AuthRepository repository;

  LoginUserUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginUserParams params) async {
    return await repository.loginWithCredentials(
      identifier: params.identifier,
      password: params.password,
      userType: params.userType,
    );
  }
}

class LoginUserParams extends Equatable {
  final String identifier;
  final String password;
  final UserType userType;

  const LoginUserParams({
    required this.identifier,
    required this.password,
    required this.userType,
  });

  @override
  List<Object> get props => [identifier, password, userType];
}
