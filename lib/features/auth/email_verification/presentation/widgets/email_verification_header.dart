import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../../core/theme/app_colors.dart';

class EmailVerificationHeader extends StatelessWidget {
  final Animation<double> emailIconAnimation;
  final Animation<double> checkAnimation;
  final bool isVerified;
  final String email;

  const EmailVerificationHeader({
    super.key,
    required this.emailIconAnimation,
    required this.checkAnimation,
    required this.isVerified,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withValues(alpha: 0.1),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          children: [
            // Animated email icon with check overlay
            SizedBox(
              width: 120.w,
              height: 120.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: emailIconAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: emailIconAnimation.value,
                        child: Container(
                          width: 100.w,
                          height: 100.h,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.email_outlined,
                            size: 50.sp,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    },
                  ),
                  if (isVerified)
                    AnimatedBuilder(
                      animation: checkAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: checkAnimation.value,
                          child: Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              isVerified
                  ? 'تم تأكيد بريدك الإلكتروني!'
                  : 'تأكيد البريد الإلكتروني',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: isVerified ? Colors.green : const Color(0xFF1F2937),
                fontFamily: 'Almarai',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              isVerified
                  ? 'بريدك الإلكتروني $email مؤكد بنجاح'
                  : 'تم إرسال رمز التفعيل إلى $email',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF6B7280),
                fontFamily: 'Almarai',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
