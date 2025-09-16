import 'dart:io';

import 'package:equatable/equatable.dart';

class ReportFormState extends Equatable {
  const ReportFormState({
    this.isLoading = false,
    this.isSubmitted = false,
    this.isGettingLocation = false,
    this.latitude,
    this.longitude,
    this.selectedDateTime,
    this.selectedMedia,
    this.errorMessage = '',
  });

  final bool isLoading;
  final bool isSubmitted;
  final bool isGettingLocation;
  final double? latitude;
  final double? longitude;
  final DateTime? selectedDateTime;
  final File? selectedMedia;
  final String errorMessage;

  @override
  List<Object?> get props => [
    isLoading,
    isSubmitted,
    isGettingLocation,
    latitude,
    longitude,
    selectedDateTime,
    selectedMedia,
    errorMessage,
  ];

  ReportFormState copyWith({
    bool? isLoading,
    bool? isSubmitted,
    bool? isGettingLocation,
    double? latitude,
    double? longitude,
    DateTime? selectedDateTime,
    File? selectedMedia,
    String? errorMessage,
    bool? removeMedia,
  }) {
    return ReportFormState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitted:
          isSubmitted ?? this.isSubmitted,
      isGettingLocation:
          isGettingLocation ??
          this.isGettingLocation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      selectedDateTime:
          selectedDateTime ??
          this.selectedDateTime,
      selectedMedia:
          removeMedia == true
              ? null
              : (selectedMedia ??
                  this.selectedMedia),
      errorMessage:
          errorMessage ?? this.errorMessage,
    );
  }
}
