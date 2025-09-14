import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/image_compression_utils.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/identity_document_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';
import '../models/identity_document_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, UserEntity>> loginWithEmail(
    String email,
    String password,
  ) async {
    try {
      final user = await _remoteDataSource.loginWithEmail(email, password);
      if (user == null) {
        return const Left(ServerFailure('المستخدم غير موجود'));
      }
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerUser({
    required UserEntity user,
    required String password,
    required List<File> documents,
  }) async {
    try {
      // Create user in database
      final userModel = UserModel.fromEntity(user);
      final createdUser = await _remoteDataSource.createUser(
        userModel,
        password,
      );

      // Upload documents
      if (documents.isNotEmpty) {
        await _uploadUserDocuments(createdUser.id!, documents, user.userType);
      }

      return Right(createdUser);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadDocument(
    File documentFile,
    String fileName,
  ) async {
    try {
      // Compress image before upload
      final compressedFile = await ImageCompressionUtils.compressImageToSize(
        documentFile,
        targetSizeKB: 1024, // 1MB max
      );

      final fileToUpload = compressedFile ?? documentFile;
      final url = await _remoteDataSource.uploadImage(fileToUpload, fileName);
      return Right(url);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkNationalIdExists(String nationalId) async {
    try {
      final exists = await _remoteDataSource.checkNationalIdExists(nationalId);
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
      final exists = await _remoteDataSource.checkPassportExists(
        passportNumber,
      );
      return Right(exists);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

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

      // Upload front document
      if (documents.isNotEmpty) {
        final frontFileName = '${userId}_${docType.name}_front.jpg';
        frontImageUrl = await _remoteDataSource.uploadImage(
          documents[0],
          frontFileName,
        );
      }

      // Upload back document for citizens (national ID has front and back)
      if (documents.length > 1 && userType == UserType.citizen) {
        final backFileName = '${userId}_${docType.name}_back.jpg';
        backImageUrl = await _remoteDataSource.uploadImage(
          documents[1],
          backFileName,
        );
      }

      // Create identity document record
      final identityDoc = IdentityDocumentModel(
        userId: userId,
        docType: docType,
        frontImageUrl: frontImageUrl,
        backImageUrl: backImageUrl,
      );

      await _remoteDataSource.createIdentityDocument(identityDoc);
    } catch (e) {
      print('خطأ في رفع المستندات: $e');
      // Don't throw here, as user is already created
      // Just log the error - user can upload documents later
    }
  }
}
