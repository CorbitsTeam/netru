import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import 'signup_step_container.dart';

class SignupUsernamePasswordStep extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isEmailMode;
  final ValueChanged<bool> onEmailModeChanged;
  final GlobalKey<FormState> formKey;

  const SignupUsernamePasswordStep({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isEmailMode,
    required this.onEmailModeChanged,
    required this.formKey,
  });

  @override
  State<SignupUsernamePasswordStep> createState() =>
      _SignupUsernamePasswordStepState();
}

class _SignupUsernamePasswordStepState
    extends State<SignupUsernamePasswordStep> {
  bool _passwordObscured = true;
  bool _confirmPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    return SignupStepContainer(
      title: 'بيانات الدخول الأساسية',
      subtitle: 'أدخل بريدك الإلكتروني أو رقم هاتفك وكلمة مرور قوية',
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Mode Toggle (Email or Phone)
            FadeInUp(
              duration: const Duration(milliseconds: 700),
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          widget.onEmailModeChanged(true);
                          // Clear form validation state when switching modes
                          widget.formKey.currentState?.reset();
                          widget.usernameController.clear();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          decoration: BoxDecoration(
                            color:
                                widget.isEmailMode
                                    ? AppColors.primary
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'البريد الإلكتروني',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color:
                                  widget.isEmailMode
                                      ? Colors.white
                                      : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          widget.onEmailModeChanged(false);
                          // Clear form validation state when switching modes
                          widget.formKey.currentState?.reset();
                          widget.usernameController.clear();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          decoration: BoxDecoration(
                            color:
                                !widget.isEmailMode
                                    ? AppColors.primary
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'رقم الهاتف',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color:
                                  !widget.isEmailMode
                                      ? Colors.white
                                      : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Username Field (Email or Phone)
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: CustomTextField(
                controller: widget.usernameController,
                label: widget.isEmailMode ? 'البريد الإلكتروني' : 'رقم الهاتف',
                hint:
                    widget.isEmailMode
                        ? 'أدخل بريدك الإلكتروني'
                        : 'أدخل رقم هاتفك',
                prefixIcon:
                    widget.isEmailMode
                        ? Icons.email_outlined
                        : Icons.phone_outlined,
                keyboardType:
                    widget.isEmailMode
                        ? TextInputType.emailAddress
                        : TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return widget.isEmailMode
                        ? 'البريد الإلكتروني مطلوب'
                        : 'رقم الهاتف مطلوب';
                  }
                  if (widget.isEmailMode) {
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'أدخل بريد إلكتروني صحيح';
                    }
                  } else {
                    if (!RegExp(
                      r'^\+?[0-9]{10,15}$',
                    ).hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''))) {
                      return 'أدخل رقم هاتف صحيح';
                    }
                  }
                  return null;
                },
              ),
            ),

            SizedBox(height: 18.h),

            // Password Field
            FadeInUp(
              duration: const Duration(milliseconds: 900),
              child: CustomTextField(
                controller: widget.passwordController,
                label: 'كلمة المرور',
                hint: 'أدخل كلمة مرور قوية',
                prefixIcon: Icons.lock_outline,
                obscureText: _passwordObscured,
                suffixIcon: IconButton(
                  onPressed:
                      () => setState(() {
                        _passwordObscured = !_passwordObscured;
                      }),
                  icon: Icon(
                    _passwordObscured ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondary,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'كلمة المرور مطلوبة';
                  }
                  if (value.length < 6) {
                    return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                  }
                  return null;
                },
              ),
            ),

            SizedBox(height: 18.h),

            // Confirm Password Field
            FadeInUp(
              duration: const Duration(milliseconds: 1000),
              child: CustomTextField(
                controller: widget.confirmPasswordController,
                label: 'تأكيد كلمة المرور',
                hint: 'أعد كتابة كلمة المرور',
                prefixIcon: Icons.lock_outline,
                obscureText: _confirmPasswordObscured,
                suffixIcon: IconButton(
                  onPressed:
                      () => setState(() {
                        _confirmPasswordObscured = !_confirmPasswordObscured;
                      }),
                  icon: Icon(
                    _confirmPasswordObscured
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.textSecondary,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'تأكيد كلمة المرور مطلوب';
                  }
                  if (value != widget.passwordController.text) {
                    return 'كلمات المرور غير متطابقة';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
