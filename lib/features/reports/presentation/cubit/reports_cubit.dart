import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/reports_entity.dart';
import '../../domain/usecases/reports_usecase.dart';
import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final GetAllReportsUseCase getAllReportsUseCase;
  final GetReportByIdUseCase getReportByIdUseCase;
  final UpdateReportStatusUseCase updateReportStatusUseCase;
  final DeleteReportUseCase deleteReportUseCase;

  ReportsCubit({
    required this.getAllReportsUseCase,
    required this.getReportByIdUseCase,
    required this.updateReportStatusUseCase,
    required this.deleteReportUseCase,
  }) : super(const ReportsState());

  Future<void> loadReports() async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));

    final result = await getAllReportsUseCase.call();

    result.fold(
      (error) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'فشل في تحميل البلاغات: $error',
          ),
        );
      },
      (reports) {
        emit(state.copyWith(isLoading: false, reports: reports));
      },
    );
  }

  Future<void> getReportById(String id) async {
    emit(state.copyWith(isLoadingDetail: true, errorMessage: ''));

    final result = await getReportByIdUseCase.call(id);

    result.fold(
      (error) {
        emit(
          state.copyWith(
            isLoadingDetail: false,
            errorMessage: 'فشل في تحميل تفاصيل البلاغ: $error',
          ),
        );
      },
      (report) {
        emit(state.copyWith(isLoadingDetail: false, selectedReport: report));
      },
    );
  }

  Future<void> updateReportStatus(String id, ReportStatus status) async {
    emit(state.copyWith(isUpdating: true, errorMessage: ''));

    final result = await updateReportStatusUseCase.call(id, status);

    result.fold(
      (error) {
        emit(
          state.copyWith(
            isUpdating: false,
            errorMessage: 'فشل في تحديث حالة البلاغ: $error',
          ),
        );
      },
      (updatedReport) {
        // Update the report in the list
        final updatedReports =
            state.reports
                .map((report) => report.id == id ? updatedReport : report)
                .toList();

        emit(
          state.copyWith(
            isUpdating: false,
            reports: updatedReports,
            selectedReport:
                state.selectedReport?.id == id
                    ? updatedReport
                    : state.selectedReport,
          ),
        );
      },
    );
  }

  Future<void> deleteReport(String id) async {
    emit(state.copyWith(isDeleting: true, errorMessage: ''));

    final result = await deleteReportUseCase.call(id);

    result.fold(
      (error) {
        emit(
          state.copyWith(
            isDeleting: false,
            errorMessage: 'فشل في حذف البلاغ: $error',
          ),
        );
      },
      (_) {
        // Remove the report from the list
        final updatedReports =
            state.reports.where((report) => report.id != id).toList();

        emit(
          state.copyWith(
            isDeleting: false,
            reports: updatedReports,
            selectedReport:
                state.selectedReport?.id == id ? null : state.selectedReport,
          ),
        );
      },
    );
  }

  void clearSelectedReport() {
    emit(state.copyWith(selectedReport: null));
  }

  void clearError() {
    emit(state.copyWith(errorMessage: ''));
  }

  List<ReportEntity> getReportsByStatus(ReportStatus status) {
    return state.reports.where((report) => report.status == status).toList();
  }

  List<ReportEntity> getReportsByType(String type) {
    return state.reports.where((report) => report.reportType == type).toList();
  }
}
