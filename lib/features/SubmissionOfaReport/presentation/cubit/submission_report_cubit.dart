import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netru_app/features/SubmissionOfaReport/presentation/cubit/submission_report_state.dart';
import 'dart:io';

class ReportFormCubit
    extends Cubit<ReportFormState> {
  ReportFormCubit()
    : super(const ReportFormState());

  void setGettingLocation(bool isGetting) {
    emit(
      state.copyWith(
        isGettingLocation: isGetting,
      ),
    );
  }

  void setLocation(
    double latitude,
    double longitude,
  ) {
    emit(
      state.copyWith(
        latitude: latitude,
        longitude: longitude,
      ),
    );
  }

  void setDateTime(DateTime dateTime) {
    emit(
      state.copyWith(selectedDateTime: dateTime),
    );
  }

  void setMedia(File media) {
    emit(state.copyWith(selectedMedia: media));
  }

  void removeMedia() {
    emit(
      state.copyWith(
        selectedMedia: null,
        removeMedia: true,
      ),
    );
  }

  void submitReport({
    required String firstName,
    required String lastName,
    required String nationalId,
    required String phone,
    required String reportType,
    required String reportDetails,
  }) async {
    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: '',
      ),
    );

    try {
      // Simulate API call
      await Future.delayed(
        const Duration(seconds: 2),
      );

      // Here you would typically make an API call to submit the report
      // Example:
      // final result = await _apiService.submitReport(...);

      emit(
        state.copyWith(
          isLoading: false,
          isSubmitted: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage:
              'حدث خطأ أثناء إرسال البلاغ. يرجى المحاولة مرة أخرى',
        ),
      );
    }
  }

  void reset() {
    emit(const ReportFormState());
  }
}
