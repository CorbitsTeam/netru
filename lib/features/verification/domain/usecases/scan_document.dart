import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:netru_app/core/errors/failures.dart';
import 'package:netru_app/core/usecases/usecase.dart';
import '../entities/identity_document.dart';
import '../entities/extracted_document_data.dart';
import '../repositories/verification_repository.dart';

class ScanDocumentUseCase
    implements UseCase<ExtractedDocumentData, ScanDocumentParams> {
  final VerificationRepository repository;

  ScanDocumentUseCase(this.repository);

  @override
  Future<Either<Failure, ExtractedDocumentData>> call(
    ScanDocumentParams params,
  ) async {
    return await repository.scanDocument(
      imageFile: params.imageFile,
      documentType: params.documentType,
    );
  }
}

class ScanDocumentParams extends Equatable {
  final File imageFile;
  final DocumentType documentType;

  const ScanDocumentParams({
    required this.imageFile,
    required this.documentType,
  });

  @override
  List<Object> get props => [imageFile, documentType];
}
