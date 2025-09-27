import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/extensions/navigation_extensions.dart';
import '../../../../../core/routing/routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/user_data_helper.dart';
import '../../../domain/entities/user_entity.dart';
import 'package:netru_app/core/di/injection_container.dart';
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';
import '../widgets/login_header.dart';

import '../widgets/login_bottom_section.dart';
import '../widgets/citizen_login_form.dart';

import '../widgets/admin_login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

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

  void _navigateBasedOnUserType(UserEntity user) async {
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
    _showAdminAccessDialog();
  }

  void _showAdminAccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        // Try to reuse existing LoginCubit from ancestor; if not found,
        // fallback to creating one from the DI container so the dialog
        // remains functional in all navigation scenarios.
        LoginCubit? existingCubit;
        try {
          existingCubit = BlocProvider.of<LoginCubit>(context);
        } catch (_) {
          existingCubit = null;
        }

        final dialogChild = AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'دخول المطور',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Almarai',
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'أدخل رمز المطور للوصول لواجهة الإدارة',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  fontFamily: 'Almarai',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              AdminLoginForm(
                isLoading: _isLoading,
                onSubmit: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
        );

        if (existingCubit != null) {
          return BlocProvider.value(value: existingCubit, child: dialogChild);
        }

        // Fallback: create a temporary LoginCubit from DI container
        return BlocProvider<LoginCubit>(
          create: (_) => sl<LoginCubit>(),
          child: dialogChild,
        );
      },
    );
  }

  void _handleFormSubmit() {
    // This will be handled by individual form widgets
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
                LoginHeader(onLogoDoubleTap: _onLogoDoubleTap),

                SizedBox(height: 32.h),

                // Citizen login form only
                CitizenLoginForm(
                  isLoading: _isLoading,
                  onSubmit: _handleFormSubmit,
                ),
                SizedBox(height: 65.h),
                LoginBottomSection(onSignupTap: _navigateToSignup),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
