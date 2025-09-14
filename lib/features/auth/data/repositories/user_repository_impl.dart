import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/login_user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDataSource _userDataSource;

  UserRepositoryImpl({required UserDataSource userDataSource})
    : _userDataSource = userDataSource;

  @override
  Future<Either<Failure, bool>> checkUserExists(String identifier) async {
    try {
      final exists = await _userDataSource.checkUserExists(identifier);
      return Right(exists);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LoginUserEntity>> loginUser(
    String identifier,
    String password,
    UserType userType,
  ) async {
    try {
      final user = await _userDataSource.loginUser(
        identifier,
        password,
        userType,
      );
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
