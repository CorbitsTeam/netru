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
    this.selectedMediaFiles = const [],
    this.reportTypes = const [],
    this.selectedReportType,
    this.errorMessage = '',
    this.submittedReportId,
    this.submissionProgress = 0.0,
    this.currentStep = '',
    this.isUploadingMedia = false,
    this.uploadedFilesCount = 0,
    this.totalFilesCount = 0,
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
  final List<File> selectedMediaFiles;
  final List<ReportTypeModel> reportTypes;
  final ReportTypeModel? selectedReportType;
  final String errorMessage;
  final String? submittedReportId;
  final double submissionProgress;
  final String currentStep;
  final bool isUploadingMedia;
  final int uploadedFilesCount;
  final int totalFilesCount;

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
    selectedMediaFiles,
    reportTypes,
    selectedReportType,
    errorMessage,
    submittedReportId,
    submissionProgress,
    currentStep,
    isUploadingMedia,
    uploadedFilesCount,
    totalFilesCount,
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
    List<File>? selectedMediaFiles,
    List<ReportTypeModel>? reportTypes,
    ReportTypeModel? selectedReportType,
    String? errorMessage,
    bool? removeMedia,
    bool? clearAllMedia,
    String? submittedReportId,
    double? submissionProgress,
    String? currentStep,
    bool? isUploadingMedia,
    int? uploadedFilesCount,
    int? totalFilesCount,
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
      selectedMedia:
          removeMedia == true ? null : (selectedMedia ?? this.selectedMedia),
      selectedMediaFiles:
          clearAllMedia == true
              ? const []
              : (selectedMediaFiles ?? this.selectedMediaFiles),
      reportTypes: reportTypes ?? this.reportTypes,
      selectedReportType: selectedReportType ?? this.selectedReportType,
      errorMessage: errorMessage ?? this.errorMessage,
      submittedReportId: submittedReportId ?? this.submittedReportId,
      submissionProgress: submissionProgress ?? this.submissionProgress,
      currentStep: currentStep ?? this.currentStep,
      isUploadingMedia: isUploadingMedia ?? this.isUploadingMedia,
      uploadedFilesCount: uploadedFilesCount ?? this.uploadedFilesCount,
      totalFilesCount: totalFilesCount ?? this.totalFilesCount,
    );
  }
}
