import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/services/location_service.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/profile_completion_usecases.dart';
import '../../../domain/usecases/validate_critical_data.dart';
import '../../../domain/usecases/check_data_exists.dart';
import 'profile_completion_state.dart';

/// Cubit شامل ومحسن لإكمال الملف الشخصي
class ProfileCompletionCubit extends Cubit<ProfileCompletionState> {
  final CompleteProfileUseCase completeProfileUseCase;
  final VerifyEmailAndCompleteSignupUseCase verifyEmailAndCompleteSignupUseCase;
  final ResendVerificationEmailUseCase resendVerificationEmailUseCase;
  final ValidateCriticalDataUseCase validateCriticalDataUseCase;
  final CheckPhoneExistsUseCase checkPhoneExistsUseCase;
  final CheckNationalIdExistsUseCase checkNationalIdExistsUseCase;
  final CheckPassportExistsUseCase checkPassportExistsUseCase;
  final CheckEmailExistsInUsersUseCase checkEmailExistsInUsersUseCase;

  final PageController pageController = PageController();

  int _currentStep = 0;
  int get currentStep => _currentStep;

  // Form Controllers
  late final TextEditingController fullNameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController nationalIdController;
  late final TextEditingController passportController;

  // Location Controllers
  late final TextEditingController governorateController;
  late final TextEditingController cityController;
  late final TextEditingController areaController;
  late final TextEditingController detailedAddressController;

  // Work Controllers
  late final TextEditingController jobTitleController;
  late final TextEditingController companyNameController;
  late final TextEditingController workAddressController;

  // Data Entry Step
  Map<String, String> userFormData = {};

  // Location Step
  GovernorateModel? selectedGovernorate;
  CityModel? selectedCity;
  String? selectedArea;

  // Documents
  List<File> documents = [];

  ProfileCompletionCubit({
    required this.completeProfileUseCase,
    required this.verifyEmailAndCompleteSignupUseCase,
    required this.resendVerificationEmailUseCase,
    required this.validateCriticalDataUseCase,
    required this.checkPhoneExistsUseCase,
    required this.checkNationalIdExistsUseCase,
    required this.checkPassportExistsUseCase,
    required this.checkEmailExistsInUsersUseCase,
  }) : super(ProfileCompletionInitial()) {
    // Initialize controllers
    fullNameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    nationalIdController = TextEditingController();
    passportController = TextEditingController();
    governorateController = TextEditingController();
    cityController = TextEditingController();
    areaController = TextEditingController();
    detailedAddressController = TextEditingController();
    jobTitleController = TextEditingController();
    companyNameController = TextEditingController();
    workAddressController = TextEditingController();
  }

  // Navigation Methods
  void nextStep() {
    if (_currentStep < 2) {
      _currentStep++;
      pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _emitStepChanged();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _emitStepChanged();
    }
  }

  // Data Management Methods
  void onDataChanged(Map<String, String> data) {
    userFormData = {...userFormData, ...data};
    _emitStepChanged();
  }

  void onGovernorateChanged(GovernorateModel? governorate) {
    selectedGovernorate = governorate;
    selectedCity = null;
    _emitStepChanged();
  }

  void onCityChanged(CityModel? city) {
    selectedCity = city;
    _emitStepChanged();
  }

  // Location Selection Methods
  void selectGovernorate(String governorateName) {
    governorateController.text = governorateName;
    selectedGovernorate = GovernorateModel(
      id: governorateName.hashCode,
      name: governorateName,
    );
    // Clear city and area when governorate changes
    cityController.clear();
    areaController.clear();
    selectedCity = null;
    selectedArea = null;
    _emitStepChanged();
  }

  void selectCity(String cityName) {
    cityController.text = cityName;
    selectedCity = CityModel(
      id: cityName.hashCode,
      name: cityName,
      governorateId: selectedGovernorate?.id ?? 0,
    );
    // Clear area when city changes
    areaController.clear();
    selectedArea = null;
    _emitStepChanged();
  }

  void selectArea(String areaName) {
    areaController.text = areaName;
    selectedArea = areaName;
    _emitStepChanged();
  }

  // Validation Methods
  Future<void> validateEmailInRealTime(String email) async {
    if (email.isEmpty) return;

    emit(
      const ProfileCompletionValidating(
        message: 'التحقق من البريد الإلكتروني...',
      ),
    );

    final result = await checkEmailExistsInUsersUseCase.call(email);
    result.fold(
      (failure) =>
          emit(ProfileCompletionValidationError(errorMessage: failure.message)),
      (exists) {
        if (exists) {
          emit(
            const ProfileCompletionValidationError(
              errorMessage: 'البريد الإلكتروني مستخدم من قبل',
            ),
          );
        } else {
          _emitStepChanged();
        }
      },
    );
  }

