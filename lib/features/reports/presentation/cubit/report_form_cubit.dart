import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netru_app/core/utils/user_data_helper.dart';
import 'package:netru_app/core/services/report_types_service.dart';
import 'report_form_state.dart';
import '../../domain/usecases/reports_usecase.dart';
import '../../data/models/report_type_model.dart';
import 'dart:io';

class ReportFormCubit extends Cubit<ReportFormState> {
  final CreateReportUseCase createReportUseCase;
  final ReportTypesService reportTypesService;

  ReportFormCubit({
    required this.createReportUseCase,
    required this.reportTypesService,
  }) : super(const ReportFormState()) {
    loadReportTypes();
  }

  void loadReportTypes() async {
    emit(state.copyWith(isLoadingReportTypes: true));
    try {
      final reportTypes = await reportTypesService.getAllReportTypes();
      emit(
        state.copyWith(reportTypes: reportTypes, isLoadingReportTypes: false),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingReportTypes: false,
          errorMessage: 'فشل في تحميل أنواع البلاغات: $e',
        ),
      );
    }
  }

  void setSelectedReportType(ReportTypeModel reportType) {
    emit(state.copyWith(selectedReportType: reportType));
  }

  void setGettingLocation(bool isGetting) {
    emit(state.copyWith(isGettingLocation: isGetting));
  }

  void setLocation(double latitude, double longitude, [String? locationName]) {
    emit(
      state.copyWith(
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
      ),
    );
  }

  void setDateTime(DateTime dateTime) {
    emit(state.copyWith(selectedDateTime: dateTime));
  }

  void setMedia(File media) {
    emit(state.copyWith(selectedMedia: media));
  }

  void removeMedia() {
    emit(state.copyWith(selectedMedia: null, removeMedia: true));
  }

  void addMediaFile(File media) {
    final currentFiles = List<File>.from(state.selectedMediaFiles);
    currentFiles.add(media);
    emit(state.copyWith(selectedMediaFiles: currentFiles));
  }

  void removeMediaFile(File media) {
    final currentFiles = List<File>.from(state.selectedMediaFiles);
    currentFiles.remove(media);
    emit(state.copyWith(selectedMediaFiles: currentFiles));
  }

  void clearAllMediaFiles() {
    emit(state.copyWith(clearAllMedia: true));
  }

  void addMultipleMediaFiles(List<File> mediaFiles) {
    final currentFiles = List<File>.from(state.selectedMediaFiles);
    currentFiles.addAll(mediaFiles);
    emit(state.copyWith(selectedMediaFiles: currentFiles));
  }

  void submitReport({
    required String firstName,
    required String lastName,
    required String nationalId,
    required String phone,
    required String reportDetails,
  }) async {
    print('🚀 Starting report submission...');
    print('📄 Report Details: $reportDetails');
    print('📍 Location: ${state.latitude}, ${state.longitude}');
    print('📷 Media File: ${state.selectedMedia?.path}');
    print('🗂️ Report Type: ${state.selectedReportType?.nameAr}');

    // Reset progress state
    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: '',
        submissionProgress: 0.0,
        currentStep: 'بدء معالجة البلاغ...',
      ),
    );

    try {
      // Step 1: Validate data (20%)
      emit(
        state.copyWith(
          submissionProgress: 0.1,
          currentStep: 'التحقق من صحة البيانات...',
        ),
      );

      if (state.selectedReportType == null) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'يرجى اختيار نوع البلاغ',
            submissionProgress: 0.0,
            currentStep: 'فشل في التحقق من البيانات',
          ),
        );
        return;
      }

      await Future.delayed(const Duration(milliseconds: 500));
      emit(
        state.copyWith(
          submissionProgress: 0.2,
          currentStep: 'تم التحقق من البيانات بنجاح',
        ),
      );

      // Step 2: Prepare media files
      final totalFiles =
          (state.selectedMedia != null ? 1 : 0) +
          state.selectedMediaFiles.length;
      if (totalFiles > 0) {
        emit(
          state.copyWith(
            submissionProgress: 0.3,
            currentStep: 'إعداد الملفات للرفع...',
            isUploadingMedia: true,
            totalFilesCount: totalFiles,
            uploadedFilesCount: 0,
          ),
        );
      } else {
        emit(
          state.copyWith(
            submissionProgress: 0.6,
            currentStep: 'تجهيز البلاغ للإرسال...',
          ),
        );
      }

      // Get current user ID
      final userHelper = UserDataHelper();
      final userId = userHelper.getUserId();
      print('👤 User ID: $userId');

      final params = CreateReportParams(
        firstName: firstName,
        lastName: lastName,
        nationalId: nationalId,
        phone: phone,
        reportType: state.selectedReportType!.nameAr, // Use Arabic name
        reportTypeId: state.selectedReportType!.id, // Store ID
        reportDetails: reportDetails,
        latitude: state.latitude,
        longitude: state.longitude,
        locationName: state.locationName,
        reportDateTime: state.selectedDateTime ?? DateTime.now(),
        mediaFile: state.selectedMedia,
        mediaFiles:
            state.selectedMediaFiles.isNotEmpty
                ? state.selectedMediaFiles
                : null,
        submittedBy: userId, // Link report to current user
      );

      // Step 3: Submit report (60% - 90%)
      emit(
        state.copyWith(
          submissionProgress: 0.7,
          currentStep: 'إرسال البلاغ...',
          isUploadingMedia: false,
        ),
      );

      print('📤 Calling createReportUseCase...');
      final result = await createReportUseCase.call(params);

      result.fold(
        (error) {
          print('❌ Report submission failed: $error');
          String userFriendlyError;
          if (error.contains('Failed to upload media')) {
            userFriendlyError =
                'تم إنشاء البلاغ بنجاح ولكن فشل في رفع الوسائط. يمكنك إرفاق الوسائط لاحقاً.';
          } else if (error.contains('PathNotFoundException') ||
              error.contains('File does not exist')) {
            userFriendlyError =
                'فشل في الوصول إلى الملف المحدد. يرجى اختيار ملف آخر.';
          } else if (error.contains('file is empty')) {
            userFriendlyError = 'الملف المحدد فارغ. يرجى اختيار ملف صالح.';
          } else if (error.contains('Storage access denied')) {
            userFriendlyError =
                'فشل في رفع الملف. يرجى التحقق من إعدادات التخزين.';
          } else if (error.contains('Bucket not found')) {
            userFriendlyError =
                'فشل في رفع الملف. يرجى التحقق من إعدادات التخزين.';
          } else {
            userFriendlyError = 'حدث خطأ أثناء إرسال البلاغ: $error';
          }

          emit(
            state.copyWith(
              isLoading: false,
              errorMessage: userFriendlyError,
              submissionProgress: 0.0,
              currentStep: 'فشل في الإرسال',
              isUploadingMedia: false,
            ),
          );
        },
        (report) async {
          print('✅ Report submitted successfully! ID: ${report.id}');

          // Step 4: Sending notifications (90% - 100%)
          emit(
            state.copyWith(
              submissionProgress: 0.9,
              currentStep: 'إرسال الإشعارات...',
            ),
          );

          await Future.delayed(const Duration(milliseconds: 800));

          // Step 5: Complete (100%)
          emit(
            state.copyWith(
              isLoading: false,
              isSubmitted: true,
              submittedReportId: report.id,
              submissionProgress: 1.0,
              currentStep: 'تم إرسال البلاغ بنجاح!',
              isUploadingMedia: false,
            ),
          );
        },
      );
    } catch (e) {
      print('💥 Exception during report submission: $e');
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'حدث خطأ أثناء إرسال البلاغ. يرجى المحاولة مرة أخرى',
          submissionProgress: 0.0,
          currentStep: 'فشل في الإرسال',
          isUploadingMedia: false,
        ),
      );
    }
  }

  void updateUploadProgress(int uploadedFiles, int totalFiles) {
    if (totalFiles > 0) {
      final uploadProgress = uploadedFiles / totalFiles;
      final overallProgress = 0.3 + (uploadProgress * 0.3); // 30% - 60%

      emit(
        state.copyWith(
          submissionProgress: overallProgress,
          uploadedFilesCount: uploadedFiles,
          currentStep: 'رفع الملفات... ($uploadedFiles/$totalFiles)',
        ),
      );
    }
  }

  void reset() {
    emit(const ReportFormState());
    loadReportTypes(); // Reload report types after reset
  }
}
