import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/features/auth/signup/presentation/cubits/signup_cubit.dart';
import 'package:netru_app/features/auth/signup/presentation/cubits/signup_state.dart';
import '../widgets/profile_navigation_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/routing/routes.dart';
import '../../../data/models/user_model.dart';
import '../../../domain/entities/user_entity.dart';
import '../widgets/profile_completion_header.dart';
import '../widgets/profile_completion_progress.dart';
import '../widgets/profile_data_entry.dart';
import '../widgets/profile_location_step.dart';
import '../widgets/profile_review_step.dart';
import '../../../../../core/services/location_service.dart';

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
          Navigator.pushReplacementNamed(context, Routes.customBottomBar);
        } else if (state is SignupFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: Column(
            children: [
              ProfileCompletionHeader(
                currentStep: _currentStep,
                stepTitles: _stepTitles,
              ),
              ProfileCompletionProgress(
                currentStep: _currentStep,
                stepTitles: _stepTitles,
              ),
              Expanded(child: _buildContent()),
              ProfileNavigationButtons(
                currentStep: _currentStep,
                canProceed: _canProceedToNext(),
                onNext: _nextStep,
                onPrevious: _previousStep,
                onSubmit: _submitProfile,
              ),
            ],
          ),
        ),
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
      child: ProfileDataEntry(
        userType: _userType,
        currentData: _userFormData,
        onDataChanged: (data) {
          setState(() {
            _userFormData = data;
          });
        },
      ),
    );
  }

  Widget _buildLocationStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: ProfileLocationStep(
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
      child: ProfileReviewStep(
        userData: _userFormData,
        selectedGovernorate: _selectedGovernorate,
        selectedCity: _selectedCity,
        email: widget.email,
      ),
    );
  }

  bool _canProceedToNext() {
    switch (_currentStep) {
      case 0: // Data entry
        return _userFormData['fullName']?.isNotEmpty == true;
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
      log('❌ لا يوجد مستخدم مصدق حالياً');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('خطأ: لا يوجد مستخدم مصدق')));
      return;
    }

    log('✅ المستخدم المصدق: ${currentUser.id}');
    log('📧 إيميل المستخدم: ${currentUser.email}');

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
          _userFormData['dateOfBirth'] != null
              ? DateTime.tryParse(_userFormData['dateOfBirth']!)
              : null,
      verificationStatus: VerificationStatus.verified,
    );

    log('🚀 إرسال بيانات المستخدم الكاملة...');
    log('📋 البيانات: ${userData.toJson()}');

    // Complete the profile
    context.read<SignupCubit>().completeUserProfile(userData);
  }
}
