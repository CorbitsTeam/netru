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

  /// Signs up a new user
  Future<Either<Failure, LoginUserEntity>> signUpUser(
    Map<String, dynamic> userData,
  );

  /// Get user data by ID
  Future<Either<Failure, LoginUserEntity>> getUserById(String userId);

  /// Get user data by email
  Future<Either<Failure, LoginUserEntity>> getUserByEmail(String email);

  /// Get user data by national ID
  Future<Either<Failure, LoginUserEntity>> getUserByNationalId(
    String nationalId,
  );

  /// Get user data by passport number
  Future<Either<Failure, LoginUserEntity>> getUserByPassport(
    String passportNumber,
  );

  /// Update user profile
  Future<Either<Failure, LoginUserEntity>> updateUserProfile(
    String userId,
    Map<String, dynamic> userData,
  );
}
