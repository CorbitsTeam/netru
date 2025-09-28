import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/image_compression_utils.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/identity_document_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_data_source.dart';
import '../models/user_model.dart';
import '../models/identity_document_model.dart';

/// Auth Repository Implementation
/// يجمع كل العمليات المتعلقة بالمصادقة وإدارة المستخدمين
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource authDataSource;

  AuthRepositoryImpl({required this.authDataSource});

  // ========================
  // Authentication Methods
  // ========================

  @override
  Future<Either<Failure, UserEntity>> loginWithEmail(
    String email,
    String password,
  ) async {
    try {
      final user = await authDataSource.loginWithEmail(email, password);
      if (user != null) {
        return Right(user);
      } else {
        return const Left(
          ServerFailure('فشل تسجيل الدخول. يرجى التحقق من بياناتك.'),
        );
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithCredentials({
    required String identifier,
    required String password,
    required UserType userType,
  }) async {
    try {
      final user = await authDataSource.loginWithCredentials(
        identifier: identifier,
        password: password,
        userType: userType,
      );
      if (user != null) {
        return Right(user);
      } else {
        return const Left(
          ServerFailure('فشل تسجيل الدخول. يرجى التحقق من بياناتك.'),
        );
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await authDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ========================
  // Password Reset Methods
  // ========================

  @override
  Future<Either<Failure, bool>> sendPasswordResetToken(String email) async {
    try {
      final result = await authDataSource.sendPasswordResetToken(email);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyPasswordResetToken(
    String email,
    String token,
  ) async {
    try {
      final result = await authDataSource.verifyPasswordResetToken(
        email,
        token,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> resetPasswordWithToken(
    String email,
    String token,
    String newPassword,
  ) async {
    try {
      final result = await authDataSource.resetPasswordWithToken(
        email,
        token,
        newPassword,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ========================
  // Registration Methods
  // ========================

  @override
  Future<Either<Failure, UserEntity>> registerUser({
    required UserEntity user,
    required String password,
    List<File>? documents,
  }) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final createdUser = await authDataSource.createUser(userModel, password);

      if (documents != null && documents.isNotEmpty) {
        await _uploadUserDocuments(createdUser.id!, documents, user.userType);
      }

      return Right(createdUser);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> signUpWithEmailOnly(
    String email,
    String password,
  ) async {
    try {
      final authUserId = await authDataSource.signUpWithEmailOnly(
        email,
        password,
      );
      return Right(authUserId);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> completeUserProfile(
    UserEntity user,
    String authUserId,
  ) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final completedUser = await authDataSource.completeUserProfile(
        userModel,
        authUserId,
      );
      return Right(completedUser);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> verifyEmailAndCompleteSignup(
    UserEntity userData,
  ) async {
    try {
      final userModel = UserModel.fromEntity(userData);
      final user = await authDataSource.verifyEmailAndCompleteSignup(userModel);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> resendVerificationEmail() async {
    try {
      final success = await authDataSource.resendVerificationEmail();
      return Right(success);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ========================
  // User Retrieval Methods
  // ========================

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await authDataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getUserById(String userId) async {
    try {
      final user = await authDataSource.getUserById(userId);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getUserByEmail(String email) async {
    try {
      final user = await authDataSource.getUserByEmail(email);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getUserByNationalId(
    String nationalId,
  ) async {
    try {
      final user = await authDataSource.getUserByNationalId(nationalId);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getUserByPassport(
    String passportNumber,
  ) async {
    try {
      final user = await authDataSource.getUserByPassport(passportNumber);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUserProfile(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      final updatedUser = await authDataSource.updateUserProfile(
        userId,
        userData,
      );
      return Right(updatedUser);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ========================
  // Critical Validation Methods
  // ========================

  @override
  Future<Either<Failure, bool>> checkUserExists(String identifier) async {
    try {
      final exists = await authDataSource.checkUserExists(identifier);
      return Right(exists);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkEmailExistsInAuth(String email) async {
    try {
      final exists = await authDataSource.checkEmailExistsInAuth(email);
      return Right(exists);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkEmailExistsInUsers(String email) async {
    try {
      final exists = await authDataSource.checkEmailExistsInUsers(email);
      return Right(exists);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkNationalIdExists(String nationalId) async {
    try {
      final exists = await authDataSource.checkNationalIdExists(nationalId);
      return Right(exists);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkPassportExists(
    String passportNumber,
  ) async {
    try {
      final exists = await authDataSource.checkPassportExists(passportNumber);
      return Right(exists);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkPhoneExists(String phone) async {
    try {
      final exists = await authDataSource.checkPhoneExists(phone);
      return Right(exists);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ========================
  // Document Management
  // ========================

  @override
  Future<Either<Failure, String>> uploadDocument(
    File documentFile,
    String fileName,
  ) async {
    try {
      final compressedFile = await ImageCompressionUtils.compressImageToSize(
        documentFile,
        targetSizeKB: 1024, // 1MB max
      );
      final fileToUpload = compressedFile ?? documentFile;
      final url = await authDataSource.uploadImage(fileToUpload, fileName);
      return Right(url);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, IdentityDocumentEntity>> createIdentityDocument(
    IdentityDocumentEntity document,
  ) async {
    try {
      final documentModel = IdentityDocumentModel.fromEntity(document);
      final createdDoc = await authDataSource.createIdentityDocument(
        documentModel,
      );
      return Right(createdDoc);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ========================
  // Private Helper Methods
  // ========================

  Future<void> _uploadUserDocuments(
    String userId,
    List<File> documents,
    UserType userType,
  ) async {
    final docType =
        userType == UserType.citizen
            ? DocumentType.nationalId
            : DocumentType.passport;

    try {
      String? frontImageUrl;
      String? backImageUrl;

      if (documents.isNotEmpty) {
        final frontFileName = '${userId}_${docType.name}_front.jpg';
        frontImageUrl = await authDataSource.uploadImage(
          documents[0],
          frontFileName,
        );
      }

      if (documents.length > 1 && userType == UserType.citizen) {
        final backFileName = '${userId}_${docType.name}_back.jpg';
        backImageUrl = await authDataSource.uploadImage(
          documents[1],
          backFileName,
        );
      }

      final identityDoc = IdentityDocumentModel(
        userId: userId,
        docType: docType,
        frontImageUrl: frontImageUrl,
        backImageUrl: backImageUrl,
      );

      await authDataSource.createIdentityDocument(identityDoc);
    } catch (e) {
      print('خطأ في رفع المستندات: $e');
      // Don't throw here, as user is already created
    }
  }
}
