import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class UpdateUserProfileUseCase
    implements UseCase<UserEntity, UpdateUserProfileParams> {
  final AuthRepository repository;

  UpdateUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(
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
