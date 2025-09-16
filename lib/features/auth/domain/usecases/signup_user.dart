import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/login_user_entity.dart';
import '../repositories/user_repository.dart';

class SignUpUserUseCase {
  final UserRepository _userRepository;

  SignUpUserUseCase({required UserRepository userRepository})
    : _userRepository = userRepository;

  Future<Either<Failure, LoginUserEntity>> call(SignUpUserParams params) async {
    return await _userRepository.signUpUser(params.userData);
  }
}

class SignUpUserParams {
  final Map<String, dynamic> userData;

  SignUpUserParams({required this.userData});
}
