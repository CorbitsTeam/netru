import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/login_user_entity.dart';
import '../repositories/user_repository.dart';

class LoginUserUseCase implements UseCase<LoginUserEntity, LoginUserParams> {
  final UserRepository repository;

  LoginUserUseCase(this.repository);

  @override
  Future<Either<Failure, LoginUserEntity>> call(LoginUserParams params) async {
    return await repository.loginUser(
      params.identifier,
      params.password,
      params.userType,
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
