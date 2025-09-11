import 'package:equatable/equatable.dart';
import '../../domain/entities/identity_document.dart';
import '../../domain/entities/extracted_document_data.dart';

abstract class VerificationState extends Equatable {
  const VerificationState();

  @override
  List<Object?> get props => [];
}

class VerificationInitial extends VerificationState {}

class VerificationLoading extends VerificationState {}

// Scanning states
class DocumentScanInProgress extends VerificationState {}

class DocumentScanSuccess extends VerificationState {
  final ExtractedDocumentData extractedData;

  const DocumentScanSuccess(this.extractedData);

  @override
  List<Object> get props => [extractedData];
}

class DocumentScanFailure extends VerificationState {
  final String message;

  const DocumentScanFailure(this.message);

  @override
  List<Object> get props => [message];
}

// Upload states
class DocumentUploadInProgress extends VerificationState {}

class DocumentUploadSuccess extends VerificationState {
  final String imageUrl;

  const DocumentUploadSuccess(this.imageUrl);

  @override
  List<Object> get props => [imageUrl];
}

class DocumentUploadFailure extends VerificationState {
  final String message;

  const DocumentUploadFailure(this.message);

  @override
  List<Object> get props => [message];
}

// Save document states
class DocumentSaveInProgress extends VerificationState {}

class DocumentSaveSuccess extends VerificationState {
  final IdentityDocument document;

  const DocumentSaveSuccess(this.document);

  @override
  List<Object> get props => [document];
}

class DocumentSaveFailure extends VerificationState {
  final String message;

  const DocumentSaveFailure(this.message);

  @override
  List<Object> get props => [message];
}

// Get documents states
class DocumentsLoading extends VerificationState {}

class DocumentsLoaded extends VerificationState {
  final List<IdentityDocument> documents;

  const DocumentsLoaded(this.documents);

  @override
  List<Object> get props => [documents];
}

class DocumentsLoadFailure extends VerificationState {
  final String message;

  const DocumentsLoadFailure(this.message);

  @override
  List<Object> get props => [message];
}

// Verification status states
class VerificationStatusLoading extends VerificationState {}

class VerificationStatusLoaded extends VerificationState {
  final bool isVerified;

  const VerificationStatusLoaded(this.isVerified);

  @override
  List<Object> get props => [isVerified];
}

class VerificationStatusFailure extends VerificationState {
  final String message;

  const VerificationStatusFailure(this.message);

  @override
  List<Object> get props => [message];
}

// Combined scanning and saving process
class VerificationProcessInProgress extends VerificationState {
  final String currentStep;

  const VerificationProcessInProgress(this.currentStep);

  @override
  List<Object> get props => [currentStep];
}

class VerificationProcessSuccess extends VerificationState {
  final IdentityDocument document;
  final ExtractedDocumentData extractedData;

  const VerificationProcessSuccess(this.document, this.extractedData);

  @override
  List<Object> get props => [document, extractedData];
}

class VerificationProcessFailure extends VerificationState {
  final String message;
  final String step;

  const VerificationProcessFailure(this.message, this.step);

  @override
  List<Object> get props => [message, step];
}
