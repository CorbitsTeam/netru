import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:netru_app/core/errors/failures.dart';
import '../../domain/entities/identity_document.dart';
import '../../domain/entities/extracted_document_data.dart';
import '../../domain/repositories/verification_repository.dart';
import '../datasources/verification_remote_data_source.dart';
import '../datasources/document_scanner_service.dart';

class VerificationRepositoryImpl implements VerificationRepository {
  final VerificationRemoteDataSource _remoteDataSource;
  final DocumentScannerService _documentScannerService;
  final Logger _logger;

  VerificationRepositoryImpl({
    required VerificationRemoteDataSource remoteDataSource,
    required DocumentScannerService documentScannerService,
    required Logger logger,
  }) : _remoteDataSource = remoteDataSource,
       _documentScannerService = documentScannerService,
       _logger = logger;

  @override
  Future<Either<Failure, ExtractedDocumentData>> scanDocument({
    required File imageFile,
    required DocumentType documentType,
  }) async {
    try {
      _logger.i('Starting document scan for ${documentType.name}');

      final extractedData = await _documentScannerService.scanDocument(
        imageFile: imageFile,
        documentType: documentType,
      );

      _logger.i('Document scan completed successfully');
      return Right(extractedData);
    } on Exception catch (e) {
      _logger.e('Document scan failed: $e');
      return Left(DocumentScanFailure(message: e.toString()));
    } catch (e) {
      _logger.e('Unexpected error during document scan: $e');
      return Left(GenericFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadDocumentImage({
    required File imageFile,
    required String userId,
    required DocumentType documentType,
  }) async {
    try {
      _logger.i('Uploading document image for user: $userId');

      final imageUrl = await _remoteDataSource.uploadDocumentImage(
        imageFile: imageFile,
        userId: userId,
        documentType: documentType,
      );

      _logger.i('Document image uploaded successfully');
      return Right(imageUrl);
    } on Exception catch (e) {
      _logger.e('Document image upload failed: $e');
      return Left(FileUploadFailure(message: e.toString()));
    } catch (e) {
      _logger.e('Unexpected error during image upload: $e');
      return Left(GenericFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, IdentityDocument>> saveIdentityDocument({
    required String userId,
    required DocumentType documentType,
    required ExtractedDocumentData extractedData,
    required String imageUrl,
  }) async {
    try {
      _logger.i('Saving identity document for user: $userId');

      final identityDocument = await _remoteDataSource.saveIdentityDocument(
        userId: userId,
        documentType: documentType,
        extractedData: extractedData,
        imageUrl: imageUrl,
      );

      _logger.i('Identity document saved successfully');
      return Right(identityDocument);
    } on Exception catch (e) {
      _logger.e('Saving identity document failed: $e');
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      _logger.e('Unexpected error while saving document: $e');
      return Left(GenericFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<IdentityDocument>>> getUserDocuments(
    String userId,
  ) async {
    try {
      _logger.i('Fetching documents for user: $userId');

      final documents = await _remoteDataSource.getUserDocuments(userId);

      _logger.i('Documents fetched successfully: ${documents.length}');
      return Right(documents);
    } on Exception catch (e) {
      _logger.e('Fetching user documents failed: $e');
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      _logger.e('Unexpected error while fetching documents: $e');
      return Left(GenericFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, IdentityDocument>> getDocumentById(
    String documentId,
  ) async {
    try {
      _logger.i('Fetching document by ID: $documentId');

      final document = await _remoteDataSource.getDocumentById(documentId);

      _logger.i('Document fetched successfully');
      return Right(document);
    } on Exception catch (e) {
      _logger.e('Fetching document by ID failed: $e');
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      _logger.e('Unexpected error while fetching document: $e');
      return Left(GenericFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, IdentityDocument>> updateDocumentStatus({
    required String documentId,
    required DocumentStatus status,
    String? rejectionReason,
  }) async {
    try {
      _logger.i('Updating document status: $documentId to ${status.name}');

      final document = await _remoteDataSource.updateDocumentStatus(
        documentId: documentId,
        status: status,
        rejectionReason: rejectionReason,
      );

      _logger.i('Document status updated successfully');
      return Right(document);
    } on Exception catch (e) {
      _logger.e('Updating document status failed: $e');
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      _logger.e('Unexpected error while updating status: $e');
      return Left(GenericFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDocument(String documentId) async {
    try {
      _logger.i('Deleting document: $documentId');

      await _remoteDataSource.deleteDocument(documentId);

      _logger.i('Document deleted successfully');
      return const Right(null);
    } on Exception catch (e) {
      _logger.e('Deleting document failed: $e');
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      _logger.e('Unexpected error while deleting document: $e');
      return Left(GenericFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasVerifiedIdentity(String userId) async {
    try {
      _logger.i('Checking verification status for user: $userId');

      final hasVerified = await _remoteDataSource.hasVerifiedIdentity(userId);

      _logger.i('Verification status checked: $hasVerified');
      return Right(hasVerified);
    } on Exception catch (e) {
      _logger.e('Checking verification status failed: $e');
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      _logger.e('Unexpected error while checking status: $e');
      return Left(GenericFailure(message: 'Unexpected error occurred'));
    }
  }
}
