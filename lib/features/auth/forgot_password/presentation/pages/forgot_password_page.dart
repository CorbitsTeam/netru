import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';
import '../widgets/forgot_password_header.dart';
import '../widgets/forgot_password_form.dart';
import '../widgets/forgot_password_success_message.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'إعادة تعيين كلمة المرور',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Almarai',
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.error,
                  style: const TextStyle(fontFamily: 'Almarai'),
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),

                // Header Section
                const ForgotPasswordHeader(),

                // Dynamic Content Based on State
                BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                  builder: (context, state) {
                    // Step 3: Password Reset Completed
                    if (state is PasswordResetSuccess) {
                      return Column(
                        children: [
                          SizedBox(height: 40.h),
                          ForgotPasswordSuccessMessage(
                            message: state.message,
                            onBackToLogin: () {
                              context.read<ForgotPasswordCubit>().resetState();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    }

                    // Step 2: Email sent successfully - Show instructions
                    if (state is PasswordResetEmailSent) {
                      return Column(
                        children: [
                          SizedBox(height: 40.h),
                          ForgotPasswordSuccessMessage(
                            message: state.message,
                            onBackToLogin: () {
                              context.read<ForgotPasswordCubit>().resetState();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    }

                    // Step 1: Email Input (Default)
                    return const ForgotPasswordForm();
                  },
                ),

                SizedBox(height: 40.h),

                // Back to Login Link
                BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                  builder: (context, state) {
                    // Hide back link for success states
                    if (state is PasswordResetSuccess ||
                        state is PasswordResetEmailSent) {
                      return const SizedBox.shrink();
                    }

                    // Show back to login link for email input
                    return GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'تذكرت كلمة المرور؟ ',
                              style: TextStyle(
                                color: const Color(0xFF6B7280),
                                fontSize: 14.sp,
                                fontFamily: 'Almarai',
                              ),
                            ),
                            TextSpan(
                              text: 'العودة لتسجيل الدخول',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Almarai',
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),

                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
