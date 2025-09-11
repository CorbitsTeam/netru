import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:netru_app/core/error/failures.dart';
import 'package:netru_app/core/usecases/usecase.dart';
import '../entities/identity_document.dart';
import '../entities/extracted_document_data.dart';
import '../repositories/verification_repository.dart';

class SaveIdentityDocumentUseCase
    implements UseCase<IdentityDocument, SaveIdentityDocumentParams> {
  final VerificationRepository repository;

  SaveIdentityDocumentUseCase(this.repository);

  @override
  Future<Either<Failure, IdentityDocument>> call(
    SaveIdentityDocumentParams params,
  ) {
    // First upload the image then save the document using returned future
    return repository
        .uploadDocumentImage(
          imageFile: params.imageFile,
          userId: params.userId,
          documentType: params.documentType,
        )
        .then(
          (uploadResult) => uploadResult.fold(
            (failure) => Future.value(Left(failure)),
            (imageUrl) => repository.saveIdentityDocument(
              userId: params.userId,
              documentType: params.documentType,
              extractedData: params.extractedData,
              imageUrl: imageUrl,
            ),
          ),
        );
  }
}

class SaveIdentityDocumentParams extends Equatable {
  final String userId;
  final DocumentType documentType;
  final ExtractedDocumentData extractedData;
  final File imageFile;

  const SaveIdentityDocumentParams({
    required this.userId,
    required this.documentType,
    required this.extractedData,
    required this.imageFile,
  });

  @override
  List<Object> get props => [userId, documentType, extractedData, imageFile];
}
