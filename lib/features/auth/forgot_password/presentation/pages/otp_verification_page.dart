// NOTE: This page previously threw "A TextEditingController was used after being disposed"
// and "Looking up a deactivated widget's ancestor is unsafe" errors when async
// bloc events tried to call setState() or use ScaffoldMessenger after the
// widget was unmounted. We guard BlocListener callbacks and snack bar helpers
// with `if (!mounted) return;` to avoid using the `BuildContext` or calling
// setState after disposal.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:netru_app/features/auth/widgets/custom_text_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;

  const OtpVerificationPage({
    super.key,
    required this.email,
  });

  @override
  State<OtpVerificationPage> createState() =>
      _OtpVerificationPageState();
}

class _OtpVerificationPageState
    extends State<OtpVerificationPage> {
  final TextEditingController _otpController =
      TextEditingController();
  final TextEditingController
  _newPasswordController =
      TextEditingController();
  final TextEditingController
  _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isOtpVerified = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _otpError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20.sp,
            ),
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
          borderRadius: BorderRadius.circular(
            12.r,
          ),
        ),
        margin: EdgeInsets.all(16.w),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20.sp,
            ),
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
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            12.r,
          ),
        ),
        margin: EdgeInsets.all(16.w),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _verifyOtp() {
    setState(() {
      _otpError = null;
    });

    if (_otpController.text.trim().isEmpty) {
      setState(() {
        _otpError = 'يرجى إدخال رمز التحقق';
      });
      return;
    }

    if (_otpController.text.trim().length != 6) {
      setState(() {
        _otpError =
            'رمز التحقق يجب أن يكون 6 أرقام';
      });
      return;
    }

    context.read<ForgotPasswordCubit>().verifyOtp(
      email: widget.email,
      token: _otpController.text.trim(),
    );
  }

  void _updatePassword() {
    setState(() {
      _passwordError = null;
      _confirmPasswordError = null;
    });

    // Validate password
    if (_newPasswordController.text
        .trim()
        .isEmpty) {
      setState(() {
        _passwordError =
            'يرجى إدخال كلمة المرور الجديدة';
      });
      return;
    }

    if (_newPasswordController.text.length < 6) {
      setState(() {
        _passwordError =
            'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
      });
      return;
    }

    // Validate confirm password
    if (_confirmPasswordController.text
        .trim()
        .isEmpty) {
      setState(() {
        _confirmPasswordError =
            'يرجى تأكيد كلمة المرور';
      });
      return;
    }

    if (_newPasswordController.text !=
        _confirmPasswordController.text) {
      setState(() {
        _confirmPasswordError =
            'كلمات المرور غير متطابقة';
      });
      return;
    }

    context
        .read<ForgotPasswordCubit>()
        .updatePassword(
          email: widget.email,
          newPassword:
              _newPasswordController.text.trim(),
        );
  }

  void _resendOtp() {
    context.read<ForgotPasswordCubit>().sendOtp(
      widget.email,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20.sp,
          ),
          onPressed:
              () => Navigator.of(context).pop(),
        ),
        title: Text(
          'تحقق من الرمز',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontFamily: 'Almarai',
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<
        ForgotPasswordCubit,
        ForgotPasswordState
      >(
        listener: (context, state) {
          // If the widget was unmounted while waiting for bloc events,
          // avoid calling setState or using the BuildContext.
          if (!mounted) return;

          if (state is ForgotPasswordLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state is ForgotPasswordOtpSent) {
            _showSuccessSnackBar(state.message);
          } else if (state
              is ForgotPasswordOtpVerified) {
            _showSuccessSnackBar(state.message);
            setState(() {
              _isOtpVerified = true;
            });
          } else if (state
              is ForgotPasswordSuccess) {
            _showSuccessSnackBar(state.message);
            // Navigate back to login after successful password reset
            Navigator.of(
              context,
            ).popUntil((route) => route.isFirst);
          } else if (state
              is ForgotPasswordFailure) {
            _showErrorSnackBar(state.error);
          } else if (state
              is ForgotPasswordValidationError) {
            if (state.fieldName == 'otp') {
              setState(() {
                _otpError = state.error;
              });
            } else if (state.fieldName ==
                'password') {
              setState(() {
                _passwordError = state.error;
              });
            }
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 24.w,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40.h),

                  // Header Icon
                  Center(
                    child: Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        color:
                            _isOtpVerified
                                ? AppColors
                                    .success
                                    .withOpacity(
                                      0.1,
                                    )
                                : AppColors
                                    .primary
                                    .withOpacity(
                                      0.1,
                                    ),
                        borderRadius:
                            BorderRadius.circular(
                              40.r,
                            ),
                      ),
                      child: Icon(
                        _isOtpVerified
                            ? Icons.lock_open
                            : Icons.security,
                        color:
                            _isOtpVerified
                                ? AppColors
                                    .success
                                : AppColors
                                    .primary,
                        size: 40.sp,
                      ),
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // Title
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        _isOtpVerified
                            ? 'كلمة المرور الجديدة'
                            : 'رمز التحقق',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              AppColors
                                  .textPrimary,
                          fontFamily: 'Almarai',
                        ),
                        textAlign:
                            TextAlign.center,
                      ),
                    ],
                  ),

                  SizedBox(height: 10.h),

                  // Description
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        _isOtpVerified
                            ? 'أدخل كلمة المرور الجديدة لحسابك'
                            : 'أدخل الرمز المرسل إلى ${widget.email}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color:
                              AppColors
                                  .textSecondary,
                          fontFamily: 'Almarai',
                          height: 1.5,
                        ),
                        textAlign:
                            TextAlign.center,
                      ),
                    ],
                  ),

                  SizedBox(height: 40.h),

                  if (!_isOtpVerified) ...[
                    // OTP Input
                    Directionality(
                      textDirection:
                          TextDirection.ltr,
                      child: PinCodeTextField(
                        appContext: context,
                        length: 6,
                        controller:
                            _otpController,
                        keyboardType:
                            TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter
                              .digitsOnly,
                        ],
                        textStyle: TextStyle(
                          fontSize: 20.sp,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              AppColors
                                  .textPrimary,
                        ),
                        pinTheme: PinTheme(
                          shape:
                              PinCodeFieldShape
                                  .box,
                          borderRadius:
                              BorderRadius.circular(
                                12.r,
                              ),
                          fieldHeight: 50.h,
                          fieldWidth: 45.w,
                          activeFillColor:
                              Colors.white,
                          inactiveFillColor:
                              Colors.white,
                          selectedFillColor:
                              Colors.white,
                          activeColor:
                              AppColors.primary,
                          inactiveColor:
                              AppColors.border,
                          selectedColor:
                              AppColors.primary,
                          borderWidth: 2,
                        ),
                        enableActiveFill: true,
                        onChanged: (value) {
                          setState(() {
                            _otpError = null;
                          });
                        },
                        onCompleted: (value) {
                          _verifyOtp();
                        },
                      ),
                    ),

                    if (_otpError != null) ...[
                      SizedBox(height: 8.h),
                      Text(
                        _otpError!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.error,
                          fontFamily: 'Almarai',
                        ),
                        textAlign:
                            TextAlign.center,
                      ),
                    ],

                    SizedBox(height: 32.h),

                    // Verify OTP Button
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.primary,
                          foregroundColor:
                              Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                  12.r,
                                ),
                          ),
                          disabledBackgroundColor:
                              AppColors.disabled,
                        ),
                        child:
                            _isLoading
                                ? SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                    valueColor:
                                        AlwaysStoppedAnimation<
                                          Color
                                        >(
                                          Colors
                                              .white,
                                        ),
                                  ),
                                )
                                : Text(
                                  'تحقق من الرمز',
                                  style: TextStyle(
                                    fontSize:
                                        16.sp,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                    fontFamily:
                                        'Almarai',
                                  ),
                                ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Resend OTP Link
                    Center(
                      child: TextButton(
                        onPressed:
                            _isLoading
                                ? null
                                : _resendOtp,
                        child: Text(
                          'إعادة إرسال الرمز',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color:
                                AppColors.primary,
                            fontFamily: 'Almarai',
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Password Fields
                    CustomTextField(
                      label:
                          'كلمة المرور الجديدة',
                      hint:
                          'أدخل كلمة المرور الجديدة',
                      controller:
                          _newPasswordController,
                      obscureText:
                          _obscurePassword,
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons
                                  .visibility_off
                              : Icons.visibility,
                          color:
                              AppColors
                                  .textSecondary,
                          size: 20.sp,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },
                      ),
                      errorText: _passwordError,
                      textInputAction:
                          TextInputAction.next,
                    ),

                    SizedBox(height: 20.h),

                    CustomTextField(
                      label: 'تأكيد كلمة المرور',
                      hint:
                          'أعد إدخال كلمة المرور',
                      controller:
                          _confirmPasswordController,
                      obscureText:
                          _obscureConfirmPassword,
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons
                                  .visibility_off
                              : Icons.visibility,
                          color:
                              AppColors
                                  .textSecondary,
                          size: 20.sp,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                          });
                        },
                      ),
                      errorText:
                          _confirmPasswordError,
                      textInputAction:
                          TextInputAction.done,
                      onFieldSubmitted:
                          (_) =>
                              _updatePassword(),
                    ),

                    SizedBox(height: 40.h),

                    // Update Password Button
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : _updatePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.success,
                          foregroundColor:
                              Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                  12.r,
                                ),
                          ),
                          disabledBackgroundColor:
                              AppColors.disabled,
                        ),
                        child:
                            _isLoading
                                ? SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                    valueColor:
                                        AlwaysStoppedAnimation<
                                          Color
                                        >(
                                          Colors
                                              .white,
                                        ),
                                  ),
                                )
                                : Text(
                                  'تحديث كلمة المرور',
                                  style: TextStyle(
                                    fontSize:
                                        16.sp,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                    fontFamily:
                                        'Almarai',
                                  ),
                                ),
                      ),
                    ),
                  ],

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
