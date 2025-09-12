import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:netru_app/core/routing/routes.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:netru_app/features/auth/presentation/widgets/data_entry_step.dart';
import 'package:netru_app/features/auth/presentation/widgets/review_submit_step.dart';
import '../../../../core/services/ocr_service.dart';
import '../../../../core/services/location_service.dart';
import '../widgets/user_type_selection_step.dart';
import '../widgets/document_upload_step.dart';
import '../widgets/simple_location_step.dart';
import '../widgets/animated_button.dart';
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

  // Step 1: User Type
  UserType? _selectedUserType;

  // Step 2: Documents
  List<File> _selectedDocuments = [];
  bool _isProcessingOCR = false;
  ExtractedDocumentData? _extractedData;

  // Step 3: Data Entry
  Map<String, String> _userData = {};

  // Step 4: Location
  GovernorateModel? _selectedGovernorate;
  CityModel? _selectedCity;

  final List<String> _stepTitles = [
    'نوع المستخدم',
    'رفع المستندات',
    'البيانات الشخصية',
    'العنوان',
    'مراجعة وإرسال',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    OCRService.dispose();
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.white, size: 20.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 5),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(16.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            );
            setState(() {
              _isSubmitting = false;
            });
          } else if (state is SignupCompleted || state is SignupSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'تم إنشاء الحساب بنجاح! مرحباً بك في نتru',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(16.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            );
            // Navigate after a short delay to show the success message
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.of(context).pushReplacementNamed(Routes.homeScreen);
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
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
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
                  width: 15.w,
                  height: 3.h,
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
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

                return SlideInUp(
                  duration: Duration(milliseconds: 300 + (stepIndex * 100)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: 40.w,
                    height: 40.h,
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
          if (documents.isNotEmpty) {
            _processOCR(documents);
          }
        },
        isProcessingOCR: _isProcessingOCR,
      ),
    );
  }

  Widget _buildDataEntryStep() {
    return SingleChildScrollView(
      child: DataEntryStep(
        userType: _selectedUserType ?? UserType.citizen,
        extractedData: _extractedData,
        currentData: _userData,
        onDataChanged: (data) {
          setState(() {
            _userData = data;
          });
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
              text:
                  _currentStep == _stepTitles.length - 1
                      ? (_isSubmitting ? 'جاري الإنشاء...' : 'إنشاء الحساب')
                      : 'التالي',
              onPressed:
                  _canProceedToNext() && !_isSubmitting ? _nextStep : null,
              isLoading: _isSubmitting,
              height: 48.h,
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceedToNext() {
    switch (_currentStep) {
      case 0:
        return _selectedUserType != null;
      case 1:
        final requiredDocs = _selectedUserType == UserType.citizen ? 2 : 1;
        return _selectedDocuments.length >= requiredDocs;
      case 2:
        return _isDataValid();
      case 3:
        return _selectedGovernorate != null && _selectedCity != null;
      case 4:
        return true; // Review step can always proceed to submit
      default:
        return false;
    }
  }

  bool _isDataValid() {
    final requiredFields = ['fullName', 'email', 'phone', 'password'];
    if (_selectedUserType == UserType.citizen) {
      requiredFields.add('nationalId');
    } else {
      requiredFields.add('passportNumber');
    }

    // Check if all required fields have values
    final allFieldsValid = requiredFields.every(
      (field) => _userData[field]?.isNotEmpty == true,
    );

    // Check password length
    final passwordValid = (_userData['password']?.length ?? 0) >= 6;

    // Validate email format
    final emailValid =
        _userData['email'] != null &&
        RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(_userData['email']!);

    // Validate national ID for citizens (14 digits)
    bool documentValid = true;
    if (_selectedUserType == UserType.citizen) {
      final nationalId = _userData['nationalId'] ?? '';
      documentValid =
          nationalId.length == 14 && RegExp(r'^\d{14}$').hasMatch(nationalId);
    } else {
      // For foreigners, just check passport number is not empty
      documentValid = (_userData['passportNumber']?.isNotEmpty ?? false);
    }

    return allFieldsValid && passwordValid && emailValid && documentValid;
  }

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitRegistration();
    }
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

  Future<void> _processOCR(List<File> documents) async {
    if (documents.isEmpty) return;

    setState(() {
      _isProcessingOCR = true;
      _extractedData = null;
    });

    try {
      ExtractedDocumentData? result;

      if (_selectedUserType == UserType.citizen) {
        result = await OCRService.extractFromEgyptianID(documents.first);
      } else {
        result = await OCRService.extractFromPassport(documents.first);
      }

      setState(() {
        _extractedData = result;
        _isProcessingOCR = false;
      });

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم استخراج البيانات بنجاح!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'لم يتم العثور على بيانات. يرجى إدخال البيانات يدوياً',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessingOCR = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في معالجة الصورة: $e')));
    }
  }

  void _submitRegistration() {
    if (!_canProceedToNext()) return;

    setState(() {
      _isSubmitting = true;
    });

    // Get password from form data or use default
    final password = _userData['password'] ?? 'TempPassword123!';

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
      'email': _userData['email'],
      'phone': _userData['phone'],
      'userType': _selectedUserType?.name,
      'governorate': _selectedGovernorate?.name,
      'city': _selectedCity?.name,
      'address': _userData['address'],
      'password': password,
    };

    // Add document-specific fields
    if (_selectedUserType == UserType.citizen) {
      registrationData['nationalId'] = _userData['nationalId'];
    } else {
      registrationData['passportNumber'] = _userData['passportNumber'];
    }

    // Add document paths
    final documentPaths = _selectedDocuments.map((file) => file.path).toList();
    registrationData['documents'] = documentPaths;

    cubit.registerUser(registrationData);
  }
}
