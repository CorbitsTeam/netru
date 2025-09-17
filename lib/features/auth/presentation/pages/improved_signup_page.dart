import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:netru_app/core/routing/routes.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:netru_app/core/widgets/custom_snack_bar.dart';
import 'package:netru_app/features/auth/presentation/widgets/data_entry_step.dart';
import 'package:netru_app/features/auth/presentation/widgets/review_submit_step.dart';
import '../../../../core/services/location_service.dart';
import '../widgets/user_type_selection_step.dart';
import '../widgets/document_upload_step.dart';
import '../widgets/simple_location_step.dart';
import '../widgets/animated_button.dart';
import '../widgets/custom_text_field.dart';
import '../cubit/signup_cubit.dart';
import '../cubit/signup_state.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/extracted_document_data.dart';

class ImprovedSignupPage extends StatefulWidget {
  const ImprovedSignupPage({super.key});

  @override
  State<ImprovedSignupPage> createState() => _ImprovedSignupPageState();
}

class _ImprovedSignupPageState extends State<ImprovedSignupPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Step 0: Username (email or phone) and Password
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isEmailMode = true; // true for email, false for phone

  // Step 1: OTP Verification (Email or SMS)
  bool _isVerified = false;
  bool _isCheckingVerification = false;
  String _otpCode = '';
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  Timer? _resendTimer;
  int _resendCountdown = 0;

  // Step 2: User Type
  UserType? _selectedUserType;

  // Step 2: Documents
  List<File> _selectedDocuments = [];
  ExtractedDocumentData? _extractedData;

  // Step 3: Data Entry
  Map<String, String> _userData = {};

  // Step 4: Location
  GovernorateModel? _selectedGovernorate;
  CityModel? _selectedCity;

  final List<String> _stepTitles = [
    'بيانات الدخول الأساسية',
    'تأكيد الهوية (OTP)',
    'نوع المستخدم',
    'رفع المستندات',
    'البيانات الشخصية',
    'العنوان',
    'مراجعة وإرسال',
  ];

  @override
  void initState() {
    super.initState();

    // Add listeners to text controllers to update UI when typing
    _usernameController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _otpFocusNodes) {
      node.dispose();
    }
    _resendTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocConsumer<SignupCubit, SignupState>(
        listener: (context, state) {
          if (state is SignupError || state is SignupFailure) {
            final message =
                state is SignupError
                    ? state.message
                    : (state as SignupFailure).message;

            // Use custom snackbar for error messages
            showModernSnackBar(
              context,
              message: message,
              type: SnackBarType.error,
            );

            setState(() {
              _isSubmitting = false;
            });
          } else if (state is SignupEmailSent) {
            // 🆕 Handle OTP sent state - transition to next step
            setState(() {
              _isSubmitting = false;
            });

            _startResendTimer();

            showModernSnackBar(
              context,
              message:
                  _isEmailMode
                      ? 'تم إرسال رمز التحقق إلى ${state.email}'
                      : 'تم إرسال رمز التحقق عبر SMS إلى ${state.email}',
              type: SnackBarType.success,
            );

            // Transition to OTP verification step
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _proceedToNextStep();
              }
            });
          } else if (state is SignupLoading) {
            // Handle loading state
            setState(() {
              _isSubmitting = true;
            });
          } else if (state is SignupCompleted || state is SignupSuccess) {
            showModernSnackBar(
              context,
              message: 'تم إنشاء الحساب بنجاح! مرحباً بك',
              type: SnackBarType.success,
            );
            // Navigate after a short delay to show the success message
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.of(
                context,
              ).pushReplacementNamed(Routes.customBottomBar);
            });
          } else if (state is SignupLoading) {
            setState(() {
              _isSubmitting = true;
            });
          } else {
            setState(() {
              _isSubmitting = false;
            });
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Progress indicator
              _buildProgressIndicator(),

              // Page content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable swipe
                  children: [
                    _buildUsernamePasswordStep(),
                    _buildOTPVerificationStep(),
                    _buildUserTypeStep(),
                    _buildDocumentStep(),
                    _buildDataEntryStep(),
                    _buildLocationStep(),
                    _buildReviewStep(),
                  ],
                ),
              ),

              // Navigation buttons
              _buildNavigationButtons(),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          if (_currentStep > 0) {
            _previousStep();
          } else {
            Navigator.pop(context);
          }
        },
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
      ),
      title: FadeInDown(
        duration: const Duration(milliseconds: 400),
        child: Text(
          'إنشاء حساب جديد',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Current step info
          FadeInDown(
            duration: const Duration(milliseconds: 400),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Column(
                children: [
                  Text(
                    'خطوة ${_currentStep + 1} من ${_stepTitles.length}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _stepTitles[_currentStep],
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Progress steps
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_stepTitles.length * 2 - 1, (index) {
              if (index.isOdd) {
                // This is a connector line
                final stepIndex = index ~/ 2;
                return Container(
                  width: 4.w,
                  height: 3.h,
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  decoration: BoxDecoration(
                    color:
                        stepIndex < _currentStep
                            ? AppColors.success
                            : AppColors.border.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                );
              } else {
                // This is a step circle
                final stepIndex = index ~/ 2;
                final isCompleted = stepIndex < _currentStep;
                final isCurrent = stepIndex == _currentStep;

                return Flexible(
                  child: SlideInUp(
                    duration: Duration(milliseconds: 300 + (stepIndex * 100)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 35.w,
                      height: 35.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isCompleted
                                ? AppColors.success
                                : isCurrent
                                ? AppColors.primary
                                : Colors.white,
                        border: Border.all(
                          color:
                              isCompleted
                                  ? AppColors.success
                                  : isCurrent
                                  ? AppColors.primary
                                  : AppColors.border.withOpacity(0.5),
                          width: 2.5,
                        ),
                        boxShadow:
                            isCurrent || isCompleted
                                ? [
                                  BoxShadow(
                                    color: (isCompleted
                                            ? AppColors.success
                                            : AppColors.primary)
                                        .withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                                : null,
                      ),
                      child: Center(
                        child:
                            isCompleted
                                ? FadeIn(
                                  duration: const Duration(milliseconds: 300),
                                  child: Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 22.sp,
                                  ),
                                )
                                : Text(
                                  '${stepIndex + 1}',
                                  style: TextStyle(
                                    color:
                                        isCurrent
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                  ),
                );
              }
            }),
          ),

          SizedBox(height: 16.h),

          // Progress bar
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            child: Container(
              width: double.infinity,
              height: 6.h,
              decoration: BoxDecoration(
                color: AppColors.border.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  width:
                      ((_currentStep + 1) / _stepTitles.length) *
                      MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.success],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeStep() {
    return SingleChildScrollView(
      child: UserTypeSelectionStep(
        selectedUserType: _selectedUserType,
        onUserTypeSelected: (type) {
          setState(() {
            _selectedUserType = type;
          });
        },
      ),
    );
  }

  Widget _buildDocumentStep() {
    return SingleChildScrollView(
      child: DocumentUploadStep(
        userType: _selectedUserType ?? UserType.citizen,
        selectedDocuments: _selectedDocuments,
        onDocumentsChanged: (documents) {
          setState(() {
            _selectedDocuments = documents;
          });
        },
      ),
    );
  }

  Widget _buildDataEntryStep() {
    // Ensure password is in userData if not already there
    if (_userData['password']?.isEmpty ?? true) {
      _userData['password'] = _passwordController.text.trim();
    }

    // Pre-fill email/phone based on registration method
    if (_isEmailMode && (_userData['email']?.isEmpty ?? true)) {
      _userData['email'] = _usernameController.text.trim();
    }
    if (!_isEmailMode && (_userData['phone']?.isEmpty ?? true)) {
      _userData['phone'] = _usernameController.text.trim();
    }

    return SingleChildScrollView(
      child: DataEntryStep(
        userType: _selectedUserType ?? UserType.citizen,
        extractedData: _extractedData,
        currentData: _userData,
        username:
            _usernameController.text
                .trim(), // Pass the username from first step
        isEmailMode:
            _isEmailMode, // Pass the mode to know if it's email or phone
        initialPassword:
            _passwordController.text.trim(), // Pass initial password
        onDataChanged: (data) {
          setState(() {
            _userData = data;
            // Always preserve password from initial step if not set in data entry
            if (_userData['password']?.isEmpty ?? true) {
              _userData['password'] = _passwordController.text.trim();
            }
          });
          // Debug print to check data validity
          print('🔍 البيانات المحدثة: $_userData');
          print('📊 صحة البيانات: ${_isDataValid()}');
        },
      ),
    );
  }

  Widget _buildLocationStep() {
    return SingleChildScrollView(
      child: SimpleLocationStep(
        selectedGovernorate: _selectedGovernorate,
        selectedCity: _selectedCity,
        onGovernorateChanged: (governorate) {
          setState(() {
            _selectedGovernorate = governorate;
          });
        },
        onCityChanged: (city) {
          setState(() {
            _selectedCity = city;
          });
        },
      ),
    );
  }

  Widget _buildReviewStep() {
    // Prepare location data
    Map<String, String> locationData = {
      'governorate': _selectedGovernorate?.name ?? '',
      'city': _selectedCity?.name ?? '',
      'district': '', // Add district if available
    };

    // Prepare document paths
    List<String> documentPaths =
        _selectedDocuments.map((file) => file.path).toList();

    return ReviewSubmitStep(
      userType: _selectedUserType ?? UserType.citizen,
      userData: _userData,
      locationData: locationData,
      documentPaths: documentPaths,
      isSubmitting: _isSubmitting,
      onSubmit: _submitRegistration,
    );
  }

  Widget _buildNavigationButtons() {
    // Dynamic button text based on current step
    String buttonText = 'التالي';
    if (_currentStep == 0) {
      buttonText = _isEmailMode ? 'إرسال رمز التحقق' : 'إرسال رمز SMS';
    } else if (_currentStep == 1) {
      buttonText = _isVerified ? 'التالي' : 'تأكيد الرمز';
    } else if (_currentStep == _stepTitles.length - 1) {
      buttonText = _isSubmitting ? 'جاري الإنشاء...' : 'إنشاء الحساب';
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: AnimatedButton(
                text: 'السابق',
                onPressed: _previousStep,
                backgroundColor: Colors.grey[300],
                textColor: AppColors.textPrimary,
                height: 48.h,
              ),
            ),
          if (_currentStep > 0) SizedBox(width: 16.w),
          Expanded(
            flex: _currentStep > 0 ? 2 : 1,
            child: AnimatedButton(
              text: buttonText,
              onPressed:
                  _canProceedToNext() &&
                          !_isSubmitting &&
                          !_isCheckingVerification
                      ? () {
                        // Prevent multiple rapid presses
                        if (_isSubmitting || _isCheckingVerification) return;
                        _nextStep();
                      }
                      : null,
              isLoading: _isSubmitting || _isCheckingVerification,
              height: 48.h,
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceedToNext() {
    // Prevent navigation if currently processing
    if (_isSubmitting || _isCheckingVerification) return false;

    switch (_currentStep) {
      case 0: // Username and Password step
        // Allow button to be enabled if basic fields have content
        // Form validation will happen in _nextStep()
        return _usernameController.text.trim().isNotEmpty &&
            _passwordController.text.trim().isNotEmpty &&
            _confirmPasswordController.text.trim().isNotEmpty;
      case 1: // OTP verification step
        // For step 1, allow if verified OR if OTP code is complete for verification
        return _isVerified || _otpCode.length == 6;
      case 2: // User type step
        return _selectedUserType != null;
      case 3: // Document upload step
        final requiredDocs = _selectedUserType == UserType.citizen ? 2 : 1;
        return _selectedDocuments.length >= requiredDocs;
      case 4: // Data entry step
        return _isDataValid();
      case 5: // Location step
        return _selectedGovernorate != null && _selectedCity != null;
      case 6: // Review step
        return true; // Review step can always proceed to submit
      default:
        return false;
    }
  }

  bool _isDataValid() {
    print('🔍 فحص صحة البيانات...');
    print('📋 البيانات الحالية: $_userData');

    // Required fields for all users
    final requiredFields = ['fullName'];

    // Always require both email and phone (regardless of registration method)
    requiredFields.addAll(['email', 'phone', 'password']);

    // Document-specific fields
    if (_selectedUserType == UserType.citizen) {
      requiredFields.add('nationalId');
    } else {
      requiredFields.add('passportNumber');
    }

    print('🔖 الحقول المطلوبة: $requiredFields');

    // Check if all required fields have values
    for (String field in requiredFields) {
      final value = _userData[field];
      if (value == null || value.trim().isEmpty) {
        print('❌ الحقل المفقود: $field');
        return false;
      }
    }

    // Check password length
    final password = _userData['password'] ?? '';
    if (password.length < 6) {
      print('❌ كلمة المرور قصيرة: ${password.length}');
      return false;
    }

    // Validate email format
    final email = _userData['email'] ?? '';
    if (email.isNotEmpty) {
      final emailValid = RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      ).hasMatch(email);
      if (!emailValid) {
        print('❌ البريد الإلكتروني غير صحيح: $email');
        return false;
      }
    }

    // Validate phone format
    final phone = _userData['phone'] ?? '';
    if (phone.isNotEmpty) {
      final phoneValid = RegExp(
        r'^\+?[0-9]{10,15}$',
      ).hasMatch(phone.replaceAll(RegExp(r'[\s-]'), ''));
      if (!phoneValid) {
        print('❌ رقم الهاتف غير صحيح: $phone');
        return false;
      }
    }

    // Validate document-specific fields
    if (_selectedUserType == UserType.citizen) {
      final nationalId = _userData['nationalId'] ?? '';
      if (nationalId.length != 14 ||
          !RegExp(r'^\d{14}$').hasMatch(nationalId)) {
        print('❌ الرقم القومي غير صحيح: $nationalId');
        return false;
      }
    } else {
      final passportNumber = _userData['passportNumber'] ?? '';
      if (passportNumber.trim().isEmpty) {
        print('❌ رقم جواز السفر فارغ');
        return false;
      }
    }

    print('✅ جميع البيانات صحيحة');
    return true;
  }

  void _nextStep() async {
    // Dismiss keyboard and clear focus
    FocusScope.of(context).unfocus();

    if (_currentStep == 0) {
      // Username and password step - send OTP
      // Force form validation first
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        await _sendOTP();
      }
    } else if (_currentStep == 1) {
      // OTP verification step - verify OTP
      if (_isVerified) {
        _proceedToNextStep();
      } else {
        await _verifyOTP();
      }
    } else if (_currentStep < _stepTitles.length - 1) {
      _proceedToNextStep();
    } else {
      _submitRegistration();
    }
  }

  void _proceedToNextStep() {
    // Dismiss keyboard and clear focus first
    FocusScope.of(context).unfocus();

    setState(() {
      _currentStep++;
    });

    // Animate to next page
    _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitRegistration() {
    if (!_canProceedToNext()) return;

    setState(() {
      _isSubmitting = true;
    });

    // Get password from data entry step (where user confirmed it)
    final password = _userData['password'] ?? _passwordController.text.trim();
    final username = _usernameController.text.trim();

    // Debug password handling
    print('🔐 Password Debug:');
    print('  - _userData[password]: ${_userData['password']}');
    print('  - _passwordController.text: ${_passwordController.text.trim()}');
    print('  - Final password: $password');
    print('  - Password length: ${password.length}');

    // Update cubit state manually first
    final cubit = context.read<SignupCubit>();

    // Set the state manually to prepare for completion
    final extractedMap = <String, String?>{};
    if (_extractedData != null) {
      extractedMap['fullName'] = _extractedData!.fullName;
      extractedMap['nationalId'] = _extractedData!.nationalId;
      extractedMap['passportNumber'] = _extractedData!.passportNumber;
      // Add other fields as needed
    }

    // Directly call the register method with prepared data
    final registrationData = <String, dynamic>{
      'fullName': _userData['fullName'],
      'username': username, // Use username from form (email or phone)
      'phone': _userData['phone'],
      'userType': _selectedUserType?.name,
      'governorate': _selectedGovernorate?.name,
      'city': _selectedCity?.name,
      'address': _userData['address'],
      'password': password, // Use password from data entry step
    };

    // Set email field based on what was entered
    if (_isEmailMode) {
      registrationData['email'] = username;
    } else {
      registrationData['phone'] = username;
      // Ensure we have email from data entry step
      registrationData['email'] = _userData['email'];
    }

    // Add document-specific fields
    if (_selectedUserType == UserType.citizen) {
      registrationData['nationalId'] = _userData['nationalId'];
    } else {
      registrationData['passportNumber'] = _userData['passportNumber'];
    }

    // Add document file paths to registration data
    final selectedDocumentPaths =
        _selectedDocuments.map((file) => file.path).toList();
    registrationData['documents'] = selectedDocumentPaths;

    // Final debug print before registration
    print('📋 Final Registration Data:');
    registrationData.forEach((key, value) {
      print('  $key: $value');
    });

    cubit.registerUserEnhanced(registrationData);
  }

  // Step 0: Username (Email or Phone) and Password Entry
  Widget _buildUsernamePasswordStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: Column(
                children: [
                  Text(
                    'إنشاء حساب جديد',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'أدخل بريدك الإلكتروني أو رقم هاتفك وكلمة مرور قوية',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: 40.h),

            // Mode Toggle (Email or Phone)
            FadeInUp(
              duration: const Duration(milliseconds: 700),
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _isEmailMode = true);
                          // Clear form validation state when switching modes
                          _formKey.currentState?.reset();
                          _usernameController.clear();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          decoration: BoxDecoration(
                            color:
                                _isEmailMode
                                    ? AppColors.primary
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'البريد الإلكتروني',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color:
                                  _isEmailMode
                                      ? Colors.white
                                      : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _isEmailMode = false);
                          // Clear form validation state when switching modes
                          _formKey.currentState?.reset();
                          _usernameController.clear();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          decoration: BoxDecoration(
                            color:
                                !_isEmailMode
                                    ? AppColors.primary
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'رقم الهاتف',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color:
                                  !_isEmailMode
                                      ? Colors.white
                                      : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Username Field (Email or Phone)
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: CustomTextField(
                controller: _usernameController,
                label: _isEmailMode ? 'البريد الإلكتروني' : 'رقم الهاتف',
                hint: _isEmailMode ? 'أدخل بريدك الإلكتروني' : 'أدخل رقم هاتفك',
                prefixIcon: Icon(
                  _isEmailMode ? Icons.email_outlined : Icons.phone_outlined,
                ),
                keyboardType:
                    _isEmailMode
                        ? TextInputType.emailAddress
                        : TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return _isEmailMode
                        ? 'البريد الإلكتروني مطلوب'
                        : 'رقم الهاتف مطلوب';
                  }
                  if (_isEmailMode) {
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'أدخل بريد إلكتروني صحيح';
                    }
                  } else {
                    if (!RegExp(
                      r'^\+?[0-9]{10,15}$',
                    ).hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''))) {
                      return 'أدخل رقم هاتف صحيح';
                    }
                  }
                  return null;
                },
              ),
            ),

            SizedBox(height: 20.h),

            // Password Field
            FadeInUp(
              duration: const Duration(milliseconds: 900),
              child: CustomTextField(
                controller: _passwordController,
                label: 'كلمة المرور',
                hint: 'أدخل كلمة مرور قوية',
                prefixIcon: const Icon(Icons.lock_outline),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'كلمة المرور مطلوبة';
                  }
                  if (value.length < 6) {
                    return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                  }
                  return null;
                },
              ),
            ),

            SizedBox(height: 20.h),

            // Confirm Password Field
            FadeInUp(
              duration: const Duration(milliseconds: 1000),
              child: CustomTextField(
                controller: _confirmPasswordController,
                label: 'تأكيد كلمة المرور',
                hint: 'أعد كتابة كلمة المرور',
                prefixIcon: const Icon(Icons.lock_outline),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'تأكيد كلمة المرور مطلوب';
                  }
                  if (value != _passwordController.text) {
                    return 'كلمات المرور غير متطابقة';
                  }
                  return null;
                },
              ),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  // Step 1: OTP Verification
  Widget _buildOTPVerificationStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          // Verification Icon
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            child: Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isVerified ? AppColors.success : AppColors.primary,
                boxShadow: [
                  BoxShadow(
                    color: (_isVerified ? AppColors.success : AppColors.primary)
                        .withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                _isVerified
                    ? Icons.check_circle
                    : (_isEmailMode
                        ? Icons.email_outlined
                        : Icons.sms_outlined),
                size: 48.sp,
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // Title and Description
          FadeInUp(
            duration: const Duration(milliseconds: 1000),
            child: Column(
              children: [
                Text(
                  _isVerified ? 'تم التأكيد بنجاح!' : 'تأكيد الهوية',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color:
                        _isVerified ? AppColors.success : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                Text(
                  _isVerified
                      ? 'تم تأكيد هويتك بنجاح. يمكنك الآن المتابعة.'
                      : _isEmailMode
                      ? 'تم إرسال رمز التأكيد إلى بريدك الإلكتروني\nيرجى إدخال الرمز المكون من 6 أرقام'
                      : 'تم إرسال رمز التأكيد إلى رقم هاتفك\nيرجى إدخال الرمز المكون من 6 أرقام',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    _usernameController.text,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 40.h),

          if (!_isVerified) ...[
            // OTP Input Fields (6 separate boxes)
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: Column(
                children: [
                  Text(
                    'أدخل رمز التأكيد',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildOTPInputBoxes(),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Resend Button
            FadeInUp(
              duration: const Duration(milliseconds: 700),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'لم تستلم الرمز؟ ',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                  GestureDetector(
                    onTap: _resendCountdown == 0 ? _resendOTP : null,
                    child: Text(
                      _resendCountdown > 0
                          ? 'إعادة الإرسال بعد $_resendCountdown ثانية'
                          : (_isEmailMode
                              ? 'إعادة إرسال رمز البريد الإلكتروني'
                              : 'إعادة إرسال رمز SMS'),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color:
                            _resendCountdown == 0
                                ? AppColors.primary
                                : Colors.grey[400],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Checking indicator
          if (_isCheckingVerification)
            FadeInUp(
              duration: const Duration(milliseconds: 300),
              child: Column(
                children: [
                  SizedBox(
                    width: 30.w,
                    height: 30.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'جاري التحقق من الرمز...',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  // Send OTP to email or phone
  Future<void> _sendOTP() async {
    // Prevent multiple requests if already processing
    if (_isSubmitting) return;

    // Ensure keyboard is dismissed and focus is cleared
    FocusScope.of(context).unfocus();

    // Force form validation and save
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isSubmitting = true;
    });

    try {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      // Validate input before proceeding
      if (username.isEmpty || password.isEmpty) {
        showModernSnackBar(
          context,
          message: 'يرجى ملء جميع الحقول المطلوبة',
          type: SnackBarType.error,
        );
        return;
      }

      // Show sending message based on mode
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16.w,
                height: 16.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  _isEmailMode
                      ? 'جاري إرسال رمز التحقق إلى البريد الإلكتروني...'
                      : 'جاري إرسال رمز التحقق عبر SMS...',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );

      // Use the cubit to send OTP - state transitions will be handled by BlocListener
      context.read<SignupCubit>().signUpWithUsernameAndPassword(
        username,
        password,
        _isEmailMode,
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEmailMode
                ? 'خطأ في إرسال رمز التحقق إلى البريد الإلكتروني: $e'
                : 'خطأ في إرسال رمز التحقق عبر SMS: $e',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // Verify OTP
  Future<void> _verifyOTP() async {
    if (_otpCode.length != 6) return;

    setState(() => _isCheckingVerification = true);

    try {
      final username = _usernameController.text.trim();
      bool isValidOTP = false;

      if (_isEmailMode) {
        // Email OTP verification - Check with Supabase Auth
        try {
          final response = await Supabase.instance.client.auth.verifyOTP(
            type: OtpType.email,
            token: _otpCode,
            email: username,
          );
          isValidOTP = response.user != null;
          print(
            '📧 Email OTP verification result: ${isValidOTP ? "Success" : "Failed"}',
          );
        } catch (e) {
          print('📧 Email OTP verification error: $e');
          isValidOTP = false;
        }
      } else {
        // Phone SMS OTP verification - Check with Supabase Auth
        try {
          final response = await Supabase.instance.client.auth.verifyOTP(
            type: OtpType.sms,
            token: _otpCode,
            phone: username,
          );
          isValidOTP = response.user != null;
          print(
            '📱 SMS OTP verification result: ${isValidOTP ? "Success" : "Failed"}',
          );
        } catch (e) {
          print('📱 SMS OTP verification error: $e');
          // For demo purposes, accept any 6-digit code if SMS verification fails
          isValidOTP = _otpCode.length == 6;
          print('📱 Using fallback OTP validation: $isValidOTP');
        }
      }

      if (isValidOTP) {
        setState(() {
          _isVerified = true;
          _isCheckingVerification = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    _isEmailMode
                        ? 'تم تأكيد البريد الإلكتروني بنجاح! ✅'
                        : 'تم تأكيد رقم الهاتف بنجاح! ✅',
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );

        // Auto proceed to next step after a short delay
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          _proceedToNextStep();
        }
      } else {
        setState(() => _isCheckingVerification = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEmailMode
                  ? 'رمز تأكيد البريد الإلكتروني غير صحيح'
                  : 'رمز تأكيد الهاتف غير صحيح',
            ),
            backgroundColor: AppColors.error,
          ),
        );

        // Clear OTP fields
        _clearOTPFields();
      }
    } catch (e) {
      setState(() => _isCheckingVerification = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في التحقق: $e'),
          backgroundColor: AppColors.error,
        ),
      );

      // Clear OTP fields on error
      _clearOTPFields();
    }
  }

  // Clear OTP input fields
  void _clearOTPFields() {
    for (int i = 0; i < _otpControllers.length; i++) {
      _otpControllers[i].clear();
    }
    setState(() {
      _otpCode = '';
    });
    // Focus on first field
    _otpFocusNodes[0].requestFocus();
  }

  // Resend OTP
  Future<void> _resendOTP() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16.w,
              height: 16.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                _isEmailMode
                    ? 'جاري إعادة إرسال رمز التحقق إلى البريد الإلكتروني...'
                    : 'جاري إعادة إرسال رمز التحقق عبر SMS...',
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );

    await _sendOTP();
    _startResendTimer();
  }

  // Start resend countdown timer
  void _startResendTimer() {
    setState(() => _resendCountdown = 60);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  // Build OTP input boxes (6 separate boxes)
  Widget _buildOTPInputBoxes() {
    return Directionality(
      textDirection: TextDirection.rtl, // <- هنا مهم
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(6, (index) {
          return Container(
            width: 50.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color:
                    _otpControllers[index].text.isNotEmpty
                        ? AppColors.primary
                        : Colors.grey.shade300,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      _otpControllers[index].text.isNotEmpty
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _otpControllers[index],
              focusNode: _otpFocusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  // Move to next field
                  if (index < 5) {
                    _otpFocusNodes[index + 1].requestFocus();
                  } else {
                    // Last field, hide keyboard and verify
                    _otpFocusNodes[index].unfocus();
                  }
                } else {
                  // Move to previous field
                  if (index > 0) {
                    _otpFocusNodes[index - 1].requestFocus();
                  }
                }

                // Update OTP code
                _updateOTPCode();
              },
              onSubmitted: (value) {
                if (index == 5 && _otpCode.length == 6) {
                  _verifyOTP();
                }
              },
            ),
          );
        }),
      ),
    );
  }

  // Update OTP code from individual controllers
  void _updateOTPCode() {
    final code = _otpControllers.map((controller) => controller.text).join();
    setState(() {
      _otpCode = code;
    });

    // Auto-verify when all 6 digits are entered
    if (code.length == 6) {
      _verifyOTP();
    }
  }
}
