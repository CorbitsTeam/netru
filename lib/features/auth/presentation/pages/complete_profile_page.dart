import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/routes.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user_entity.dart';
import '../widgets/animated_button.dart';
import '../widgets/data_entry_step.dart';
import '../widgets/simple_location_step.dart';
import '../cubit/signup_cubit.dart';
import '../cubit/signup_state.dart';
import '../../../../core/services/location_service.dart';

class CompleteProfilePage extends StatefulWidget {
  final String email;
  final String password;

  const CompleteProfilePage({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Data Entry Step
  Map<String, String> _userFormData = {};

  // Location Step
  GovernorateModel? _selectedGovernorate;
  CityModel? _selectedCity;

  final List<String> _stepTitles = [
    'البيانات الشخصية',
    'العنوان',
    'مراجعة وإرسال',
  ];

  UserType get _userType => UserType.citizen; // Default to citizen for now

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  void _initializeUserData() {
    // Initialize with empty data - user will fill everything
    _userFormData = {};
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignupCubit, SignupState>(
      listener: (context, state) {
        if (state is SignupSuccess) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.homePage,
            (route) => false,
          );
        } else if (state is SignupFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressIndicator(),
              Expanded(child: _buildContent()),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.security, size: 32.sp, color: AppColors.primary),
            SizedBox(height: 8.h),
            Text(
              'إكمال الملف الشخصي',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'تم تأكيد بريدك الإلكتروني بنجاح',
              style: TextStyle(fontSize: 14.sp, color: AppColors.success),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Column(
        children: [
          // Progress indicator
          Row(
            children: List.generate(_stepTitles.length, (index) {
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;

              return Expanded(
                child: Row(
                  children: [
                    // Step circle
                    SlideInDown(
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 36.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isCompleted || isCurrent
                                  ? AppColors.primary
                                  : Colors.grey[300],
                          border: Border.all(
                            color:
                                isCompleted || isCurrent
                                    ? AppColors.primary
                                    : Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child:
                              isCompleted
                                  ? Icon(
                                    Icons.check,
                                    size: 20.sp,
                                    color: Colors.white,
                                  )
                                  : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isCurrent
                                              ? Colors.white
                                              : Colors.grey[600],
                                    ),
                                  ),
                        ),
                      ),
                    ),

                    // Connection line (except for last step)
                    if (index < _stepTitles.length - 1)
                      Expanded(
                        child: SlideInRight(
                          duration: Duration(milliseconds: 400 + (index * 100)),
                          child: Container(
                            height: 2.h,
                            color:
                                isCompleted
                                    ? AppColors.primary
                                    : Colors.grey[300],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),

          SizedBox(height: 12.h),

          // Step title
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            child: Text(
              _stepTitles[_currentStep],
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildDataEntryStep(),
        _buildLocationStep(),
        _buildReviewStep(),
      ],
    );
  }

  Widget _buildDataEntryStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: DataEntryStep(
        userType: _userType,
        extractedData: null, // No extracted data in this flow
        onDataChanged: (data) {
          setState(() {
            _userFormData = data;
          });
        },
        currentData: _userFormData,
      ),
    );
  }

  Widget _buildLocationStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: SimpleLocationStep(
        selectedGovernorate: _selectedGovernorate,
        selectedCity: _selectedCity,
        onGovernorateChanged: (governorate) {
          setState(() {
            _selectedGovernorate = governorate;
            _selectedCity = null; // Reset city when governorate changes
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
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: Text(
              'مراجعة البيانات',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // Personal Information
          _buildReviewSection(
            title: 'البيانات الشخصية',
            icon: Icons.person,
            items: [
              if (_userFormData['fullName'] != null)
                _buildReviewItem('الاسم الكامل', _userFormData['fullName']!),
              if (_userFormData['nationalId'] != null)
                _buildReviewItem('الرقم القومي', _userFormData['nationalId']!),
              if (_userFormData['passportNumber'] != null)
                _buildReviewItem(
                  'رقم جواز السفر',
                  _userFormData['passportNumber']!,
                ),
              if (_userFormData['phone'] != null)
                _buildReviewItem('رقم الهاتف', _userFormData['phone']!),
            ],
          ),

          SizedBox(height: 20.h),

          // Location Information
          _buildReviewSection(
            title: 'العنوان',
            icon: Icons.location_on,
            items: [
              if (_selectedGovernorate != null)
                _buildReviewItem('المحافظة', _selectedGovernorate!.name),
              if (_selectedCity != null)
                _buildReviewItem('المدينة', _selectedCity!.name),
            ],
          ),

          SizedBox(height: 40.h),

          BlocBuilder<SignupCubit, SignupState>(
            builder: (context, state) {
              return AnimatedButton(
                text: 'إكمال التسجيل',
                onPressed: _submitProfile,
                isLoading: state is SignupLoading,
                backgroundColor: AppColors.primary,
                width: double.infinity,
                height: 50.h,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection({
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24.sp),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: AnimatedButton(
                text: 'السابق',
                onPressed: _previousStep,
                backgroundColor: Colors.grey[300],
                textColor: Colors.grey[700],
                height: 50.h,
              ),
            ),
          if (_currentStep > 0) SizedBox(width: 16.w),
          Expanded(
            child: AnimatedButton(
              text: _currentStep == _stepTitles.length - 1 ? 'إنهاء' : 'التالي',
              onPressed: _canProceedToNext() ? _nextStep : null,
              backgroundColor: AppColors.primary,
              height: 50.h,
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceedToNext() {
    switch (_currentStep) {
      case 0: // Data entry
        return _userFormData['fullName']?.isNotEmpty == true &&
            (_userFormData['nationalId']?.isNotEmpty == true ||
                _userFormData['passportNumber']?.isNotEmpty == true);
      case 1: // Location
        return _selectedGovernorate != null && _selectedCity != null;
      case 2: // Review
        return true;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitProfile() {
    // Get current user ID from Supabase auth
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      print('❌ لا يوجد مستخدم مصدق حالياً');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطأ في المصادقة. يرجى تسجيل الدخول مرة أخرى'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('✅ المستخدم المصدق: ${currentUser.id}');
    print('📧 إيميل المستخدم: ${currentUser.email}');

    // Create complete user model
    final userData = UserModel(
      id: currentUser.id,
      email: widget.email,
      fullName: _userFormData['fullName'] ?? '',
      userType: _userType,
      nationalId: _userFormData['nationalId'],
      passportNumber: _userFormData['passportNumber'],
      phone: _userFormData['phone'],
      governorateId: _selectedGovernorate?.id,
      governorateName: _selectedGovernorate?.name,
      cityId: _selectedCity?.id,
      cityName: _selectedCity?.name,
      dateOfBirth:
          _userFormData['birthDate']?.isNotEmpty == true
              ? DateTime.tryParse(_userFormData['birthDate']!)
              : null,
      verificationStatus: VerificationStatus.verified,
    );

    print('🚀 إرسال بيانات المستخدم الكاملة...');
    print('📋 البيانات: ${userData.toJson()}');

    // Complete the profile
    context.read<SignupCubit>().completeUserProfile(userData);
  }
}
