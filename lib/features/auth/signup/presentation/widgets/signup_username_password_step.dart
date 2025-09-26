import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../widgets/validated_text_form_field.dart';
import 'signup_step_container.dart';

class SignupUsernamePasswordStep
    extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController
  confirmPasswordController;
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
  State<SignupUsernamePasswordStep>
  createState() =>
      _SignupUsernamePasswordStepState();
}

class _SignupUsernamePasswordStepState
    extends State<SignupUsernamePasswordStep> {
  bool _passwordObscured = true;
  bool _confirmPasswordObscured = true;
  late VoidCallback _passwordListener;

  @override
  void initState() {
    super.initState();
    // Create listener to password controller to update UI when text changes
    _passwordListener = () {
      setState(
        () {},
      ); // Rebuild to update password strength indicator
    };
    widget.passwordController.addListener(
      _passwordListener,
    );
  }

  @override
  void dispose() {
    // Remove listener before disposal
    widget.passwordController.removeListener(
      _passwordListener,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SignupStepContainer(
      // title: 'بيانات الدخول الأساسية',
      // subtitle: 'أدخل بريدك الإلكتروني وكلمة مرور قوية',
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.center,
          children: [
            // Username Field (Email or Phone)
            FadeInUp(
              duration: const Duration(
                milliseconds: 800,
              ),
              child: ValidatedTextFormField(
                controller:
                    widget.usernameController,
                label:
                    widget.isEmailMode
                        ? 'البريد الإلكتروني'
                        : 'رقم الهاتف',
                hint:
                    widget.isEmailMode
                        ? 'أدخل بريدك الإلكتروني'
                        : 'أدخل رقم هاتفك',
                prefixIcon: Icon(
                  widget.isEmailMode
                      ? Icons.email_outlined
                      : Icons.phone_outlined,
                  color: AppColors.textSecondary,
                  size: 20.sp,
                ),
                keyboardType:
                    widget.isEmailMode
                        ? TextInputType
                            .emailAddress
                        : TextInputType.phone,
                validationType:
                    widget.isEmailMode
                        ? ValidationType.email
                        : ValidationType.phone,
                realTimeValidation: true,
                showValidationIcon: true,
              ),
            ),

            SizedBox(height: 18.h),

            // Password Field
            FadeInUp(
              duration: const Duration(
                milliseconds: 900,
              ),
              child: Column(
                children: [
                  ValidatedTextFormField(
                    controller:
                        widget.passwordController,
                    label: 'كلمة المرور',
                    hint:
                        'أدخل كلمة مرور قوية (8 أحرف على الأقل)',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color:
                          AppColors.textSecondary,
                      size: 20.sp,
                    ),
                    obscureText:
                        _passwordObscured,
                    suffixIcon: IconButton(
                      onPressed:
                          () => setState(() {
                            _passwordObscured =
                                !_passwordObscured;
                          }),
                      icon: Icon(
                        _passwordObscured
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color:
                            AppColors
                                .textSecondary,
                        size: 20.sp,
                      ),
                    ),
                    validationType:
                        ValidationType.password,
                    realTimeValidation: true,
                    showValidationIcon:
                        false, // We'll show strength indicator instead
                  ),
                  // Password strength indicator
                  PasswordStrengthIndicator(
                    password:
                        widget
                            .passwordController
                            .text,
                    show:
                        widget
                            .passwordController
                            .text
                            .isNotEmpty,
                  ),
                ],
              ),
            ),

            SizedBox(height: 18.h),

            // Confirm Password Field
            FadeInUp(
              duration: const Duration(
                milliseconds: 1000,
              ),
              child: ValidatedTextFormField(
                controller:
                    widget
                        .confirmPasswordController,
                label: 'تأكيد كلمة المرور',
                hint: 'أعد كتابة كلمة المرور',
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: AppColors.textSecondary,
                  size: 20.sp,
                ),
                obscureText:
                    _confirmPasswordObscured,
                suffixIcon: IconButton(
                  onPressed:
                      () => setState(() {
                        _confirmPasswordObscured =
                            !_confirmPasswordObscured;
                      }),
                  icon: Icon(
                    _confirmPasswordObscured
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color:
                        AppColors.textSecondary,
                    size: 20.sp,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'تأكيد كلمة المرور مطلوب';
                  }
                  if (value !=
                      widget
                          .passwordController
                          .text) {
                    return 'كلمات المرور غير متطابقة';
                  }
                  return null;
                },
                realTimeValidation: true,
                showValidationIcon: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
