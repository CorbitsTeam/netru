import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/login_user_entity.dart';
import '../repositories/user_repository.dart';

class GetUserByIdUseCase extends UseCase<LoginUserEntity, GetUserByIdParams> {
  final UserRepository repository;

  GetUserByIdUseCase(this.repository);

  @override
  Future<Either<Failure, LoginUserEntity>> call(
    GetUserByIdParams params,
  ) async {
    return await repository.getUserById(params.userId);
  }
}

class GetUserByIdParams {
  final String userId;

  GetUserByIdParams({required this.userId});
}
