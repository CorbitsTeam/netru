import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/identity_document.dart';
import '../../domain/usecases/scan_document.dart';
import '../../domain/usecases/save_identity_document.dart';
import '../../domain/usecases/get_user_documents.dart';
import '../../domain/usecases/check_verification_status.dart';
import 'verification_state.dart';

class VerificationCubit extends Cubit<VerificationState> {
  final ScanDocumentUseCase _scanDocumentUseCase;
  final SaveIdentityDocumentUseCase _saveIdentityDocumentUseCase;
  final GetUserDocumentsUseCase _getUserDocumentsUseCase;
  final CheckVerificationStatusUseCase _checkVerificationStatusUseCase;
  final Logger _logger;

  VerificationCubit({
    required ScanDocumentUseCase scanDocumentUseCase,
    required SaveIdentityDocumentUseCase saveIdentityDocumentUseCase,
    required GetUserDocumentsUseCase getUserDocumentsUseCase,
    required CheckVerificationStatusUseCase checkVerificationStatusUseCase,
    required Logger logger,
  }) : _scanDocumentUseCase = scanDocumentUseCase,
       _saveIdentityDocumentUseCase = saveIdentityDocumentUseCase,
       _getUserDocumentsUseCase = getUserDocumentsUseCase,
       _checkVerificationStatusUseCase = checkVerificationStatusUseCase,
       _logger = logger,
       super(VerificationInitial());

  /// Scan document and extract data
  Future<void> scanDocument({
    required File imageFile,
    required DocumentType documentType,
  }) async {
    try {
      emit(DocumentScanInProgress());
      _logger.i('Starting document scan for ${documentType.name}');

      final result = await _scanDocumentUseCase(
        ScanDocumentParams(imageFile: imageFile, documentType: documentType),
      );

      result.fold(
        (failure) {
          _logger.e('Document scan failed: ${failure.message}');
          emit(DocumentScanFailure(failure.message));
        },
        (extractedData) {
          _logger.i(
            'Document scan completed successfully with confidence: ${extractedData.confidence}',
          );
          emit(DocumentScanSuccess(extractedData));
        },
      );
    } catch (e) {
      _logger.e('Unexpected error during document scan: $e');
      emit(const DocumentScanFailure('حدث خطأ غير متوقع أثناء مسح الوثيقة'));
    }
  }

  /// Complete verification process (scan + save)
  Future<void> completeVerificationProcess({
    required File imageFile,
    required DocumentType documentType,
    required String userId,
  }) async {
    try {
      _logger.i('Starting complete verification process');

      // Step 1: Scan document
      emit(const VerificationProcessInProgress('جاري مسح الوثيقة...'));

      final scanResult = await _scanDocumentUseCase(
        ScanDocumentParams(imageFile: imageFile, documentType: documentType),
      );

      final extractedData = scanResult.fold((failure) {
        _logger.e('Document scan failed: ${failure.message}');
        emit(VerificationProcessFailure(failure.message, 'مسح الوثيقة'));
        return null;
      }, (data) => data);

      if (extractedData == null) return;

      // Check confidence level
      if (extractedData.confidence < 0.5) {
        emit(
          const VerificationProcessFailure(
            'جودة الصورة منخفضة. يرجى التأكد من وضوح الوثيقة وإعادة المحاولة',
            'فحص جودة الصورة',
          ),
        );
        return;
      }

      // Step 2: Save document
      emit(const VerificationProcessInProgress('جاري حفظ الوثيقة...'));

      final saveResult = await _saveIdentityDocumentUseCase(
        SaveIdentityDocumentParams(
          userId: userId,
          documentType: documentType,
          extractedData: extractedData,
          imageFile: imageFile,
        ),
      );

      saveResult.fold(
        (failure) {
          _logger.e('Document save failed: ${failure.message}');
          emit(VerificationProcessFailure(failure.message, 'حفظ الوثيقة'));
        },
        (document) {
          _logger.i('Verification process completed successfully');
          emit(VerificationProcessSuccess(document, extractedData));
        },
      );
    } catch (e) {
      _logger.e('Unexpected error during verification process: $e');
      emit(
        const VerificationProcessFailure(
          'حدث خطأ غير متوقع أثناء عملية التحقق',
          'عملية التحقق',
        ),
      );
    }
  }

  /// Get user documents
  Future<void> getUserDocuments(String userId) async {
    try {
      emit(DocumentsLoading());
      _logger.i('Fetching documents for user: $userId');

      final result = await _getUserDocumentsUseCase(
        GetUserDocumentsParams(userId: userId),
      );

      result.fold(
        (failure) {
          _logger.e('Failed to get user documents: ${failure.message}');
          emit(DocumentsLoadFailure(failure.message));
        },
        (documents) {
          _logger.i('Documents loaded successfully: ${documents.length}');
          emit(DocumentsLoaded(documents));
        },
      );
    } catch (e) {
      _logger.e('Unexpected error while getting documents: $e');
      emit(const DocumentsLoadFailure('حدث خطأ أثناء تحميل الوثائق'));
    }
  }

  /// Check verification status
  Future<void> checkVerificationStatus(String userId) async {
    try {
      emit(VerificationStatusLoading());
      _logger.i('Checking verification status for user: $userId');

      final result = await _checkVerificationStatusUseCase(
        CheckVerificationStatusParams(userId: userId),
      );

      result.fold(
        (failure) {
          _logger.e('Failed to check verification status: ${failure.message}');
          emit(VerificationStatusFailure(failure.message));
        },
        (isVerified) {
          _logger.i('Verification status: $isVerified');
          emit(VerificationStatusLoaded(isVerified));
        },
      );
    } catch (e) {
      _logger.e('Unexpected error while checking verification status: $e');
      emit(const VerificationStatusFailure('حدث خطأ أثناء فحص حالة التحقق'));
    }
  }

  /// Reset to initial state
  void reset() {
    emit(VerificationInitial());
  }

  /// Get current scan data if available
  String? getCurrentScanData() {
    if (state is DocumentScanSuccess) {
      final scanState = state as DocumentScanSuccess;
      return scanState.extractedData.fullName;
    }
    return null;
  }

  /// Check if scan was successful
  bool get hasScanSuccess => state is DocumentScanSuccess;

  /// Check if verification is in progress
  bool get isVerificationInProgress => state is VerificationProcessInProgress;

  /// Check if documents are loaded
  bool get hasDocuments => state is DocumentsLoaded;

  /// Get loaded documents
  List<IdentityDocument> get loadedDocuments {
    if (state is DocumentsLoaded) {
      return (state as DocumentsLoaded).documents;
    }
    return [];
  }
}