  // Additional Validation Methods
  Future<void> validatePhoneInRealTime(String phone) async {
    if (phone.isEmpty) return;

    emit(
      const ProfileCompletionValidating(message: 'التحقق من رقم التليفون...'),
    );

    final result = await checkPhoneExistsUseCase.call(phone);
    result.fold(
      (failure) =>
          emit(ProfileCompletionValidationError(errorMessage: failure.message)),
      (exists) {
        if (exists) {
          emit(
            const ProfileCompletionValidationError(
              errorMessage: 'رقم التليفون مستخدم من قبل',
            ),
          );
        } else {
          _emitStepChanged();
        }
      },
    );
  }

  Future<void> validateNationalIdInRealTime(String nationalId) async {
    if (nationalId.isEmpty) return;

    emit(
      const ProfileCompletionValidating(message: 'التحقق من الرقم القومي...'),
    );

    final result = await checkNationalIdExistsUseCase.call(nationalId);
    result.fold(
      (failure) =>
          emit(ProfileCompletionValidationError(errorMessage: failure.message)),
      (exists) {
        if (exists) {
          emit(
            const ProfileCompletionValidationError(
              errorMessage: 'الرقم القومي مستخدم من قبل',
            ),
          );
        } else {
          _emitStepChanged();
        }
      },
    );
  }

  Future<void> validatePassportInRealTime(String passportNumber) async {
    if (passportNumber.isEmpty) return;

    emit(
      const ProfileCompletionValidating(message: 'التحقق من رقم جواز السفر...'),
    );

    final result = await checkPassportExistsUseCase.call(passportNumber);
    result.fold(
      (failure) =>
          emit(ProfileCompletionValidationError(errorMessage: failure.message)),
      (exists) {
        if (exists) {
          emit(
            const ProfileCompletionValidationError(
              errorMessage: 'رقم جواز السفر مستخدم من قبل',
            ),
          );
        } else {
          _emitStepChanged();
        }
      },
    );
  }

  // Complete Profile Method
  Future<void> completeProfile(String authUserId) async {
    emit(ProfileCompletionLoading());

    try {
      final user = _createUserFromFormData();

      final result = await completeProfileUseCase.call(
        CompleteProfileParams(user: user, authUserId: authUserId),
      );

      result.fold(
        (failure) =>
            emit(ProfileCompletionError(errorMessage: failure.message)),
        (completedUser) => emit(
          const ProfileCompletionSuccess(
            message: 'تم إكمال الملف الشخصي بنجاح',
          ),
        ),
      );
    } catch (e) {
      emit(ProfileCompletionError(errorMessage: 'خطأ غير متوقع: $e'));
    }
  }

  // Helper Methods
  void _emitStepChanged() {
    emit(
      ProfileCompletionStepChanged(
        currentStep: _currentStep,
        formData: userFormData,
        selectedGovernorate: selectedGovernorate,
        selectedCity: selectedCity,
      ),
    );
  }

  UserEntity _createUserFromFormData() {
    UserType userType = UserType.citizen;
    if (userFormData['passport_number'] != null &&
        userFormData['passport_number']!.isNotEmpty) {
      userType = UserType.foreigner;
    }

    return UserEntity(
      fullName: userFormData['full_name'] ?? '',
      email: userFormData['email'],
      nationalId: userFormData['national_id'],
      passportNumber: userFormData['passport_number'],
      userType: userType,
      phone: userFormData['phone'],
      governorateId: selectedGovernorate?.id,
      governorateName: selectedGovernorate?.name,
      cityId: selectedCity?.id,
      cityName: selectedCity?.name,
      address: userFormData['address'],
    );
  }

  bool get isFormValid {
    final fullName = userFormData['full_name'];
    final phone = userFormData['phone'];
    final hasIdentifier =
        (userFormData['national_id']?.isNotEmpty ?? false) ||
        (userFormData['passport_number']?.isNotEmpty ?? false);

    return fullName != null &&
        fullName.isNotEmpty &&
        phone != null &&
        phone.isNotEmpty &&
        hasIdentifier &&
        selectedGovernorate != null &&
        selectedCity != null;
  }

  @override
  Future<void> close() {
    pageController.dispose();
    // Dispose all controllers
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    nationalIdController.dispose();
    passportController.dispose();
    governorateController.dispose();
    cityController.dispose();
    areaController.dispose();
    detailedAddressController.dispose();
    jobTitleController.dispose();
    companyNameController.dispose();
    workAddressController.dispose();
    return super.close();
  }
}
