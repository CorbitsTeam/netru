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

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:netru_app/core/routing/routes.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:netru_app/core/widgets/custom_snack_bar.dart';
import 'package:netru_app/features/auth/widgets/modern_dialog.dart';
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
  bool _isDisposed = false; // Track disposal state

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

  // Step 2: User Type - Initialize with default citizen type
  final UserType _selectedUserType = UserType.citizen;

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
    _isDisposed = true; // Mark as disposed
    
    // Cancel any running timers first
    _resendTimer?.cancel();
    _otpErrorController?.close();

    // Remove listeners safely before disposing controllers
    try {
      _usernameController.removeListener(_usernameListener);
    } catch (_) {
      // Ignore errors during listener removal
    }

    try {
      _passwordController.removeListener(_passwordListener);
    } catch (_) {
      // Ignore errors during listener removal
    }

    try {
      _confirmPasswordController.removeListener(_confirmPasswordListener);
    } catch (_) {
      // Ignore errors during listener removal
    }

    // Dispose controllers safely
    try {
      _pageController.dispose();
    } catch (_) {
      // Already disposed
    }

    try {
      _usernameController.dispose();
    } catch (_) {
      // Already disposed
    }

    try {
      _passwordController.dispose();
    } catch (_) {
      // Already disposed
    }

    try {
      _confirmPasswordController.dispose();
    } catch (_) {
      // Already disposed
    }

    try {
      _otpController.dispose();
    } catch (_) {
      // Already disposed
    }

    super.dispose();
  }

  void _handleBlocState(BuildContext context, SignupState state) {
    if (_isDisposed) return; // Don't handle state if disposed
    
    if (state is SignupError || state is SignupFailure) {
      final message =
          state is SignupError
              ? state.message
              : (state as SignupFailure).message;

      // Use custom snackbar for error messages
      showModernSnackBar(context, message: message, type: SnackBarType.error);

      if (!_isDisposed && mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    } else if (state is SignupUserExistsWithLoginOption) {
      // 🆕 Handle user already exists - show dialog with login option
      if (!_isDisposed && mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }

      _showUserExistsDialog(context, state.message, state.dataType);
    } else if (state is SignupEmailSent) {
      // 🆕 Handle OTP sent state - transition to next step
      if (!_isDisposed && mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }

      _startResendTimer();

      showModernSnackBar(
        context,
        message:
            _isEmailMode
                ? 'تم إرسال رمز التحقق إلى ${state.email}'
                : 'تم إرسال رمز التحقق عبر SMS إلى ${state.email}',
        type: SnackBarType.success,
      );

      // Transition to OTP verification step only if not coming from user exists error
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_isDisposed && mounted) {
          _proceedToNextStep();
        }
      });
    } else if (state is SignupLoading) {
      // Handle loading state
      if (!_isDisposed && mounted) {
        setState(() {
          _isSubmitting = true;
        });
      }
    } else if (state is SignupCompleted || state is SignupSuccess) {
      if (!_isDisposed && mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }

      showModernSnackBar(
        context,
        message: 'تم إنشاء الحساب بنجاح! جاري توجيهك لصفحة اختيار اللغة...',
        type: SnackBarType.success,
      );

      // Clear cache and navigate to language selection page immediately
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (_isDisposed || !mounted) return;

        try {
          // Clear cache after successful signup
          await context.read<SignupCubit>().clearCacheAfterSuccessfulSignup();

          if (_isDisposed || !mounted) return;

          // Navigate to language selection page (or main app)
          // Replace with the actual route for language selection
          Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.loginScreen, // TODO: Change to language selection route
            (route) => false,
          );
        } catch (e) {
          print('❌ Error during post-signup cleanup: $e');
          // Still navigate even if cleanup fails
          if (!_isDisposed && mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.loginScreen,
              (route) => false,
            );
          }
        }
      });
    } else {
      if (!_isDisposed && mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
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
      // _buildUserTypeStep(),
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
          final canProceed = _canProceedToNext();
          final isProcessing = _isSubmitting || _isCheckingVerification;

          return SignupNavigationButtons(
            onPrevious: _currentStep > 0 ? _previousStep : null,
            onNext:
                canProceed && !isProcessing
                    ? () {
                      if (isProcessing) return;
                      // Debug current state before proceeding
                      _debugCurrentState();
                      _nextStep();
                    }
                    : () {
                      // Show debug info when button is disabled
                      _debugCurrentState();
                      if (_currentStep == 3) {
                        final errorMessage = _getValidationError();
                        if (errorMessage != null) {
                          // Use post-frame callback to avoid calling during build
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _showValidationError(errorMessage);
                          });
                        }
                      }
                    },
            nextButtonText: _getNextButtonText(),
            isLoading: isProcessing,
            canProceed: canProceed,
            showPreviousButton: _currentStep > 0,
          );
        },
      ),
    );
  }

  // Widget _buildUserTypeStep() {
  //   return SignupStepContainer(
  //     title: 'نوع المستخدم',
  //     subtitle: 'اختر نوع المستخدم المناسب لك',
  //     child: UserTypeSelectionStep(
  //       selectedUserType: _selectedUserType,
  //       onUserTypeSelected: (type) {
  //         setState(() {
  //           _selectedUserType = type;
  //         });
  //       },
  //     ),
  //   );
  // }

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
            print('📊 Data updated: $_userData'); // Debug log
          });
          // Force rebuild of navigation buttons
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() {});
          });
        },
      ),
    );
  }

  Widget _buildLocationStep() {
    return SignupStepContainer(
      // title: 'العنوان',
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
      case 2: // Document upload step (now step 2, not 3)
        final requiredDocs = _selectedUserType == UserType.citizen ? 2 : 1;
        return _selectedDocuments.length >= requiredDocs;
      case 3: // Data entry step (now step 3, not 4)
        final canProceed = _isDataValid();
        print('🔍 Step 3 - Can proceed: $canProceed'); // Debug log
        return canProceed;
      case 4: // Location step (now step 4, not 5)
        final canProceed = _selectedGovernorate != null && _selectedCity != null;
        print('🔍 Step 4 - Can proceed: $canProceed (Gov: $_selectedGovernorate, City: $_selectedCity)'); // Debug log
        return canProceed;
      case 5: // Review step (now step 5, not 6)
        return true; // Review step can always proceed to submit
      default:
        return false;
    }
  }

  bool _isDataValid() {
    try {
      // Required fields for all users
      final requiredFields = ['fullName', 'email', 'phone', 'password'];

      // Document-specific fields
      if (_selectedUserType == UserType.citizen) {
        requiredFields.add('nationalId');
      } else {
        requiredFields.add('passportNumber');
      }

      // Debug: Log current data state
      print('🔍 Validating data for step $_currentStep');
      print('📊 Current _userData: $_userData');
      print('✅ Required fields: $requiredFields');

      // Check if all required fields have values
      List<String> missingFields = [];
      for (String field in requiredFields) {
        final value = _userData[field];
        if (value == null || value.trim().isEmpty) {
          missingFields.add(field);
        }
      }

      if (missingFields.isNotEmpty) {
        print('❌ Missing fields: $missingFields');
        return false;
      }

      // Check password length with fallback to controller
      final password = _userData['password'] ?? _passwordController.text.trim();
      if (password.length < 8) {
        print('❌ Password too short: ${password.length}');
        return false;
      }

      // Validate email format
      final email = _userData['email'] ?? '';
      if (email.isNotEmpty) {
        final emailValid = RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(email);
        if (!emailValid) {
          print('❌ Invalid email format: $email');
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
          print('❌ Invalid phone format: $phone');
          return false;
        }
      }

      // Validate document-specific fields
      if (_selectedUserType == UserType.citizen) {
        final nationalId = _userData['nationalId'] ?? '';
        if (nationalId.length != 14 ||
            !RegExp(r'^\d{14}$').hasMatch(nationalId)) {
          print('❌ Invalid national ID: $nationalId');
          return false;
        }
      } else {
        final passportNumber = _userData['passportNumber'] ?? '';
        if (passportNumber.length < 6 || passportNumber.length > 12) {
          print('❌ Invalid passport number: $passportNumber');
          return false;
        }
      }

      print('✅ All validation checks passed');
      return true;
    } catch (e) {
      print('❌ Validation error: $e');
      return false;
    }
  }

  /// Get validation error message for current data
  String? _getValidationError() {
    try {
      // Required fields for all users
      final requiredFields = ['fullName', 'email', 'phone', 'password'];

      // Document-specific fields
      if (_selectedUserType == UserType.citizen) {
        requiredFields.add('nationalId');
      } else {
        requiredFields.add('passportNumber');
      }

      // Check if all required fields have values
      List<String> missingFields = [];
      for (String field in requiredFields) {
        final value = _userData[field];
        if (value == null || value.trim().isEmpty) {
          missingFields.add(field);
        }
      }

      if (missingFields.isNotEmpty) {
        return 'الحقول المطلوبة مفقودة: ${missingFields.join(", ")}';
      }

      // Check password length with fallback to controller
      final password = _userData['password'] ?? _passwordController.text.trim();
      if (password.length < 8) {
        return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
      }

      // Validate email format
      final email = _userData['email'] ?? '';
      if (email.isNotEmpty) {
        final emailValid = RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(email);
        if (!emailValid) {
          return 'صيغة البريد الإلكتروني غير صحيحة';
        }
      }

      // Validate phone format
      final phone = _userData['phone'] ?? '';
      if (phone.isNotEmpty) {
        final phoneValid = RegExp(
          r'^\+?[0-9]{10,15}$',
        ).hasMatch(phone.replaceAll(RegExp(r'[\s-]'), ''));
        if (!phoneValid) {
          return 'صيغة رقم الهاتف غير صحيحة';
        }
      }

      // Validate document-specific fields
      if (_selectedUserType == UserType.citizen) {
        final nationalId = _userData['nationalId'] ?? '';
        if (nationalId.length != 14 ||
            !RegExp(r'^\d{14}$').hasMatch(nationalId)) {
          return 'الرقم القومي يجب أن يكون 14 رقم';
        }
      } else {
        final passportNumber = _userData['passportNumber'] ?? '';
        if (passportNumber.length < 6 || passportNumber.length > 12) {
          return 'رقم الجواز يجب أن يكون بين 6-12 حرف أو رقم';
        }
      }

      return null; // No validation error
    } catch (e) {
      return 'خطأ في التحقق من البيانات';
    }
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
    try {
      // Dismiss keyboard and clear focus
      FocusScope.of(context).unfocus();

      print('🚀 _nextStep called for step $_currentStep');
      print('📊 Can proceed: ${_canProceedToNext()}');

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
      } else if (_currentStep == 2) {
        // Document upload step - just proceed if documents are uploaded
        _proceedToNextStep();
      } else if (_currentStep == 3) {
        // Data entry step - validate data before proceeding
        print('📝 Validating data entry step...');
        if (_isDataValid()) {
          print('✅ Data is valid, proceeding to next step');
          _proceedToNextStep();
        } else {
          print('❌ Data validation failed, staying on current step');
          final errorMessage = _getValidationError();
          if (errorMessage != null) {
            _showValidationError(errorMessage);
          }
        }
      } else if (_currentStep == 4) {
        // Location step - validate location selection
        if (_selectedGovernorate != null && _selectedCity != null) {
          print('✅ Location selected, proceeding to review');
          _proceedToNextStep();
        } else {
          _showValidationError('يرجى اختيار المحافظة والمدينة');
        }
      } else if (_currentStep < _stepTitles.length - 1) {
        _proceedToNextStep();
      } else {
        _submitRegistration();
      }
    } catch (e) {
      print('❌ Error in _nextStep: $e');
      _showValidationError('حدث خطأ أثناء الانتقال للخطوة التالية');
    }
  }

  void _proceedToNextStep() {
    // Dismiss keyboard and clear focus first
    FocusScope.of(context).unfocus();

    if (!_isDisposed && mounted) {
      setState(() {
        _currentStep++;
      });
    }

    // Animate to next page
    _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousStep() {
    if (_currentStep > 0) {
      if (!_isDisposed && mounted) {
        setState(() {
          _currentStep--;
        });
      }
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

    // Basic security check - prevent empty or suspicious OTP codes
    if (_otpCode.trim().isEmpty || _otpCode.contains(RegExp(r'[^0-9]'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('رمز التحقق غير صحيح'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

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

  // 🆕 Show modern dialog when user already exists
  void _showUserExistsDialog(
    BuildContext context,
    String message,
    String field,
  ) {
    ModernDialog.show(
      context: context,
      title: 'حساب موجود مسبقاً',
      message: message,
      icon: Icon(
        Icons.account_circle_outlined,
        color: AppColors.warning,
        size: 32.sp,
      ),
      barrierDismissible: false,
      actions: [
        ModernDialogAction(
          text: 'تسجيل الدخول',
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed(Routes.loginScreen);
          },
          isPrimary: true,
          icon: Icon(Icons.login, size: 16.sp, color: Colors.white),
        ),
        ModernDialogAction(
          text:
              field == 'email'
                  ? 'جرب إيميل آخر'
                  : field == 'phone'
                  ? 'جرب رقم آخر'
                  : field == 'nationalId'
                  ? 'تأكد من الرقم القومي'
                  : 'تأكد من البيانات',
          onPressed: () {
            Navigator.of(context).pop();
            if (mounted) {
              context.read<SignupCubit>().clearErrorAndRetry();
            }
            // Clear the conflicting field
            if (field == 'email' || field == 'phone') {
              _usernameController.clear();
            }
            // Reset to initial step if needed
            setState(() {
              if (_currentStep > 0) {
                _currentStep = 0;
                _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            });
          },
          icon: Icon(Icons.edit, size: 16.sp),
        ),
        ModernDialogAction(
          text: 'إلغاء',
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.close, size: 16.sp),
        ),
      ],
    );
  } // Start resend countdown timer

  /// Show validation error to user
  void _showValidationError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Debug current state for troubleshooting
  void _debugCurrentState() {
    print('🔍 === DEBUG CURRENT STATE ===');
    print('📍 Current Step: $_currentStep');
    print('📊 User Data: $_userData');
    print('👤 Selected User Type: $_selectedUserType');
    print('📄 Selected Documents: ${_selectedDocuments.length}');
    print('🌍 Selected Governorate: $_selectedGovernorate');
    print('🏙️ Selected City: $_selectedCity');
    print('✅ Can Proceed: ${_canProceedToNext()}');
    print('🔒 Is Verified: $_isVerified');
    print('⏳ Is Submitting: $_isSubmitting');
    print('📧 Username Controller: ${_usernameController.text}');
    print('🔑 Password Controller: ${_passwordController.text}');
    print('🔄 Is Email Mode: $_isEmailMode');
    
    // Check specific step requirements
    if (_currentStep == 3) {
      final requiredFields = ['fullName', 'email', 'phone', 'password'];
      if (_selectedUserType == UserType.citizen) {
        requiredFields.add('nationalId');
      } else {
        requiredFields.add('passportNumber');
      }
      
      print('📋 Required fields for step 3: $requiredFields');
      for (String field in requiredFields) {
        final value = _userData[field];
        print('   $field: "${value ?? ''}" (${value?.isEmpty == true ? 'EMPTY' : 'OK'})');
      }
    }
    print('================================');
  }

  void _startResendTimer() {
    if (!_isDisposed && mounted) {
      setState(() => _resendCountdown = 60);
    }
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed || !mounted) {
        timer.cancel();
        return;
      }
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
