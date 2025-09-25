import 'package:equatable/equatable.dart';
import '../../../../../../core/services/location_service.dart';

/// حالات إكمال الملف الشخصي
abstract class ProfileCompletionState extends Equatable {
  const ProfileCompletionState();

  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class ProfileCompletionInitial extends ProfileCompletionState {}

/// تحميل
class ProfileCompletionLoading extends ProfileCompletionState {}

/// تغيير الخطوة
class ProfileCompletionStepChanged extends ProfileCompletionState {
  final int currentStep;
  final Map<String, String> formData;
  final GovernorateModel? selectedGovernorate;
  final CityModel? selectedCity;

  const ProfileCompletionStepChanged({
    required this.currentStep,
    required this.formData,
    this.selectedGovernorate,
    this.selectedCity,
  });

  @override
  List<Object?> get props => [
    currentStep,
    formData,
    selectedGovernorate,
    selectedCity,
  ];
}

/// فشل في التحقق من البيانات
class ProfileCompletionValidationError extends ProfileCompletionState {
  final String errorMessage;

  const ProfileCompletionValidationError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

/// نجح إكمال الملف الشخصي
class ProfileCompletionSuccess extends ProfileCompletionState {
  final String message;

  const ProfileCompletionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// فشل في إكمال الملف الشخصي
class ProfileCompletionError extends ProfileCompletionState {
  final String errorMessage;

  const ProfileCompletionError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

/// حالة التحقق من البيانات
class ProfileCompletionValidating extends ProfileCompletionState {
  final String message;

  const ProfileCompletionValidating({required this.message});

  @override
  List<Object?> get props => [message];
}
