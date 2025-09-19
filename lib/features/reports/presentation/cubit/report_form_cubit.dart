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

    emit(state.copyWith(isLoading: true, errorMessage: ''));

    try {
      // Validate that a report type is selected
      if (state.selectedReportType == null) {
        print('❌ No report type selected');
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'يرجى اختيار نوع البلاغ',
          ),
        );
        return;
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
        submittedBy: userId, // Link report to current user
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
            state.copyWith(isLoading: false, errorMessage: userFriendlyError),
          );
        },
        (report) {
          print('✅ Report submitted successfully! ID: ${report.id}');
          print('📷 Media URL: ${report.mediaUrl}');
          emit(
            state.copyWith(
              isLoading: false,
              isSubmitted: true,
              submittedReportId: report.id,
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
        ),
      );
    }
  }

  void reset() {
    emit(const ReportFormState());
    loadReportTypes(); // Reload report types after reset
  }
}
