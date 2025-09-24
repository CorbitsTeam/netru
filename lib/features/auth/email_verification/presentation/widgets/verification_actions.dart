import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../../core/theme/app_colors.dart';

class VerificationActions extends StatelessWidget {
  final VoidCallback? onVerifyOTP;
  final VoidCallback? onResend;
  final VoidCallback? onContinue;
  final bool isVerified;
  final bool isVerifyingOTP;
  final bool isResending;
  final int resendCooldown;
  final String otpCode;

  const VerificationActions({
    super.key,
    this.onVerifyOTP,
    this.onResend,
    this.onContinue,
    required this.isVerified,
    this.isVerifyingOTP = false,
    this.isResending = false,
    this.resendCooldown = 0,
    this.otpCode = '',
  });

  @override
  Widget build(BuildContext context) {
    if (isVerified) {
      return _buildVerifiedActions();
    }

    return _buildVerificationActions();
  }

  Widget _buildVerifiedActions() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 24.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'تم تفعيل حسابك بنجاح! يمكنك الآن إكمال إعداد ملفك الشخصي.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.green.shade700,
                      fontFamily: 'Almarai',
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'متابعة إعداد الملف الشخصي',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Almarai',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationActions() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed:
                  otpCode.length == 6 && !isVerifyingOTP ? onVerifyOTP : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child:
                  isVerifyingOTP
                      ? SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : Text(
                        'تأكيد الرمز',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Almarai',
                        ),
                      ),
            ),
          ),
          SizedBox(height: 20.h),
          TextButton(
            onPressed: resendCooldown == 0 && !isResending ? onResend : null,
            child:
                isResending
                    ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'يتم إعادة الإرسال...',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Almarai',
                          ),
                        ),
                      ],
                    )
                    : Text(
                      resendCooldown > 0
                          ? 'إعادة الإرسال بعد $resendCooldown ثانية'
                          : 'لم تتلق رمزًا؟ إعادة إرسال',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color:
                            resendCooldown > 0
                                ? const Color(0xFF6B7280)
                                : AppColors.primary,
                        fontFamily: 'Almarai',
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
