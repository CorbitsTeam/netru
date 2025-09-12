import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/register_user.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/utils/ocr_utils.dart';
import '../../../../core/utils/egyptian_id_parser.dart';
import 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  final RegisterUserUseCase _registerUserUseCase;
  final LocationService _locationService;

  SignupCubit({
    required RegisterUserUseCase registerUserUseCase,
    required LocationService locationService,
  }) : _registerUserUseCase = registerUserUseCase,
       _locationService = locationService,
       super(SignupInitial());

  void selectUserType(UserType userType) {
    emit(SignupUserTypeSelected(userType: userType));
  }

  void uploadDocuments(List<File> documents) {
    final currentState = state;
    if (currentState is SignupUserTypeSelected) {
      emit(
        SignupDocumentsUploaded(
          userType: currentState.userType,
          documents: documents,
        ),
      );
    }
  }

  Future<void> processOCR(File frontDocument) async {
    final currentState = state;
    if (currentState is! SignupDocumentsUploaded) return;

    emit(SignupOCRProcessing());

    try {
      final extractedText = await OCRUtils.extractTextFromImage(frontDocument);

      if (extractedText != null) {
        Map<String, String?> extractedData;

        if (currentState.userType == UserType.citizen) {
          extractedData = OCRUtils.extractNationalIdData(extractedText);
        } else {
          extractedData = OCRUtils.extractPassportData(extractedText);
        }

        emit(
          SignupOCRCompleted(
            userType: currentState.userType,
            documents: currentState.documents,
            extractedData: extractedData,
          ),
        );
      } else {
        emit(
          SignupOCRCompleted(
            userType: currentState.userType,
            documents: currentState.documents,
            extractedData: {},
          ),
        );
      }
    } catch (e) {
      emit(
        SignupOCRCompleted(
          userType: currentState.userType,
          documents: currentState.documents,
          extractedData: {},
        ),
      );
    }
  }

  void enterFormData(Map<String, dynamic> formData) {
    final currentState = state;

    if (currentState is SignupOCRCompleted) {
      emit(
        SignupDataEntered(
          userType: currentState.userType,
          documents: currentState.documents,
          extractedData: currentState.extractedData,
          formData: formData,
        ),
      );
    } else if (currentState is SignupDocumentsUploaded) {
      emit(
        SignupDataEntered(
          userType: currentState.userType,
          documents: currentState.documents,
          extractedData: {},
          formData: formData,
        ),
      );
    }
  }

  Future<void> loadGovernorates() async {
    final currentState = state;
    if (currentState is! SignupDataEntered) return;

    emit(SignupLocationLoading());

    try {
      final result = await _locationService.getGovernorates();

      result.fold(
        (failure) => emit(SignupError(message: failure.message)),
        (governorates) => emit(
          SignupLocationLoaded(
            userType: currentState.userType,
            documents: currentState.documents,
            extractedData: currentState.extractedData,
            formData: currentState.formData,
            governorates: governorates,
          ),
        ),
      );
    } catch (e) {
      emit(SignupError(message: 'خطأ في تحميل المحافظات: $e'));
    }
  }

  Future<void> selectGovernorate(GovernorateModel governorate) async {
    final currentState = state;
    if (currentState is! SignupLocationLoaded) return;

    try {
      final result = await _locationService.getCities(governorate.id);

      result.fold(
        (failure) => emit(SignupError(message: failure.message)),
        (cities) => emit(
          SignupCitiesLoaded(
            userType: currentState.userType,
            documents: currentState.documents,
            extractedData: currentState.extractedData,
            formData: currentState.formData,
            governorates: currentState.governorates,
            cities: cities,
            selectedGovernorate: governorate,
          ),
        ),
      );
    } catch (e) {
      emit(SignupError(message: 'خطأ في تحميل المدن: $e'));
    }
  }

  Future<void> selectCity(CityModel city) async {
    final currentState = state;
    if (currentState is! SignupCitiesLoaded) return;

    try {
      final result = await _locationService.getDistricts(city.id);

      result.fold(
        (failure) => emit(SignupError(message: failure.message)),
        (districts) => emit(
          SignupDistrictsLoaded(
            userType: currentState.userType,
            documents: currentState.documents,
            extractedData: currentState.extractedData,
            formData: currentState.formData,
            governorates: currentState.governorates,
            cities: currentState.cities,
            districts: districts,
            selectedGovernorate: currentState.selectedGovernorate,
            selectedCity: city,
          ),
        ),
      );
    } catch (e) {
      emit(SignupError(message: 'خطأ في تحميل الأحياء: $e'));
    }
  }

  void selectDistrict(DistrictModel? district) {
    final currentState = state;
    if (currentState is! SignupDistrictsLoaded) return;

    emit(
      SignupLocationSelected(
        userType: currentState.userType,
        documents: currentState.documents,
        extractedData: currentState.extractedData,
        formData: currentState.formData,
        selectedGovernorate: currentState.selectedGovernorate,
        selectedCity: currentState.selectedCity,
        selectedDistrict: district,
      ),
    );
  }

  Future<void> completeSignup(String password) async {
    final currentState = state;
    if (currentState is! SignupLocationSelected) return;

    emit(SignupLoading());

    try {
      // Parse date of birth from national ID if available
      DateTime? dateOfBirth;
      if (currentState.userType == UserType.citizen) {
        final nationalId = currentState.formData['nationalId'] as String?;
        if (nationalId != null) {
          dateOfBirth = EgyptianIdParser.parseEgyptianNationalIdToDOB(
            nationalId,
          );
        }
      }

      final user = UserEntity(
        fullName: currentState.formData['fullName'] as String,
        nationalId: currentState.formData['nationalId'] as String?,
        passportNumber: currentState.formData['passportNumber'] as String?,
        userType: currentState.userType,
        email: currentState.formData['email'] as String?,
        phone: currentState.formData['phone'] as String?,
        governorateId: currentState.selectedGovernorate.id,
        governorateName: currentState.selectedGovernorate.name,
        cityId: currentState.selectedCity.id,
        cityName: currentState.selectedCity.name,
        districtId: currentState.selectedDistrict?.id,
        districtName: currentState.selectedDistrict?.name,
        address: currentState.formData['address'] as String?,
        dateOfBirth: dateOfBirth,
        verificationStatus: VerificationStatus.pending,
      );

      final result = await _registerUserUseCase(
        RegisterUserParams(
          user: user,
          password: password,
          documents: currentState.documents,
        ),
      );

      result.fold(
        (failure) => emit(SignupError(message: failure.message)),
        (createdUser) => emit(SignupCompleted(user: createdUser)),
      );
    } catch (e) {
      emit(SignupError(message: 'خطأ في إنشاء الحساب: $e'));
    }
  }

  // New method for multi-step signup
  Future<void> registerUser(Map<String, dynamic> registrationData) async {
    emit(SignupLoading());

    try {
      print('🔄 بدء عملية التسجيل');
      print('📝 البيانات المرسلة: $registrationData');

      // Validate required fields
      final fullName = registrationData['fullName'] as String?;
      final email = registrationData['email'] as String?;
      final phone = registrationData['phone'] as String?;
      final password = registrationData['password'] as String?;
      final userTypeString = registrationData['userType'] as String?;

      print('📋 التحقق من البيانات:');
      print('  - الاسم: $fullName');
      print('  - البريد: $email');
      print('  - الهاتف: $phone');
      print('  - كلمة المرور: ${password != null ? '****' : 'null'}');
      print('  - نوع المستخدم: $userTypeString');

      if (fullName == null || fullName.trim().isEmpty) {
        print('❌ فشل: اسم فارغ');
        emit(SignupFailure(message: 'يرجى إدخال الاسم الكامل'));
        return;
      }

      // Email validation - can be empty but if provided should be valid
      if (email != null && email.isNotEmpty) {
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
          print('❌ فشل: بريد إلكتروني غير صحيح');
          emit(SignupFailure(message: 'عنوان البريد الإلكتروني غير صحيح'));
          return;
        }
      }

      if (phone == null || phone.trim().isEmpty) {
        print('❌ فشل: رقم هاتف فارغ');
        emit(SignupFailure(message: 'يرجى إدخال رقم الهاتف'));
        return;
      }

      if (password == null || password.length < 6) {
        print('❌ فشل: كلمة مرور قصيرة');
        emit(
          SignupFailure(message: 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'),
        );
        return;
      }

      // Parse user type
      UserType userType;
      if (userTypeString == UserType.citizen.name) {
        userType = UserType.citizen;
        // Validate national ID for citizens
        final nationalId = registrationData['nationalId'] as String?;
        print('  - الرقم القومي: $nationalId');
        if (nationalId == null || nationalId.trim().isEmpty) {
          print('❌ فشل: رقم قومي فارغ');
          emit(SignupFailure(message: 'يرجى إدخال الرقم القومي'));
          return;
        }
        if (nationalId.length != 14) {
          print('❌ فشل: رقم قومي غير صحيح - الطول ${nationalId.length}');
          emit(SignupFailure(message: 'الرقم القومي يجب أن يكون 14 رقم'));
          return;
        }
        // Validate that national ID contains only digits
        if (!RegExp(r'^\d{14}$').hasMatch(nationalId)) {
          print('❌ فشل: رقم قومي يحتوي على أحرف');
          emit(
            SignupFailure(message: 'الرقم القومي يجب أن يحتوي على أرقام فقط'),
          );
          return;
        }
      } else {
        userType = UserType.foreigner;
        // Validate passport for foreigners
        final passportNumber = registrationData['passportNumber'] as String?;
        print('  - رقم الجواز: $passportNumber');
        if (passportNumber == null || passportNumber.trim().isEmpty) {
          print('❌ فشل: رقم جواز فارغ');
          emit(SignupFailure(message: 'يرجى إدخال رقم جواز السفر'));
          return;
        }
      }

      print('✅ تم التحقق من البيانات بنجاح');

      // Create user entity from registration data
      final user = UserEntity(
        fullName: fullName.trim(),
        nationalId:
            userType == UserType.citizen
                ? (registrationData['nationalId'] as String?)?.trim()
                : null,
        passportNumber:
            userType == UserType.foreigner
                ? (registrationData['passportNumber'] as String?)?.trim()
                : null,
        userType: userType,
        email: email?.trim().isEmpty == true ? null : email?.trim(),
        phone: phone.trim(),
        governorateId: null, // Will be assigned later by backend
        governorateName: registrationData['governorate'] as String?,
        cityId: null, // Will be assigned later by backend
        cityName: registrationData['city'] as String?,
        districtId: null, // Will be assigned later by backend
        districtName: registrationData['district'] as String?,
        address: (registrationData['address'] as String?)?.trim(),
        dateOfBirth:
            registrationData['birthDate'] != null
                ? DateTime.tryParse(registrationData['birthDate'] as String)
                : null,
        verificationStatus: VerificationStatus.pending,
      );

      // Convert document paths to File objects
      final documentPaths =
          registrationData['documents'] as List<String>? ?? [];
      final documents = documentPaths.map((path) => File(path)).toList();

      print('📁 عدد المستندات: ${documents.length}');
      print('🔧 إنشاء كائن المستخدم...');
      print('  - الاسم: ${user.fullName}');
      print('  - البريد: ${user.email}');
      print('  - الهاتف: ${user.phone}');
      print('  - النوع: ${user.userType}');

      print('📡 استدعاء use case...');
      final result = await _registerUserUseCase(
        RegisterUserParams(
          user: user,
          password: password,
          documents: documents,
        ),
      );

      result.fold(
        (failure) {
          print('❌ فشل التسجيل: ${failure.message}');
          emit(SignupFailure(message: failure.message));
        },
        (createdUser) {
          print('✅ تم التسجيل بنجاح: ${createdUser.id}');
          emit(SignupSuccess(user: createdUser));
        },
      );
    } catch (e) {
      print('❌ خطأ في التسجيل: $e');
      print('📍 Stack trace: ${StackTrace.current}');

      // Extract meaningful error message
      String errorMessage = 'خطأ في إنشاء الحساب';
      if (e.toString().contains('Exception:')) {
        errorMessage = e.toString().split('Exception:').last.trim();
      } else {
        errorMessage = e.toString();
      }

      emit(SignupFailure(message: errorMessage));
    }
  }

  void reset() {
    emit(SignupInitial());
  }

  void goBack() {
    final currentState = state;

    if (currentState is SignupUserTypeSelected) {
      emit(SignupInitial());
    } else if (currentState is SignupDocumentsUploaded) {
      emit(SignupUserTypeSelected(userType: currentState.userType));
    } else if (currentState is SignupOCRCompleted) {
      emit(
        SignupDocumentsUploaded(
          userType: currentState.userType,
          documents: currentState.documents,
        ),
      );
    } else if (currentState is SignupDataEntered) {
      if (currentState.extractedData.isNotEmpty) {
        emit(
          SignupOCRCompleted(
            userType: currentState.userType,
            documents: currentState.documents,
            extractedData: currentState.extractedData,
          ),
        );
      } else {
        emit(
          SignupDocumentsUploaded(
            userType: currentState.userType,
            documents: currentState.documents,
          ),
        );
      }
    } else if (currentState is SignupLocationLoaded) {
      emit(
        SignupDataEntered(
          userType: currentState.userType,
          documents: currentState.documents,
          extractedData: currentState.extractedData,
          formData: currentState.formData,
        ),
      );
    } else if (currentState is SignupCitiesLoaded) {
      emit(
        SignupLocationLoaded(
          userType: currentState.userType,
          documents: currentState.documents,
          extractedData: currentState.extractedData,
          formData: currentState.formData,
          governorates: currentState.governorates,
        ),
      );
    } else if (currentState is SignupDistrictsLoaded) {
      emit(
        SignupCitiesLoaded(
          userType: currentState.userType,
          documents: currentState.documents,
          extractedData: currentState.extractedData,
          formData: currentState.formData,
          governorates: currentState.governorates,
          cities: currentState.cities,
          selectedGovernorate: currentState.selectedGovernorate,
        ),
      );
    } else if (currentState is SignupLocationSelected) {
      emit(
        SignupDistrictsLoaded(
          userType: currentState.userType,
          documents: currentState.documents,
          extractedData: currentState.extractedData,
          formData: currentState.formData,
          governorates: [],
          cities: [],
          districts: [],
          selectedGovernorate: currentState.selectedGovernorate,
          selectedCity: currentState.selectedCity,
        ),
      );
    }
  }
}
