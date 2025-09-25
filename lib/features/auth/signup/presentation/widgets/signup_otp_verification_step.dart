import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../../core/theme/app_colors.dart';
import 'signup_step_container.dart';

class SignupOTPVerificationStep extends StatelessWidget {
  final bool isEmailMode;
  final String username;
  final bool isVerified;
  final bool isCheckingVerification;
  final String otpCode;
  final TextEditingController otpController;
  final StreamController<ErrorAnimationType>? otpErrorController;
  final int resendCountdown;
  final ValueChanged<String> onOTPChanged;
  final VoidCallback? onOTPCompleted;
  final VoidCallback? onResendOTP;

  const SignupOTPVerificationStep({
    super.key,
    required this.isEmailMode,
    required this.username,
    required this.isVerified,
    required this.isCheckingVerification,
    required this.otpCode,
    required this.otpController,
    required this.otpErrorController,
    required this.resendCountdown,
    required this.onOTPChanged,
    this.onOTPCompleted,
    this.onResendOTP,
  });

  @override
  Widget build(BuildContext context) {
    return SignupStepContainer(
      subtitle:
          isVerified
              ? 'تم تأكيد هويتك بنجاح. يمكنك الآن المتابعة.'
              : isEmailMode
              ? 'تم إرسال رمز التأكيد إلى بريدك الإلكتروني\nيرجى إدخال الرمز المكون من 6 أرقام'
              : 'تم إرسال رمز التأكيد إلى رقم هاتفك\nيرجى إدخال الرمز المكون من 6 أرقام',
      child: Column(
        children: [
          // Username display
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              username,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),

          SizedBox(height: 32.h),

          if (!isVerified) ...[
            _buildOTPInput(),
            SizedBox(height: 24.h),
            _buildResendButton(),
          ],

          // Checking indicator
          if (isCheckingVerification) _buildCheckingIndicator(),
        ],
      ),
    );
  }

  Widget _buildOTPInput() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          Text(
            'أدخل رمز التأكيد',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 20.h),
          Builder(
            builder:
                (context) => Directionality(
                  textDirection: TextDirection.ltr, // Force LTR for OTP
                  child: PinCodeTextField(
                    appContext: context,
                    pastedTextStyle: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    length: 6,
                    obscureText: false,
                    obscuringCharacter: '*',
                    blinkWhenObscuring: true,
                    animationType: AnimationType.fade,
                    validator: (v) {
                      if (v!.length < 6) {
                        return "يجب إدخال الرمز كاملاً";
                      } else {
                        return null;
                      }
                    },
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(12.r),
                      fieldHeight: 48.h,
                      fieldWidth: 48.w,
                      activeFillColor: Colors.white,
                      inactiveFillColor: Colors.white,
                      selectedFillColor: Colors.white,
                      activeColor: AppColors.primary,
                      inactiveColor: Colors.grey.shade300,
                      selectedColor: AppColors.primary,
                      borderWidth: 2,
                      errorBorderColor: AppColors.error,
                    ),
                    cursorColor: AppColors.primary,
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: true,
                    errorAnimationController: otpErrorController,
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    boxShadows: const [
                      BoxShadow(
                        offset: Offset(0, 1),
                        color: Colors.black12,
                        blurRadius: 10,
                      ),
                    ],
                    onCompleted: (v) {
                      print("OTP Completed: $v");
                      onOTPCompleted?.call();
                    },
                    onChanged: (value) {
                      print("OTP Changed: $value");
                      onOTPChanged(value);
                    },
                    beforeTextPaste: (text) {
                      print("Allowing to paste $text");
                      return true;
                    },
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildResendButton() {
    return FadeInUp(
      duration: const Duration(milliseconds: 700),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'لم تستلم الرمز؟ ',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
          GestureDetector(
            onTap: resendCountdown == 0 ? onResendOTP : null,
            child: Text(
              resendCountdown > 0
                  ? 'إعادة الإرسال بعد $resendCountdown ثانية'
                  : (isEmailMode ? 'إعادة إرسال الرمز' : 'إعادة إرسال رمز SMS'),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color:
                    resendCountdown == 0 ? AppColors.primary : Colors.grey[400],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckingIndicator() {
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Column(
        children: [
          SizedBox(height: 20.h),
          SizedBox(
            width: 30.w,
            height: 30.h,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'جاري التحقق من الرمز...',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
