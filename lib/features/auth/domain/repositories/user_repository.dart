import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/login_user_entity.dart';

abstract class UserRepository {
  /// Checks if a user exists by identifier (national_id, passport_number, or email)
  Future<Either<Failure, bool>> checkUserExists(String identifier);

  /// Logs in a user using identifier and password
  Future<Either<Failure, LoginUserEntity>> loginUser(
    String identifier,
    String password,
    UserType userType,
  );
}
