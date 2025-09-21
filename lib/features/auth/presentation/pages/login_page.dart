import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:netru_app/core/extensions/navigation_extensions.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/user_data_helper.dart';
import '../../domain/entities/login_user_entity.dart';
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late TabController _tabController;

  // Form keys for each tab
  final _citizenFormKey = GlobalKey<FormState>();
  final _foreignerFormKey = GlobalKey<FormState>();
  final _adminFormKey = GlobalKey<FormState>();

  // Controllers for each form
  final _citizenNationalIdController = TextEditingController();
  final _citizenPasswordController = TextEditingController();

  final _foreignerPassportController = TextEditingController();
  final _foreignerPasswordController = TextEditingController();

  final _adminEmailController = TextEditingController();
  final _adminPasswordController = TextEditingController();

  bool _obscureCitizenPassword = true;
  bool _obscureForeignerPassword = true;
  bool _obscureAdminPassword = true;
  bool _isLoading = false;
  bool _showAdminTab = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _citizenNationalIdController.dispose();
    _citizenPasswordController.dispose();
    _foreignerPassportController.dispose();
    _foreignerPasswordController.dispose();
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  void _handleLogin(UserType userType) {
    GlobalKey<FormState> formKey;
    String identifier;
    String password;

    switch (userType) {
      case UserType.citizen:
        formKey = _citizenFormKey;
        identifier = _citizenNationalIdController.text.trim();
        password = _citizenPasswordController.text;
        break;
      case UserType.foreigner:
        formKey = _foreignerFormKey;
        identifier = _foreignerPassportController.text.trim();
        password = _foreignerPasswordController.text;
        break;
      case UserType.admin:
        formKey = _adminFormKey;
        identifier = _adminEmailController.text.trim();
        password = _adminPasswordController.text;
        break;
    }

    if (!(formKey.currentState?.validate() ?? false)) return;

    context.read<LoginCubit>().loginUser(
      identifier: identifier,
      password: password,
      userType: userType,
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _navigateToSignup() {
    context.pushNamed(Routes.signupScreen);
  }

  void _navigateBasedOnUserType(LoginUserEntity user) async {
    // Save user data to SharedPreferences and refresh from database
    try {
      final userHelper = UserDataHelper();
      await userHelper.saveCurrentUser(user);

      // Refresh user data from database to get complete information
      await userHelper.refreshUserDataFromDatabase();
    } catch (e) {
      print('Error saving/refreshing user data: $e');
    }

    switch (user.userType) {
      case UserType.citizen:
      case UserType.foreigner:
        context.pushReplacementNamed(Routes.customBottomBar);
        break;
      case UserType.admin:
        context.pushReplacementNamed(Routes.adminDashboard);
        break;
    }
  }

  void _onLogoDoubleTap() {
    if (!_showAdminTab) {
      setState(() {
        _showAdminTab = true;
        // Dispose the old controller properly
        final oldIndex = _tabController.index;
        _tabController.dispose();
        _tabController = TabController(length: 3, vsync: this);
        // Keep the current tab if it's still valid, otherwise go to admin tab
        if (oldIndex < 2) {
          _tabController.index = oldIndex;
        } else {
          _tabController.animateTo(2); // Switch to admin tab
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state is LoginSuccess) {
            _navigateBasedOnUserType(state.user);
          } else if (state is LoginFailure) {
            _showErrorSnackBar(state.error);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 40.h),
                _buildHeader(),
                SizedBox(height: 40.h),
                _buildTabBar(),
                // SizedBox(height: 24.h),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCitizenForm(),
                      _buildForeignerForm(),
                      if (_showAdminTab) _buildAdminForm(),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
                _buildBottomSection(),
                SizedBox(height: 30.h),
              ],
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
          // اللوغو بدون إطار - واضح وبسيط
          GestureDetector(
            onDoubleTap: _onLogoDoubleTap,
            child: Image.asset(
              AppAssets.mainLogo,
              width: 120.w,
              height: 120.h,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 32.h),

          // النص الترحيبي
          Text(
            'أهلاً وسهلاً',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1a1a1a),
              fontFamily: 'Almarai',
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'سجل دخولك للمتابعة',
            style: TextStyle(
              fontSize: 16.sp,
              color: const Color(0xFF6B7280),
              fontFamily: 'Almarai',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(25.r),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF6B7280),
        labelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'Almarai',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          fontFamily: 'Almarai',
        ),
        tabs: [
          const Tab(text: 'مواطن مصري'),
          const Tab(text: 'مقيم أجنبي'),
          if (_showAdminTab) const Tab(text: 'مدير'),
        ],
      ),
    );
  }

  Widget _buildCitizenForm() {
    return Form(
      key: _citizenFormKey,
      child: Column(
        children: [
          SizedBox(height: 32.h),
          _buildTextField(
            controller: _citizenNationalIdController,
            label: 'الرقم القومي',
            hint: 'أدخل الرقم القومي (14 رقم)',
            icon: Icons.person_outline,
            keyboardType: TextInputType.number,
            validator:
                (value) => context.read<LoginCubit>().validateIdentifier(
                  value,
                  UserType.citizen,
                ),
          ),
          SizedBox(height: 24.h),
          _buildPasswordField(
            controller: _citizenPasswordController,
            validator:
                (value) => context.read<LoginCubit>().validatePassword(value),
            obscureText: _obscureCitizenPassword,
            onToggleVisibility:
                () => setState(
                  () => _obscureCitizenPassword = !_obscureCitizenPassword,
                ),
          ),
          SizedBox(height: 40.h),
          _buildLoginButton(() => _handleLogin(UserType.citizen)),
        ],
      ),
    );
  }

  Widget _buildForeignerForm() {
    return Form(
      key: _foreignerFormKey,
      child: Column(
        children: [
          SizedBox(height: 32.h),
          _buildTextField(
            controller: _foreignerPassportController,
            label: 'رقم جواز السفر',
            hint: 'أدخل رقم جواز السفر',
            icon: Icons.flight_outlined,
            keyboardType: TextInputType.text,
            validator:
                (value) => context.read<LoginCubit>().validateIdentifier(
                  value,
                  UserType.foreigner,
                ),
          ),
          SizedBox(height: 24.h),
          _buildPasswordField(
            controller: _foreignerPasswordController,
            validator:
                (value) => context.read<LoginCubit>().validatePassword(value),
            obscureText: _obscureForeignerPassword,
            onToggleVisibility:
                () => setState(
                  () => _obscureForeignerPassword = !_obscureForeignerPassword,
                ),
          ),
          SizedBox(height: 40.h),
          _buildLoginButton(() => _handleLogin(UserType.foreigner)),
        ],
      ),
    );
  }

  Widget _buildAdminForm() {
    return Form(
      key: _adminFormKey,
      child: Column(
        children: [
          SizedBox(height: 32.h),
          _buildTextField(
            controller: _adminEmailController,
            label: 'البريد الإلكتروني',
            hint: 'أدخل البريد الإلكتروني',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator:
                (value) => context.read<LoginCubit>().validateIdentifier(
                  value,
                  UserType.admin,
                ),
          ),
          SizedBox(height: 24.h),
          _buildPasswordField(
            controller: _adminPasswordController,
            validator:
                (value) => context.read<LoginCubit>().validatePassword(value),
            obscureText: _obscureAdminPassword,
            onToggleVisibility:
                () => setState(
                  () => _obscureAdminPassword = !_obscureAdminPassword,
                ),
          ),
          SizedBox(height: 40.h),
          _buildLoginButton(() => _handleLogin(UserType.admin)),
        ],
      ),
    );
  }

  Widget _buildLoginButton(VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child:
            _isLoading
                ? SizedBox(
                  width: 24.w,
                  height: 24.h,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Text(
                  'تسجيل الدخول',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Almarai',
                  ),
                ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1a1a1a),
            fontFamily: 'Almarai',
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          textDirection:
              keyboardType == TextInputType.emailAddress
                  ? TextDirection.ltr
                  : TextDirection.rtl,
          style: TextStyle(
            fontSize: 16.sp,
            color: const Color(0xFF1a1a1a),
            fontFamily: 'Almarai',
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: const Color(0xFF9CA3AF),
              fontSize: 15.sp,
              fontFamily: 'Almarai',
            ),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 22.sp),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String? Function(String?) validator,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'كلمة المرور',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1a1a1a),
            fontFamily: 'Almarai',
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          style: TextStyle(
            fontSize: 16.sp,
            color: const Color(0xFF1a1a1a),
            fontFamily: 'Almarai',
          ),
          decoration: InputDecoration(
            hintText: 'أدخل كلمة المرور',
            hintStyle: TextStyle(
              color: const Color(0xFF9CA3AF),
              fontSize: 15.sp,
              fontFamily: 'Almarai',
            ),
            prefixIcon: Icon(
              Icons.lock_outline,
              color: AppColors.primary,
              size: 22.sp,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFF6B7280),
                size: 22.sp,
              ),
              onPressed: onToggleVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      delay: const Duration(milliseconds: 800),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'ليس لديك حساب؟ ',
            style: TextStyle(
              color: const Color(0xFF6B7280),
              fontSize: 15.sp,
              fontFamily: 'Almarai',
            ),
          ),
          GestureDetector(
            onTap: _navigateToSignup,
            child: Text(
              'إنشاء حساب جديد',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Almarai',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
