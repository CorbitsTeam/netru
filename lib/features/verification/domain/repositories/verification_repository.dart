import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:netru_app/core/error/failures.dart';
import '../entities/identity_document.dart';
import '../entities/extracted_document_data.dart';

abstract class VerificationRepository {
  /// Scan and extract data from document image
  Future<Either<Failure, ExtractedDocumentData>> scanDocument({
    required File imageFile,
    required DocumentType documentType,
  });

  /// Upload document image to storage
  Future<Either<Failure, String>> uploadDocumentImage({
    required File imageFile,
    required String userId,
    required DocumentType documentType,
  });

  /// Save identity document to database
  Future<Either<Failure, IdentityDocument>> saveIdentityDocument({
    required String userId,
    required DocumentType documentType,
    required ExtractedDocumentData extractedData,
    required String imageUrl,
  });

  /// Get user's identity documents
  Future<Either<Failure, List<IdentityDocument>>> getUserDocuments(
    String userId,
  );

  /// Get specific identity document
  Future<Either<Failure, IdentityDocument>> getDocumentById(String documentId);

  /// Update document status (for admin/verification process)
  Future<Either<Failure, IdentityDocument>> updateDocumentStatus({
    required String documentId,
    required DocumentStatus status,
    String? rejectionReason,
  });

  /// Delete identity document
  Future<Either<Failure, void>> deleteDocument(String documentId);

  /// Check if user has verified identity
  Future<Either<Failure, bool>> hasVerifiedIdentity(String userId);
}
