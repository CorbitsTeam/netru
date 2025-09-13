import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginWithEmailUseCase
    implements UseCase<UserEntity, LoginWithEmailParams> {
  final AuthRepository repository;

  LoginWithEmailUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginWithEmailParams params) async {
    return await repository.loginWithEmail(params.email, params.password);
  }
}

class LoginWithEmailParams extends Equatable {
  final String email;
  final String password;

  const LoginWithEmailParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}
