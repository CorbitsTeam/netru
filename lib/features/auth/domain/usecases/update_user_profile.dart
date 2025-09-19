import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/login_user_entity.dart';
import '../repositories/user_repository.dart';

class UpdateUserProfileUseCase
    implements UseCase<LoginUserEntity, UpdateUserProfileParams> {
  final UserRepository repository;

  UpdateUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, LoginUserEntity>> call(
    UpdateUserProfileParams params,
  ) async {
    return await repository.updateUserProfile(params.userId, params.userData);
  }
}

class UpdateUserProfileParams extends Equatable {
  final String userId;
  final Map<String, dynamic> userData;

  const UpdateUserProfileParams({required this.userId, required this.userData});

  @override
  List<Object> get props => [userId, userData];
}
