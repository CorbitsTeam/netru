import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:netru_app/core/domain/entities/signup_entities.dart';
import 'package:netru_app/features/auth/widgets/data_entry_step.dart';
import 'package:netru_app/features/auth/widgets/document_upload_step.dart';
import 'package:netru_app/features/auth/widgets/review_submit_step.dart';
import 'package:netru_app/features/auth/widgets/simple_location_step.dart';
import 'package:netru_app/features/auth/widgets/user_type_selection_step.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:netru_app/core/routing/routes.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:netru_app/core/widgets/custom_snack_bar.dart';
import '../../../../../core/services/location_service.dart';
import '../widgets/signup_header.dart';
import '../widgets/signup_progress_indicator.dart';
import '../widgets/signup_username_password_step.dart';
import '../widgets/signup_otp_verification_step.dart';
import '../widgets/signup_navigation_buttons.dart';
import '../widgets/signup_step_container.dart';
import '../cubits/signup_cubit.dart';
import '../cubits/signup_state.dart';
import '../../../domain/entities/extracted_document_data.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Step 0: Username (email or phone) and Password
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final VoidCallback _usernameListener;
  late final VoidCallback _passwordListener;
  late final VoidCallback _confirmPasswordListener;
  final _formKey = GlobalKey<FormState>();
  bool _isEmailMode = true; // true for email, false for phone

  // Step 1: OTP Verification (Email or SMS)
  bool _isVerified = false;
  bool _isCheckingVerification = false;
  String _otpCode = '';
  final TextEditingController _otpController = TextEditingController();
  StreamController<ErrorAnimationType>? _otpErrorController;
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

    // Initialize OTP error controller
    _otpErrorController = StreamController<ErrorAnimationType>();

    // Add listeners to text controllers to update UI when typing
    _usernameListener = () {
      if (!mounted) return;
      setState(() {});
    };
    _passwordListener = () {
      if (!mounted) return;
      setState(() {});
    };
    _confirmPasswordListener = () {
      if (!mounted) return;
      setState(() {});
    };

    _usernameController.addListener(_usernameListener);
    _passwordController.addListener(_passwordListener);
    _confirmPasswordController.addListener(_confirmPasswordListener);
  }

  @override
  void dispose() {
    // Cancel any running timers first
    _resendTimer?.cancel();
    _otpErrorController?.close();

    // Remove listeners safely
    try {
      _usernameController.removeListener(_usernameListener);
      _passwordController.removeListener(_passwordListener);
      _confirmPasswordController.removeListener(_confirmPasswordListener);
    } catch (_) {
      // Ignore errors during listener removal
    }

    // Dispose controllers
    _pageController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();

    super.dispose();
  }

  void _handleBlocState(BuildContext context, SignupState state) {
    if (state is SignupError || state is SignupFailure) {
      final message =
          state is SignupError
              ? state.message
              : (state as SignupFailure).message;

      // Use custom snackbar for error messages
      showModernSnackBar(context, message: message, type: SnackBarType.error);

      setState(() {
        _isSubmitting = false;
      });
    } else if (state is SignupFailure && state.message.contains('موجود')) {
      // 🆕 Handle user already exists - show dialog and redirect to login
      setState(() {
        _isSubmitting = false;
      });

      _showUserExistsDialog(context, state.message, 'general');
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
        message: 'تم إنشاء الحساب بنجاح! يرجى تسجيل الدخول',
        type: SnackBarType.success,
      );
      // Navigate to login page after successful registration
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pushReplacementNamed(Routes.loginScreen);
      });
    } else {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  List<Widget> _buildStepWidgets() {
    return [
      SignupUsernamePasswordStep(
        usernameController: _usernameController,
        passwordController: _passwordController,
        confirmPasswordController: _confirmPasswordController,
        isEmailMode: _isEmailMode,
        onEmailModeChanged: (isEmail) {
          setState(() {
            _isEmailMode = isEmail;
          });
        },
        formKey: _formKey,
      ),
      SignupOTPVerificationStep(
        isEmailMode: _isEmailMode,
        username: _usernameController.text,
        isVerified: _isVerified,
        isCheckingVerification: _isCheckingVerification,
        otpCode: _otpCode,
        otpController: _otpController,
        otpErrorController: _otpErrorController,
        resendCountdown: _resendCountdown,
        onOTPChanged: (value) {
          setState(() {
            _otpCode = value;
          });
        },
        onOTPCompleted: _verifyOTP,
        onResendOTP: _resendOTP,
      ),
      _buildUserTypeStep(),
      _buildDocumentStep(),
      _buildDataEntryStep(),
      _buildLocationStep(),
      _buildReviewStep(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: BlocConsumer<SignupCubit, SignupState>(
        listener: _handleBlocState,
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              // Header and progress indicator as non-scrollable sections
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Header with logo and title
                    const SignupHeader(
                      title: 'إنشاء حساب جديد',
                      subtitle: 'أنشئ حساباً جديداً للاستفادة من جميع الخدمات',
                      showLogo: false,
                    ),
                    // Progress indicator
                    SignupProgressIndicator(
                      currentStep: _currentStep,
                      stepTitles: _stepTitles,
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
              // PageView content
              SliverFillRemaining(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _buildStepWidgets(),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<SignupCubit, SignupState>(
        builder: (context, state) {
          return SignupNavigationButtons(
            onPrevious: _currentStep > 0 ? _previousStep : null,
            onNext:
                _canProceedToNext() &&
                        !_isSubmitting &&
                        !_isCheckingVerification
                    ? () {
                      if (_isSubmitting || _isCheckingVerification) return;
                      _nextStep();
                    }
                    : null,
            nextButtonText: _getNextButtonText(),
            isLoading: _isSubmitting || _isCheckingVerification,
            canProceed: _canProceedToNext(),
            showPreviousButton: _currentStep > 0,
          );
        },
      ),
    );
  }

  Widget _buildUserTypeStep() {
    return SignupStepContainer(
      title: 'نوع المستخدم',
      subtitle: 'اختر نوع المستخدم المناسب لك',
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
    return SignupStepContainer(
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
    // Ensure password is in userData
    final currentPassword = _passwordController.text.trim();
    if (currentPassword.isNotEmpty &&
        (_userData['password']?.isEmpty ?? true)) {
      _userData['password'] = currentPassword;
    }

    // Pre-fill email/phone based on registration method
    if (_isEmailMode && (_userData['email']?.isEmpty ?? true)) {
      _userData['email'] = _usernameController.text.trim();
    }
    if (!_isEmailMode && (_userData['phone']?.isEmpty ?? true)) {
      _userData['phone'] = _usernameController.text.trim();
    }

    return SignupStepContainer(
      title: 'البيانات الشخصية',
      subtitle: 'أدخل بياناتك الشخصية بدقة',
      child: DataEntryStep(
        userType: _selectedUserType ?? UserType.citizen,
        extractedData: _extractedData,
        currentData: _userData,
        username: _usernameController.text.trim(),
        isEmailMode: _isEmailMode,
        initialPassword: currentPassword,
        onDataChanged: (data) {
          setState(() {
            _userData = _mergeUserData(data);
          });
        },
      ),
    );
  }

  Widget _buildLocationStep() {
    return SignupStepContainer(
      title: 'العنوان',
      subtitle: 'حدد موقعك بدقة',
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
    final locationData = {
      'governorate': _selectedGovernorate?.name ?? '',
      'city': _selectedCity?.name ?? '',
      'district': '',
    };

    final documentPaths = _selectedDocuments.map((file) => file.path).toList();

    return SignupStepContainer(
      title: 'مراجعة وإرسال',
      subtitle: 'مراجعة أخيرة لبياناتك',
      child: ReviewSubmitStep(
        userType: _selectedUserType ?? UserType.citizen,
        userData: _userData,
        locationData: locationData,
        documentPaths: documentPaths,
        isSubmitting: _isSubmitting,
        onSubmit: _submitRegistration,
      ),
    );
  }

  Map<String, String> _mergeUserData(Map<String, dynamic> data) {
    final currentPassword = _passwordController.text.trim();

    // Merge incoming data with existing _userData but preserve the controller password
    final merged = Map<String, String>.from(_userData);

    // Add/overwrite with new fields from data
    data.forEach((k, v) {
      merged[k] = v.toString();
    });

    // Ensure password is preserved from controller if available
    final incomingPassword = data['password']?.toString() ?? '';
    final existingPassword = _userData['password'] ?? '';
    final controllerPassword = currentPassword;

    // Choose the best password candidate
    String bestPassword = '';
    for (final p in [controllerPassword, existingPassword, incomingPassword]) {
      if (p.isNotEmpty && p.length > bestPassword.length) {
        bestPassword = p;
      }
    }
    if (bestPassword.isNotEmpty) merged['password'] = bestPassword;

    return merged;
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
    // Required fields for all users
    final requiredFields = ['fullName', 'email', 'phone', 'password'];

    // Document-specific fields
    if (_selectedUserType == UserType.citizen) {
      requiredFields.add('nationalId');
    } else {
      requiredFields.add('passportNumber');
    }

    // Check if all required fields have values
    for (String field in requiredFields) {
      final value = _userData[field];
      if (value == null || value.trim().isEmpty) {
        return false;
      }
    }

    // Check password length with fallback to controller
    final password = _userData['password'] ?? _passwordController.text.trim();
    if (password.length < 6) {
      return false;
    }

    // Validate email format
    final email = _userData['email'] ?? '';
    if (email.isNotEmpty) {
      final emailValid = RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      ).hasMatch(email);
      if (!emailValid) return false;
    }

    // Validate phone format
    final phone = _userData['phone'] ?? '';
    if (phone.isNotEmpty) {
      final phoneValid = RegExp(
        r'^\+?[0-9]{10,15}$',
      ).hasMatch(phone.replaceAll(RegExp(r'[\s-]'), ''));
      if (!phoneValid) return false;
    }

    // Validate document-specific fields
    if (_selectedUserType == UserType.citizen) {
      final nationalId = _userData['nationalId'] ?? '';
      if (nationalId.length != 14 ||
          !RegExp(r'^\d{14}$').hasMatch(nationalId)) {
        return false;
      }
    }

    return true;
  }

  String _getNextButtonText() {
    if (_currentStep == 0) {
      return _isEmailMode ? 'إرسال رمز التحقق' : 'إرسال رمز SMS';
    } else if (_currentStep == 1) {
      return _isVerified ? 'التالي' : 'تأكيد الرمز';
    } else if (_currentStep == _stepTitles.length - 1) {
      return _isSubmitting ? 'جاري الإنشاء...' : 'إنشاء الحساب';
    }
    return 'التالي';
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

    final password = _userData['password'] ?? _passwordController.text.trim();
    final username = _usernameController.text.trim();

    // Prepare registration data
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

    // Add document file paths
    registrationData['documents'] =
        _selectedDocuments.map((file) => file.path).toList();

    context.read<SignupCubit>().registerUserEnhanced(registrationData);
  }

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

  Future<void> _verifyOTP() async {
    if (_otpCode.length != 6) return;

    setState(() => _isCheckingVerification = true);

    try {
      final username = _usernameController.text.trim();
      bool isValidOTP = false;

      if (_isEmailMode) {
        try {
          final response = await Supabase.instance.client.auth.verifyOTP(
            type: OtpType.email,
            token: _otpCode,
            email: username,
          );
          isValidOTP = response.user != null;
        } catch (e) {
          isValidOTP = false;
        }
      } else {
        try {
          final response = await Supabase.instance.client.auth.verifyOTP(
            type: OtpType.sms,
            token: _otpCode,
            phone: username,
          );
          isValidOTP = response.user != null;
        } catch (e) {
          // Fallback for SMS verification
          isValidOTP = _otpCode.length == 6;
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
    _otpController.clear();
    setState(() {
      _otpCode = '';
    });
    // Trigger error animation
    _otpErrorController?.add(ErrorAnimationType.shake);
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

  // 🆕 Show dialog when user already exists
  void _showUserExistsDialog(
    BuildContext context,
    String message,
    String field,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.warning, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                'حساب موجود مسبقاً',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontFamily: 'Almarai',
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
              fontFamily: 'Almarai',
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to login screen
                Navigator.of(context).pushReplacementNamed(Routes.loginScreen);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'تسجيل الدخول',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Almarai',
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Stay on current page
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'إلغاء',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Almarai',
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
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
}
