import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:netru_app/core/extensions/navigation_extensions.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/auth_validation_utils.dart';
import '../../../../core/routing/routes.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/animated_button.dart';
import 'multi_step_signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _identityController = TextEditingController();
  final _passwordController = TextEditingController();

  late TabController _tabController;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _identityController.dispose();
    _passwordController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  bool get _isCitizenTab => _tabController.index == 0;

  void _handleLogin() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final identity = _identityController.text.trim();
    final password = _passwordController.text;

    if (_isCitizenTab) {
      context.read<AuthCubit>().loginWithNationalId(
        nationalId: identity,
        password: password,
      );
    } else {
      context.read<AuthCubit>().loginWithPassport(
        passportNumber: identity,
        password: password,
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  void _navigateToSignup() {
    // For now, just navigate to the multi-step signup page
    // You'll need to set up proper dependency injection
    context.pushNamed(Routes.signupScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state is AuthLoggedIn) {
            Navigator.pushReplacementNamed(context, Routes.homeScreen);
          } else if (state is AuthError) {
            _showErrorSnackBar(state.message);
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8FAFC), Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
              stops: [0.0, 0.6, 1.0],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  _buildHeader(),
                  SizedBox(height: 50.h),
                  _buildLoginCard(),
                  SizedBox(height: 30.h),
                  _buildBottomSection(),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeInDown(
      duration: const Duration(milliseconds: 800),
      child: Column(
        children: [
          // Logo with improved design
          Image.asset(
            AppAssets.mainLogo,
            width: 150.w,
            // height: 120.h,
            fit: BoxFit.contain,
          ),

          SizedBox(height: 32.h),

          // Welcome text with improved typography
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 200),
            child: Column(
              children: [
                Text(
                  'مرحباً بك في نترو',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'سجل دخولك للوصول إلى خدماتنا الرقمية',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      delay: const Duration(milliseconds: 400),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            _buildTabSelection(),
            SizedBox(height: 24.h),
            _buildLoginForm(),
            SizedBox(height: 28.h),
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      delay: const Duration(milliseconds: 800),
      child: Column(
        children: [
          // Signup section
          _buildSignupSection(),
        ],
      ),
    );
  }

  Widget _buildTabSelection() {
    return Container(
      height: 50.h,
      padding: EdgeInsets.all(3.w), // علشان يدي مسافة للـ indicator
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant, // خلفية ثابتة
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border.withOpacity(0.3), width: 1),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.primary, // لون الـ indicator
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14.sp,
          fontFamily: 'Almarai',
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14.sp,
          fontFamily: 'Almarai',
        ),
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        tabs: const [Tab(text: 'مواطن مصري'), Tab(text: 'مقيم أجنبي')],
        onTap: (index) {
          setState(() {
            _identityController.clear();
            _passwordController.clear();
          });
        },
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Identity Field
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.border.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: TextFormField(
              controller: _identityController,
              keyboardType:
                  _isCitizenTab ? TextInputType.number : TextInputType.text,
              inputFormatters:
                  _isCitizenTab
                      ? [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(14),
                      ]
                      : [LengthLimitingTextInputFormatter(12)],
              validator:
                  _isCitizenTab
                      ? AuthValidationUtils.validateNationalId
                      : AuthValidationUtils.validatePassportNumber,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                fontFamily: 'Almarai',
              ),
              decoration: InputDecoration(
                hintText: _isCitizenTab ? 'الرقم القومي' : 'رقم الجواز',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.7),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Almarai',
                ),
                prefixIcon: Icon(
                  _isCitizenTab
                      ? Icons.credit_card_outlined
                      : Icons.book_outlined,
                  color: AppColors.primary.withOpacity(0.7),
                  size: 20.sp,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
                filled: false,
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Password Field
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.border.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              validator: AuthValidationUtils.validatePassword,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                fontFamily: 'Almarai',
              ),
              decoration: InputDecoration(
                hintText: 'كلمة المرور',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.7),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Almarai',
                ),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: AppColors.primary.withOpacity(0.7),
                  size: 20.sp,
                ),
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  child: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecondary.withOpacity(0.7),
                    size: 20.sp,
                  ),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
                filled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return AnimatedButton(
      text: 'تسجيل الدخول',
      onPressed: _handleLogin,
      isLoading: _isLoading,
      isEnabled: !_isLoading,
      icon: Icon(Icons.login, color: Colors.white, size: 20.sp),
      backgroundColor: AppColors.primary,
      height: 56.h,
    );
  }

  Widget _buildSignupSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'ليس لديك حساب؟ ',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15.sp),
          ),
          GestureDetector(
            onTap: _navigateToSignup,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'إنشاء حساب جديد',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15.sp,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
