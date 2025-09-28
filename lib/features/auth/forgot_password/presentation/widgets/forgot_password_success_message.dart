import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../../core/theme/app_colors.dart';

class ForgotPasswordSuccessMessage extends StatelessWidget {
  final String message;
  final VoidCallback onBackToLogin;

  const ForgotPasswordSuccessMessage({
    super.key,
    required this.message,
    required this.onBackToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.green[200]!, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 32.sp,
              ),
            ),

            SizedBox(height: 20.h),

            // Success Title
            Text(
              'تم الإرسال بنجاح!',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
                fontFamily: 'Almarai',
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12.h),

            // Success Message
            Text(
              message,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.green[700],
                fontFamily: 'Almarai',
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 20.h),

            // Additional Instructions
            Text(
              'يرجى التحقق من صندوق الوارد والنقر على الرابط المرسل لإعادة تعيين كلمة المرور. قد تحتاج إلى فحص مجلد الرسائل المرفوضة',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontFamily: 'Almarai',
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 24.h),

            // Back to Login Button
            SizedBox(
              width: double.infinity,
              height: 44.h,
              child: OutlinedButton(
                onPressed: onBackToLogin,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'العودة لتسجيل الدخول',
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
      ),
    );
  }
}
