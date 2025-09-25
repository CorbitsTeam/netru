import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../entities/identity_document_entity.dart';

/// Unified Auth Repository Interface
/// يجمع كل العمليات المتعلقة بالمصادقة وإدارة المستخدمين
abstract class AuthRepository {
  // ========================
  // Authentication Methods
  // ========================
  Future<Either<Failure, UserEntity>> loginWithEmail(
    String email,
    String password,
  );

  Future<Either<Failure, UserEntity>> loginWithCredentials({
    required String identifier,
    required String password,
    required UserType userType,
  });

  Future<Either<Failure, void>> logout();

  // ========================
  // Registration Methods
  // ========================
  Future<Either<Failure, UserEntity>> registerUser({
    required UserEntity user,
    required String password,
    List<File>? documents,
  });

  Future<Either<Failure, String>> signUpWithEmailOnly(
    String email,
    String password,
  );

  Future<Either<Failure, UserEntity>> completeUserProfile(
    UserEntity user,
    String authUserId,
  );

  // ========================
  // Email Verification
  // ========================
  Future<Either<Failure, UserEntity?>> verifyEmailAndCompleteSignup(
    UserEntity userData,
  );

  Future<Either<Failure, bool>> resendVerificationEmail();

  // ========================
  // User Retrieval Methods
  // ========================
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Future<Either<Failure, UserEntity?>> getUserById(String userId);

  Future<Either<Failure, UserEntity?>> getUserByEmail(String email);

  Future<Either<Failure, UserEntity?>> getUserByNationalId(String nationalId);

  Future<Either<Failure, UserEntity?>> getUserByPassport(String passportNumber);

  // ========================
  // User Update Methods
  // ========================
  Future<Either<Failure, UserEntity>> updateUserProfile(
    String userId,
    Map<String, dynamic> userData,
  );

  // ========================
  // Critical Validation Methods
  // ========================
  /// التحقق العام من وجود المستخدم
  Future<Either<Failure, bool>> checkUserExists(String identifier);

  /// التحقق من وجود الإيميل في نظام المصادقة
  Future<Either<Failure, bool>> checkEmailExistsInAuth(String email);

  /// التحقق من وجود الإيميل في جدول المستخدمين
  Future<Either<Failure, bool>> checkEmailExistsInUsers(String email);

  /// التحقق من وجود الرقم القومي
  Future<Either<Failure, bool>> checkNationalIdExists(String nationalId);

  /// التحقق من وجود رقم جواز السفر
  Future<Either<Failure, bool>> checkPassportExists(String passportNumber);

  /// التحقق من وجود رقم التليفون
  Future<Either<Failure, bool>> checkPhoneExists(String phone);

  // ========================
  // Document Management
  // ========================
  Future<Either<Failure, String>> uploadDocument(
    File documentFile,
    String fileName,
  );

  Future<Either<Failure, IdentityDocumentEntity>> createIdentityDocument(
    IdentityDocumentEntity document,
  );
}
