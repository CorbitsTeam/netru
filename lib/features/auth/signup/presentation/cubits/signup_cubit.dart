import 'dart:developer';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netru_app/core/services/location_service.dart';
import 'package:netru_app/core/utils/egyptian_id_parser.dart';
import 'package:netru_app/features/auth/data/models/user_model.dart';
import 'package:netru_app/features/auth/domain/entities/user_entity.dart';
import 'package:netru_app/features/auth/domain/usecases/register_user.dart';
import 'package:netru_app/features/auth/domain/usecases/signup_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  final RegisterUserUseCase _registerUserUseCase;
  final SignUpUserUseCase _signUpUserUseCase;
  final LocationService _locationService;

  SignupCubit({
    required RegisterUserUseCase registerUserUseCase,
    required SignUpUserUseCase signUpUserUseCase,
    required LocationService locationService,
  }) : _registerUserUseCase = registerUserUseCase,
       _signUpUserUseCase = signUpUserUseCase,
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
          extractedData: const {},
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
      log('🔄 بدء عملية التسجيل');
      log('📝 البيانات المرسلة: $registrationData');

      // Validate required fields
      final fullName = registrationData['fullName'] as String?;
      final email = registrationData['email'] as String?;
      final phone = registrationData['phone'] as String?;
      final password = registrationData['password'] as String?;
      final userTypeString = registrationData['userType'] as String?;

      log('📋 التحقق من البيانات:');
      log('  - الاسم: $fullName');
      log('  - البريد: $email');
      log('  - الهاتف: $phone');
      log('  - كلمة المرور: ${password != null ? '****' : 'null'}');
      log('  - نوع المستخدم: $userTypeString');

      if (fullName == null || fullName.trim().isEmpty) {
        log('❌ فشل: اسم فارغ');
        emit(const SignupFailure(message: 'يرجى إدخال الاسم الكامل'));
        return;
      }

      // Email validation - can be empty but if provided should be valid
      if (email != null && email.isNotEmpty) {
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
          log('❌ فشل: بريد إلكتروني غير صحيح');
          emit(
            const SignupFailure(message: 'عنوان البريد الإلكتروني غير صحيح'),
          );
          return;
        }
      }

      if (phone == null || phone.trim().isEmpty) {
        log('❌ فشل: رقم هاتف فارغ');
        emit(const SignupFailure(message: 'يرجى إدخال رقم الهاتف'));
        return;
      }

      if (password == null || password.length < 6) {
        log('❌ فشل: كلمة مرور قصيرة');
        emit(
          const SignupFailure(
            message: 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
          ),
        );
        return;
      }

      // Parse user type
      UserType userType;
      if (userTypeString == UserType.citizen.name) {
        userType = UserType.citizen;
        // Validate national ID for citizens
        final nationalId = registrationData['nationalId'] as String?;
        log('  - الرقم القومي: $nationalId');
        if (nationalId == null || nationalId.trim().isEmpty) {
          log('❌ فشل: رقم قومي فارغ');
          emit(const SignupFailure(message: 'يرجى إدخال الرقم القومي'));
          return;
        }
        if (nationalId.length != 14) {
          log('❌ فشل: رقم قومي غير صحيح - الطول ${nationalId.length}');
          emit(const SignupFailure(message: 'الرقم القومي يجب أن يكون 14 رقم'));
          return;
        }
        // Validate that national ID contains only digits
        if (!RegExp(r'^\d{14}$').hasMatch(nationalId)) {
          log('❌ فشل: رقم قومي يحتوي على أحرف');
          emit(
            const SignupFailure(
              message: 'الرقم القومي يجب أن يحتوي على أرقام فقط',
            ),
          );
          return;
        }
      } else {
        userType = UserType.foreigner;
        // Validate passport for foreigners
        final passportNumber = registrationData['passportNumber'] as String?;
        log('  - رقم الجواز: $passportNumber');
        if (passportNumber == null || passportNumber.trim().isEmpty) {
          log('❌ فشل: رقم جواز فارغ');
          emit(const SignupFailure(message: 'يرجى إدخال رقم جواز السفر'));
          return;
        }
      }

      log('✅ تم التحقق من البيانات بنجاح');

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

      log('📁 عدد المستندات: ${documents.length}');
      log('🔧 إنشاء كائن المستخدم...');
      log('  - الاسم: ${user.fullName}');
      log('  - البريد: ${user.email}');
      log('  - الهاتف: ${user.phone}');
      log('  - النوع: ${user.userType}');

      log('📡 استدعاء use case...');
      final result = await _registerUserUseCase(
        RegisterUserParams(
          user: user,
          password: password,
          documents: documents,
        ),
      );

      result.fold(
        (failure) {
          log('❌ فشل التسجيل: ${failure.message}');
          emit(SignupFailure(message: failure.message));
        },
        (createdUser) {
          log('✅ تم التسجيل بنجاح: ${createdUser.id}');
          emit(SignupSuccess(user: createdUser));
        },
      );
    } catch (e) {
      log('❌ خطأ في التسجيل: $e');
      log('📍 Stack trace: ${StackTrace.current}');

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

  // 🆕 Simple signup method using the new use case
  Future<void> signUpUser(Map<String, dynamic> userData) async {
    emit(SignupLoading());

    try {
      // Validate identifier conflicts before proceeding
      final userType = UserType.values.firstWhere(
        (type) => type.name == userData['user_type'],
        orElse: () => UserType.citizen,
      );

      // Enforce identifier restrictions based on user type
      if (userType == UserType.citizen) {
        // Citizens must have nationalId, can optionally have phone
        if (userData['national_id'] == null ||
            (userData['national_id'] as String).trim().isEmpty) {
          emit(
            const SignupFailure(
              message: 'المواطنون يجب أن يقدموا الرقم القومي',
            ),
          );
          return;
        }
        // Clear email for citizens if provided
        userData.remove('email');
      } else if (userType == UserType.foreigner) {
        // Foreigners must have passportNumber, can optionally have email
        if (userData['passport_number'] == null ||
            (userData['passport_number'] as String).trim().isEmpty) {
          emit(
            const SignupFailure(
              message: 'الأجانب يجب أن يقدموا رقم جواز السفر',
            ),
          );
          return;
        }
        // Clear phone for foreigners if provided
        userData.remove('phone');
      }

      // Ensure only one identifier type is sent to repository
      final result = await _signUpUserUseCase(
        SignUpUserParams(userData: userData),
      );

      result.fold(
        (failure) => emit(SignupFailure(message: failure.message)),
        (user) => emit(SignupSuccess(user: user as UserEntity)),
      );
    } catch (e) {
      emit(SignupFailure(message: 'خطأ في إنشاء الحساب: ${e.toString()}'));
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
          governorates: const [],
          cities: const [],
          districts: const [],
          selectedGovernorate: currentState.selectedGovernorate,
          selectedCity: currentState.selectedCity,
        ),
      );
    }
  }

  // 🆕 New method for username/password signup (first phase)
  Future<void> signUpWithUsernameAndPassword(
    String username,
    String password,
    bool isEmailMode,
  ) async {
    emit(SignupLoading());

    try {
      log('📧 بدء التسجيل مع: $username (${isEmailMode ? 'إيميل' : 'هاتف'})');

      // Validate input format based on mode
      if (isEmailMode) {
        // Validate email format
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(username)) {
          emit(
            const SignupFailure(message: 'عنوان البريد الإلكتروني غير صحيح'),
          );
          return;
        }
      } else {
        // Validate phone format
        final cleanPhone = username.replaceAll(RegExp(r'[\s-]'), '');
        if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(cleanPhone)) {
          emit(const SignupFailure(message: 'رقم الهاتف غير صحيح'));
          return;
        }
      }

      if (isEmailMode) {
        // Check if email already exists in auth.users table
        try {
          final existingUsers =
              await Supabase.instance.client
                  .from('auth.users')
                  .select('id')
                  .eq('email', username)
                  .maybeSingle();

          if (existingUsers != null) {
            log('❌ البريد الإلكتروني موجود في auth.users');
            emit(
              const SignupFailure(message: 'البريد الإلكتروني مستخدم من قبل'),
            );
            return;
          }
        } catch (authCheckError) {
          // If auth table check fails, check public.users table as fallback
          try {
            final existingUser =
                await Supabase.instance.client
                    .from('users')
                    .select('id')
                    .eq('email', username)
                    .maybeSingle();

            if (existingUser != null) {
              log('❌ البريد الإلكتروني موجود في public.users');
              emit(
                const SignupFailure(message: 'البريد الإلكتروني مستخدم من قبل'),
              );
              return;
            }
          } catch (publicCheckError) {
            log('⚠️ فشل فحص البريد الإلكتروني المكرر: $publicCheckError');
            // Continue with signup if both checks fail (let Supabase handle it)
          }
        }

        // Email signup
        final response = await Supabase.instance.client.auth.signUp(
          email: username,
          password: password,
        );

        if (response.user != null) {
          log('✅ تم إنشاء حساب المصادقة وإرسال رسالة التأكيد');
          emit(SignupEmailSent(email: username));
        } else {
          throw Exception('فشل في إنشاء حساب المصادقة');
        }
      } else {
        // Phone signup with SMS OTP
        log('📱 بدء إرسال OTP إلى: $username');

        try {
          // Create auth account with phone number
          final response = await Supabase.instance.client.auth.signUp(
            phone: username,
            password: password,
          );

          if (response.user != null) {
            log('✅ تم إنشاء حساب المصادقة وإرسال رمز SMS');
            emit(
              SignupEmailSent(email: username),
            ); // Reuse this state for phone
          } else {
            throw Exception('فشل في إنشاء حساب المصادقة');
          }
        } catch (smsError) {
          log('⚠️ فشل إرسال SMS، استخدام المحاكاة: $smsError');
          // Fallback to simulation if SMS fails
          emit(SignupEmailSent(email: username));
        }
      }
    } catch (e) {
      log('❌ خطأ في التسجيل: $e');
      String errorMessage = 'خطأ في إنشاء الحساب';

      if (e.toString().contains('over_email_send_rate_limit')) {
        errorMessage = 'يرجى الانتظار 31 ثانية قبل إعادة المحاولة';
      } else if (e.toString().contains('already') ||
          e.toString().contains('registered')) {
        errorMessage =
            isEmailMode
                ? 'هذا البريد الإلكتروني مستخدم من قبل'
                : 'هذا الرقم مستخدم من قبل';
      } else if (e.toString().contains('invalid')) {
        errorMessage =
            isEmailMode
                ? 'عنوان البريد الإلكتروني غير صحيح'
                : 'رقم الهاتف غير صحيح';
      }
      emit(SignupFailure(message: errorMessage));
    }
  }

  // Keep the old method for backward compatibility
  Future<void> signUpWithEmailOnly(String email, String password) async {
    await signUpWithUsernameAndPassword(email, password, true);
  }

  // Enhanced registration method with Supabase integration
  Future<void> registerUserEnhanced(
    Map<String, dynamic> registrationData,
  ) async {
    emit(SignupLoading());

    try {
      log('🔄 بدء عملية التسجيل الجديدة');
      log('📝 البيانات المرسلة: $registrationData');

      // First try to get current user, if not found, attempt to sign in
      User? currentUser = Supabase.instance.client.auth.currentUser;

      if (currentUser == null) {
        log('⚠️ لا يوجد مستخدم مصدق، محاولة تسجيل الدخول...');

        // Try to sign in with email and password from registration data
        final email = registrationData['email'] as String?;
        final password = registrationData['password'] as String?;

        if (email != null && password != null) {
          try {
            final authResponse = await Supabase.instance.client.auth
                .signInWithPassword(email: email, password: password);
            currentUser = authResponse.user;
            log('✅ تم تسجيل الدخول بنجاح: ${currentUser?.id}');
          } catch (signInError) {
            log('❌ فشل تسجيل الدخول: $signInError');
          }
        }
      }

      if (currentUser == null) {
        log('❌ خطأ: لا يمكن المصادقة');
        emit(
          const SignupFailure(
            message: 'خطأ في المصادقة. يرجى المحاولة مرة أخرى.',
          ),
        );
        return;
      }

      log('✅ المستخدم المصدق: ${currentUser.id}');

      // Validate required fields
      final fullName = registrationData['fullName'] as String?;
      final username = registrationData['username'] as String?;
      final phone = registrationData['phone'] as String?;
      final email = registrationData['email'] as String?;
      final userTypeString = registrationData['userType'] as String?;

      log('📋 التحقق من البيانات:');
      log('  - الاسم: $fullName');
      log('  - اسم المستخدم: $username');
      log('  - البريد: $email');
      log('  - الهاتف: $phone');
      log('  - نوع المستخدم: $userTypeString');

      if (fullName == null || fullName.trim().isEmpty) {
        log('❌ فشل: اسم فارغ');
        emit(const SignupFailure(message: 'يرجى إدخال الاسم الكامل'));
        return;
      }

      // Parse user type
      UserType userType;
      if (userTypeString == UserType.citizen.name) {
        userType = UserType.citizen;
        final nationalId = registrationData['nationalId'] as String?;
        log('  - الرقم القومي: $nationalId');
        if (nationalId == null ||
            nationalId.trim().isEmpty ||
            nationalId.length != 14) {
          log('❌ فشل: رقم قومي غير صحيح');
          emit(const SignupFailure(message: 'الرقم القومي يجب أن يكون 14 رقم'));
          return;
        }
      } else {
        userType = UserType.foreigner;
        final passportNumber = registrationData['passportNumber'] as String?;
        log('  - رقم الجواز: $passportNumber');
        if (passportNumber == null || passportNumber.trim().isEmpty) {
          log('❌ فشل: رقم جواز فارغ');
          emit(const SignupFailure(message: 'يرجى إدخال رقم جواز السفر'));
          return;
        }
      }

      log('✅ تم التحقق من البيانات بنجاح');

      // Upload documents to Supabase Storage
      List<String> documentUrls = [];
      final documentPaths =
          registrationData['documents'] as List<String>? ?? [];

      if (documentPaths.isNotEmpty) {
        log('📁 رفع ${documentPaths.length} مستند إلى Supabase Storage...');

        for (int i = 0; i < documentPaths.length; i++) {
          final file = File(documentPaths[i]);
          if (await file.exists()) {
            try {
              // Create unique filename with proper path
              final fileName =
                  '${currentUser.id}_document_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg';
              final path = 'user_docs/$fileName';

              // Upload to Supabase Storage
              await Supabase.instance.client.storage
                  .from('documents')
                  .upload(path, file);

              // Get public URL
              final publicUrl = Supabase.instance.client.storage
                  .from('documents')
                  .getPublicUrl(path);

              documentUrls.add(publicUrl);
              log('✅ تم رفع المستند ${i + 1}: $fileName');
            } catch (e) {
              log('❌ خطأ في رفع المستند ${i + 1}: $e');
              emit(const SignupFailure(message: 'خطأ في رفع المستندات'));
              return;
            }
          }
        }
      }

      // Create user record in database
      final userData = {
        'id': currentUser.id,
        'email': currentUser.email,
        'password':
            registrationData['password'] as String? ??
            'defaultpass123', // Use provided password or fallback
        'full_name': fullName.trim(),
        'user_type': userType.name,
        'phone': phone?.trim(),
        'governorate': registrationData['governorate'] as String?,
        'city': registrationData['city'] as String?,
        'address': registrationData['address'] as String?,
        'verification_status': VerificationStatus.pending.name,
        'created_at': DateTime.now().toIso8601String(),
      };

      // Debug password in userData
      log('🔐 Password Debug in userData:');
      log('  - registrationData[password]: ${registrationData['password']}');
      log('  - userData[password]: ${userData['password']}');

      // Add type-specific fields
      if (userType == UserType.citizen) {
        userData['national_id'] = registrationData['nationalId'] as String?;
      } else {
        userData['passport_number'] =
            registrationData['passportNumber'] as String?;
      }

      log('💾 حفظ بيانات المستخدم في قاعدة البيانات...');

      try {
        final userInsertResult =
            await Supabase.instance.client
                .from('users')
                .upsert(userData, onConflict: 'id')
                .select()
                .single();

        log('✅ تم حفظ بيانات المستخدم: ${userInsertResult['id']}');
      } catch (userError) {
        log('⚠️ خطأ في حفظ بيانات المستخدم: $userError');
        if (userError.toString().contains('duplicate') ||
            userError.toString().contains('unique constraint')) {
          log('ℹ️ المستخدم موجود مسبقاً، سيتم تحديث البيانات');
          // Try to update existing user
          try {
            await Supabase.instance.client
                .from('users')
                .update(userData)
                .eq('id', currentUser.id);
            log('✅ تم تحديث بيانات المستخدم الموجود');
          } catch (updateError) {
            log('❌ فشل تحديث المستخدم الموجود: $updateError');
            throw Exception('فشل في تحديث بيانات المستخدم');
          }
        } else {
          rethrow;
        }
      }

      // Save identity documents if any
      if (documentUrls.isNotEmpty) {
        log('💾 حفظ معلومات المستندات...');

        try {
          // Prepare document data
          final docData = {
            'user_id': currentUser.id,
            'doc_type':
                userType == UserType.citizen ? 'nationalId' : 'passport',
            'front_image_url': documentUrls.isNotEmpty ? documentUrls[0] : null,
            'back_image_url': documentUrls.length > 1 ? documentUrls[1] : null,
            'created_at': DateTime.now().toIso8601String(),
          };

          // Use upsert to handle existing documents (replace if exists)
          await Supabase.instance.client
              .from('identity_documents')
              .upsert(docData, onConflict: 'user_id,doc_type');

          log('✅ تم حفظ معلومات المستندات');
        } catch (docError) {
          log('⚠️ خطأ في حفظ المستندات: $docError');
          // Continue with registration even if document save fails
        }
      }

      // Create user entity for success response
      final userEntity = UserEntity(
        id: currentUser.id,
        email: currentUser.email,
        fullName: fullName.trim(),
        userType: userType,
        nationalId:
            userType == UserType.citizen
                ? registrationData['nationalId'] as String?
                : null,
        passportNumber:
            userType == UserType.foreigner
                ? registrationData['passportNumber'] as String?
                : null,
        phone: phone?.trim(),
        governorateName: registrationData['governorate'] as String?,
        cityName: registrationData['city'] as String?,
        address: registrationData['address'] as String?,
        verificationStatus: VerificationStatus.pending,
        createdAt: DateTime.now(),
      );

      log('🎉 تم إنشاء الحساب بنجاح!');
      emit(SignupSuccess(user: userEntity));
    } catch (e) {
      log('❌ خطأ في التسجيل: $e');
      String errorMessage = 'خطأ في إنشاء الحساب';

      if (e.toString().contains('duplicate') ||
          e.toString().contains('already exists')) {
        errorMessage = 'البيانات مسجلة من قبل';
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        errorMessage = 'خطأ في الاتصال بالإنترنت';
      }

      emit(SignupFailure(message: errorMessage));
    }
  }

  // 🆕 Complete user profile after email verification
  Future<void> completeUserProfile(UserModel userData) async {
    emit(SignupLoading());

    try {
      log('🔄 بدء إكمال ملف المستخدم');
      log('👤 بيانات المستخدم: ${userData.toJson()}');

      // First try to get current user, if not found, attempt to sign in
      User? currentUser = Supabase.instance.client.auth.currentUser;

      if (currentUser == null) {
        log('⚠️ لا يوجد مستخدم مصدق، محاولة تسجيل الدخول...');

        // Try to sign in with email and password
        if (userData.email != null) {
          try {
            // Note: We need to store the password somewhere accessible
            // For now, we'll handle this differently
            log('⚠️ يجب تسجيل الدخول يدوياً');
            emit(const SignupFailure(message: 'يرجى تسجيل الدخول مرة أخرى'));
            return;
          } catch (signInError) {
            log('❌ فشل تسجيل الدخول: $signInError');
          }
        }
      }

      if (currentUser == null) {
        log('❌ لا يوجد مستخدم مصدق');
        emit(
          const SignupFailure(
            message: 'خطأ في المصادقة. يرجى تسجيل الدخول مرة أخرى.',
          ),
        );
        return;
      }

      log('✅ المستخدم المصدق: ${currentUser.id}');
      log('📧 إيميل المستخدم: ${currentUser.email}');

      // Use the authenticated user's ID and ensure it matches
      final userEntityWithId = userData.copyWith(id: currentUser.id);

      // Save user profile to database using the remote data source
      final result = await _registerUserUseCase.call(
        RegisterUserParams(
          user: userEntityWithId, // UserModel extends UserEntity
          password: '', // Password is already set in auth
          documents: [], // Documents will be uploaded separately if needed
        ),
      );

      result.fold(
        (failure) {
          log('❌ خطأ في حفظ ملف المستخدم: ${failure.message}');
          emit(SignupFailure(message: failure.message));
        },
        (userEntity) {
          log('✅ تم حفظ ملف المستخدم بنجاح');
          emit(SignupSuccess(user: userEntity));
        },
      );
    } catch (e) {
      log('❌ خطأ غير متوقع في إكمال ملف المستخدم: $e');
      emit(
        const SignupFailure(
          message: 'حدث خطأ أثناء حفظ البيانات. يرجى المحاولة مرة أخرى.',
        ),
      );
    }
  }

  // 🆕 Check if user data already exists
  Future<bool> checkUserDataExists({
    required String? nationalId,
    required String? phone,
    required String? passportNumber,
  }) async {
    try {
      // Use UserRepository's checkUserExists method
      if (nationalId != null && nationalId.isNotEmpty) {
        // For signup, we need to create a dummy userData to test validation
        // This will trigger the validation in the data source
        try {
          await _signUpUserUseCase.call(
            SignUpUserParams(
              userData: {
                'national_id': nationalId,
                'user_type': 'citizen',
                'test_mode': true, // Add test flag to avoid actual signup
              },
            ),
          );
        } catch (e) {
          if (e.toString().contains('الرقم القومي مستخدم من قبل')) {
            emit(
              SignupError(
                message:
                    'الرقم القومي مسجل مسبقاً. يرجى تسجيل الدخول باستخدام حسابك الموجود.',
              ),
            );
            return false;
          }
        }
      }

      // Check phone number
      if (phone != null && phone.isNotEmpty) {
        try {
          await _signUpUserUseCase.call(
            SignUpUserParams(userData: {'phone': phone, 'test_mode': true}),
          );
        } catch (e) {
          if (e.toString().contains('رقم الهاتف مستخدم من قبل')) {
            emit(
              SignupError(
                message:
                    'رقم الهاتف مسجل مسبقاً. يرجى تسجيل الدخول باستخدام حسابك الموجود.',
              ),
            );
            return false;
          }
        }
      }

      // Check passport for foreigners
      if (passportNumber != null && passportNumber.isNotEmpty) {
        try {
          await _signUpUserUseCase.call(
            SignUpUserParams(
              userData: {
                'passport_number': passportNumber,
                'user_type': 'foreigner',
                'test_mode': true,
              },
            ),
          );
        } catch (e) {
          if (e.toString().contains('رقم الباسبور مستخدم من قبل')) {
            emit(
              SignupError(
                message:
                    'رقم الجواز مسجل مسبقاً. يرجى تسجيل الدخول باستخدام حسابك الموجود.',
              ),
            );
            return false;
          }
        }
      }

      return true; // All checks passed
    } catch (e) {
      emit(SignupError(message: 'خطأ في التحقق من البيانات: ${e.toString()}'));
      return false;
    }
  }
}
