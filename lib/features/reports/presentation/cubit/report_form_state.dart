import 'dart:io';

import 'package:equatable/equatable.dart';
import '../../data/models/report_type_model.dart';

class ReportFormState extends Equatable {
  const ReportFormState({
    this.isLoading = false,
    this.isSubmitted = false,
    this.isGettingLocation = false,
    this.isLoadingReportTypes = false,
    this.latitude,
    this.longitude,
    this.locationName,
    this.selectedDateTime,
    this.selectedMedia,
    this.reportTypes = const [],
    this.selectedReportType,
    this.errorMessage = '',
    this.submittedReportId,
  });

  final bool isLoading;
  final bool isSubmitted;
  final bool isGettingLocation;
  final bool isLoadingReportTypes;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final DateTime? selectedDateTime;
  final File? selectedMedia;
  final List<ReportTypeModel> reportTypes;
  final ReportTypeModel? selectedReportType;
  final String errorMessage;
  final String? submittedReportId;

  @override
  List<Object?> get props => [
    isLoading,
    isSubmitted,
    isGettingLocation,
    isLoadingReportTypes,
    latitude,
    longitude,
    locationName,
    selectedDateTime,
    selectedMedia,
    reportTypes,
    selectedReportType,
    errorMessage,
    submittedReportId,
  ];

  ReportFormState copyWith({
    bool? isLoading,
    bool? isSubmitted,
    bool? isGettingLocation,
    bool? isLoadingReportTypes,
    double? latitude,
    double? longitude,
    String? locationName,
    DateTime? selectedDateTime,
    File? selectedMedia,
    List<ReportTypeModel>? reportTypes,
    ReportTypeModel? selectedReportType,
    String? errorMessage,
    bool? removeMedia,
    String? submittedReportId,
  }) {
    return ReportFormState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      isGettingLocation: isGettingLocation ?? this.isGettingLocation,
      isLoadingReportTypes: isLoadingReportTypes ?? this.isLoadingReportTypes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      selectedDateTime: selectedDateTime ?? this.selectedDateTime,
      selectedMedia: removeMedia == true ? null : (selectedMedia ?? this.selectedMedia),
      reportTypes: reportTypes ?? this.reportTypes,
      selectedReportType: selectedReportType ?? this.selectedReportType,
      errorMessage: errorMessage ?? this.errorMessage,
      submittedReportId: submittedReportId ?? this.submittedReportId,
    );
  }
}
