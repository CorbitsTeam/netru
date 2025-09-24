import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';

class ProfileCompletionHeader extends StatelessWidget {
  final int currentStep;
  final List<String> stepTitles;

  const ProfileCompletionHeader({
    super.key,
    required this.currentStep,
    required this.stepTitles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            'إكمال الملف الشخصي',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
              fontFamily: 'Almarai',
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'أكمل بياناتك لإنشاء حسابك',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF6B7280),
              fontFamily: 'Almarai',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
