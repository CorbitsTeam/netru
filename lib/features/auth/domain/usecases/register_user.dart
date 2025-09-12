import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUserUseCase {
  final AuthRepository _repository;

  RegisterUserUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(RegisterUserParams params) async {
    return await _repository.registerUser(
      user: params.user,
      password: params.password,
      documents: params.documents,
    );
  }
}

class RegisterUserParams {
  final UserEntity user;
  final String password;
  final List<File> documents;

  RegisterUserParams({
    required this.user,
    required this.password,
    required this.documents,
  });
}
