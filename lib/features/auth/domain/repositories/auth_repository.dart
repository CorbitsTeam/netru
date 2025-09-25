import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> loginWithEmail(
    String email,
    String password,
  );
  Future<Either<Failure, UserEntity>> registerUser({
    required UserEntity user,
    required String password,
    required List<File> documents,
  });
  Future<Either<Failure, String>> uploadDocument(
    File documentFile,
    String fileName,
  );
  Future<Either<Failure, bool>> checkNationalIdExists(String nationalId);
  Future<Either<Failure, bool>> checkPassportExists(String passportNumber);
  Future<Either<Failure, bool>> checkEmailExistsInAuth(String email);
  Future<Either<Failure, bool>> checkPhoneExists(String phone);
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, void>> logout();
}
