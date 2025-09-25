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
      // title: 'بيانات الدخول الأساسية',
      subtitle: 'أدخل بريدك الإلكتروني وكلمة مرور قوية',
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Username Field (Email or Phone)
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: CustomTextField(
                controller: widget.usernameController,
                label: 'البريد الإلكتروني',
                hint: 'أدخل بريدك الإلكتروني',
                prefixIcon: Icons.email_outlined,
                keyboardType:
                    widget.isEmailMode
                        ? TextInputType.emailAddress
                        : TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'البريد الإلكتروني مطلوب';
                  }
                  if (widget.isEmailMode) {
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'أدخل بريد إلكتروني صحيح';
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
