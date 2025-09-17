import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netru_app/features/SubmissionOfaReport/presentation/cubit/submission_report_state.dart';
import 'package:netru_app/features/reports/domain/usecases/reports_usecase.dart';
import 'dart:io';

class ReportFormCubit extends Cubit<ReportFormState> {
  final CreateReportUseCase createReportUseCase;

  ReportFormCubit({required this.createReportUseCase})
    : super(const ReportFormState());

  void setGettingLocation(bool isGetting) {
    emit(state.copyWith(isGettingLocation: isGetting));
  }

  void setLocation(double latitude, double longitude) {
    emit(state.copyWith(latitude: latitude, longitude: longitude));
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
    required String reportType,
    required String reportDetails,
  }) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));

    try {
      final params = CreateReportParams(
        firstName: firstName,
        lastName: lastName,
        nationalId: nationalId,
        phone: phone,
        reportType: reportType,
        reportDetails: reportDetails,
        latitude: state.latitude,
        longitude: state.longitude,
        reportDateTime: state.selectedDateTime ?? DateTime.now(),
        mediaFile: state.selectedMedia,
      );

      final result = await createReportUseCase.call(params);

      result.fold(
        (error) {
          emit(
            state.copyWith(
              isLoading: false,
              errorMessage: 'حدث خطأ أثناء إرسال البلاغ: $error',
            ),
          );
        },
        (report) {
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
  }
}
