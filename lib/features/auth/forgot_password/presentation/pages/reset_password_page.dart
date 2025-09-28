import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../widgets/validated_text_form_field.dart';
import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';

/// This page is shown after the user clicks the reset password link from email
/// It allows them to enter a new password
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _newPasswordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final state = context.read<ForgotPasswordCubit>().state;
      if (state is TokenVerified) {
        context.read<ForgotPasswordCubit>().resetPasswordWithToken(
          state.email,
          state.token,
          _newPasswordController.text.trim(),
          _confirmPasswordController.text.trim(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'تعيين كلمة المرور الجديدة',
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
          } else if (state is PasswordResetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: const TextStyle(fontFamily: 'Almarai'),
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );

            // Navigate back to login after success
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            });
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40.h),

                // Header
                FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: Column(
                    children: [
                      Icon(
                        Icons.lock_reset,
                        size: 80.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'كلمة المرور الجديدة',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontFamily: 'Almarai',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'يرجى إدخال كلمة المرور الجديدة',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: const Color(0xFF6B7280),
                          fontFamily: 'Almarai',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40.h),

                // Form
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // New Password Field
                        ValidatedTextFormField(
                          controller: _newPasswordController,
                          focusNode: _newPasswordFocusNode,
                          label: 'كلمة المرور الجديدة',
                          hint: 'أدخل كلمة المرور الجديدة',
                          prefixIcon: Icon(Icons.lock_outline, size: 20.sp),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 20.sp,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                          obscureText: _obscureNewPassword,
                          validationType: ValidationType.password,
                          realTimeValidation: true,
                          showValidationIcon: true,
                          validator:
                              (value) => context
                                  .read<ForgotPasswordCubit>()
                                  .validatePassword(value),
                        ),

                        SizedBox(height: 20.h),

                        // Confirm Password Field
                        ValidatedTextFormField(
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocusNode,
                          label: 'تأكيد كلمة المرور',
                          hint: 'أعد إدخال كلمة المرور الجديدة',
                          prefixIcon: Icon(Icons.lock_outline, size: 20.sp),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 20.sp,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          obscureText: _obscureConfirmPassword,
                          validationType: ValidationType.password,
                          realTimeValidation: true,
                          showValidationIcon: true,
                          validator:
                              (value) => context
                                  .read<ForgotPasswordCubit>()
                                  .validatePasswordConfirmation(
                                    value,
                                    _newPasswordController.text,
                                  ),
                        ),

                        SizedBox(height: 32.h),

                        // Password Requirements
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Colors.blue[200]!,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'متطلبات كلمة المرور:',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[800],
                                  fontFamily: 'Almarai',
                                ),
                              ),
                              SizedBox(height: 8.h),
                              _buildRequirement('8 أحرف على الأقل'),
                              _buildRequirement('حروف كبيرة وصغيرة'),
                              _buildRequirement('أرقام ورموز خاصة'),
                            ],
                          ),
                        ),

                        SizedBox(height: 32.h),

                        // Reset Password Button
                        BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                          builder: (context, state) {
                            final isLoading = state is ForgotPasswordLoading;
                            return SizedBox(
                              width: double.infinity,
                              height: 50.h,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _handleSubmit,
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
                                    isLoading
                                        ? SizedBox(
                                          width: 24.w,
                                          height: 24.h,
                                          child:
                                              const CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                        )
                                        : Text(
                                          'حفظ كلمة المرور الجديدة',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Almarai',
                                          ),
                                        ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16.sp,
            color: Colors.blue[600],
          ),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.blue[700],
              fontFamily: 'Almarai',
            ),
          ),
        ],
      ),
    );
  }
}
