import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';

class SignupStepContainer extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final Duration animationDuration;
  final int animationDelay;

  const SignupStepContainer({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.animationDuration = const Duration(milliseconds: 600),
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: animationDuration,
      delay: Duration(milliseconds: animationDelay),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                  fontFamily: 'Almarai',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
            ],
            if (subtitle != null) ...[
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                  fontFamily: 'Almarai',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
