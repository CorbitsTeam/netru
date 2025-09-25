import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpUserUseCase {
  final AuthRepository _authRepository;

  SignUpUserUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  Future<Either<Failure, UserEntity>> call(SignUpUserParams params) async {
    return await _authRepository.registerUser(
      user: params.user,
      password: params.password,
      documents: params.documents,
    );
  }
}

class SignUpUserParams {
  final UserEntity user;
  final String password;
  final List<File>? documents;

  SignUpUserParams({
    required this.user,
    required this.password,
    this.documents,
  });
}
