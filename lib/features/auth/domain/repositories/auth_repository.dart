import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> loginWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  });

  Future<Either<Failure, UserEntity>> signInWithGoogle();

  Future<Either<Failure, CitizenEntity>> registerCitizen({
    required String email,
    required String password,
    required String fullName,
    required String nationalId,
    required String phone,
    String? address,
  });

  Future<Either<Failure, ForeignerEntity>> registerForeigner({
    required String email,
    required String password,
    required String fullName,
    required String passportNumber,
    required String nationality,
    required String phone,
  });

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, bool>> isUserLoggedIn();
}
