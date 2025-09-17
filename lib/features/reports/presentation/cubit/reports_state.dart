import 'package:equatable/equatable.dart';
import '../../domain/entities/reports_entity.dart';

class ReportsState extends Equatable {
  final bool isLoading;
  final bool isLoadingDetail;
  final bool isUpdating;
  final bool isDeleting;
  final List<ReportEntity> reports;
  final ReportEntity? selectedReport;
  final String errorMessage;

  const ReportsState({
    this.isLoading = false,
    this.isLoadingDetail = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.reports = const [],
    this.selectedReport,
    this.errorMessage = '',
  });

  @override
  List<Object?> get props => [
    isLoading,
    isLoadingDetail,
    isUpdating,
    isDeleting,
    reports,
    selectedReport,
    errorMessage,
  ];

  ReportsState copyWith({
    bool? isLoading,
    bool? isLoadingDetail,
    bool? isUpdating,
    bool? isDeleting,
    List<ReportEntity>? reports,
    ReportEntity? selectedReport,
    String? errorMessage,
  }) {
    return ReportsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      reports: reports ?? this.reports,
      selectedReport: selectedReport ?? this.selectedReport,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
