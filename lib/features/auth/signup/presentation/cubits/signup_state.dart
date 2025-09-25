import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:netru_app/core/services/location_service.dart';
import 'package:netru_app/features/auth/domain/entities/user_entity.dart';

abstract class SignupState extends Equatable {
  const SignupState();

  @override
  List<Object?> get props => [];
}

class SignupInitial extends SignupState {}

class SignupLoading extends SignupState {}

class SignupUserTypeSelected extends SignupState {
  final UserType userType;

  const SignupUserTypeSelected({required this.userType});

  @override
  List<Object?> get props => [userType];
}

class SignupDocumentsUploaded extends SignupState {
  final UserType userType;
  final List<File> documents;

  const SignupDocumentsUploaded({
    required this.userType,
    required this.documents,
  });

  @override
  List<Object?> get props => [userType, documents];
}

class SignupOCRProcessing extends SignupState {}

class SignupOCRCompleted extends SignupState {
  final UserType userType;
  final List<File> documents;
  final Map<String, String?> extractedData;

  const SignupOCRCompleted({
    required this.userType,
    required this.documents,
    required this.extractedData,
  });

  @override
  List<Object?> get props => [userType, documents, extractedData];
}

class SignupDataEntered extends SignupState {
  final UserType userType;
  final List<File> documents;
  final Map<String, String?> extractedData;
  final Map<String, dynamic> formData;

  const SignupDataEntered({
    required this.userType,
    required this.documents,
    required this.extractedData,
    required this.formData,
  });

  @override
  List<Object?> get props => [userType, documents, extractedData, formData];
}

class SignupLocationLoading extends SignupState {}

class SignupLocationLoaded extends SignupState {
  final UserType userType;
  final List<File> documents;
  final Map<String, String?> extractedData;
  final Map<String, dynamic> formData;
  final List<GovernorateModel> governorates;

  const SignupLocationLoaded({
    required this.userType,
    required this.documents,
    required this.extractedData,
    required this.formData,
    required this.governorates,
  });

  @override
  List<Object?> get props => [
    userType,
    documents,
    extractedData,
    formData,
    governorates,
  ];
}

class SignupCitiesLoaded extends SignupState {
  final UserType userType;
  final List<File> documents;
  final Map<String, String?> extractedData;
  final Map<String, dynamic> formData;
  final List<GovernorateModel> governorates;
  final List<CityModel> cities;
  final GovernorateModel selectedGovernorate;

  const SignupCitiesLoaded({
    required this.userType,
    required this.documents,
    required this.extractedData,
    required this.formData,
    required this.governorates,
    required this.cities,
    required this.selectedGovernorate,
  });

  @override
  List<Object?> get props => [
    userType,
    documents,
    extractedData,
    formData,
    governorates,
    cities,
    selectedGovernorate,
  ];
}

class SignupDistrictsLoaded extends SignupState {
  final UserType userType;
  final List<File> documents;
  final Map<String, String?> extractedData;
  final Map<String, dynamic> formData;
  final List<GovernorateModel> governorates;
  final List<CityModel> cities;
  final List<DistrictModel> districts;
  final GovernorateModel selectedGovernorate;
  final CityModel selectedCity;

  const SignupDistrictsLoaded({
    required this.userType,
    required this.documents,
    required this.extractedData,
    required this.formData,
    required this.governorates,
    required this.cities,
    required this.districts,
    required this.selectedGovernorate,
    required this.selectedCity,
  });

  @override
  List<Object?> get props => [
    userType,
    documents,
    extractedData,
    formData,
    governorates,
    cities,
    districts,
    selectedGovernorate,
    selectedCity,
  ];
}

class SignupLocationSelected extends SignupState {
  final UserType userType;
  final List<File> documents;
  final Map<String, String?> extractedData;
  final Map<String, dynamic> formData;
  final GovernorateModel selectedGovernorate;
  final CityModel selectedCity;
  final DistrictModel? selectedDistrict;

  const SignupLocationSelected({
    required this.userType,
    required this.documents,
    required this.extractedData,
    required this.formData,
    required this.selectedGovernorate,
    required this.selectedCity,
    this.selectedDistrict,
  });

  @override
  List<Object?> get props => [
    userType,
    documents,
    extractedData,
    formData,
    selectedGovernorate,
    selectedCity,
    selectedDistrict,
  ];
}

class SignupCompleted extends SignupState {
  final UserEntity user;

  const SignupCompleted({required this.user});

  @override
  List<Object?> get props => [user];
}

class SignupSuccess extends SignupState {
  final UserEntity user;

  const SignupSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

// 🆕 New state for email verification flow
class SignupEmailSent extends SignupState {
  final String email;

  const SignupEmailSent({required this.email});

  @override
  List<Object?> get props => [email];
}

class SignupFailure extends SignupState {
  final String message;

  const SignupFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class SignupError extends SignupState {
  final String message;

  const SignupError({required this.message});

  @override
  List<Object?> get props => [message];
}

// 🆕 New state for showing login option when user already exists
class SignupUserExistsWithLoginOption extends SignupState {
  final String message;
  final String dataType; // 'email', 'phone', 'nationalId', 'passport'

  const SignupUserExistsWithLoginOption({
    required this.message,
    required this.dataType,
  });

  @override
  List<Object?> get props => [message, dataType];
}
