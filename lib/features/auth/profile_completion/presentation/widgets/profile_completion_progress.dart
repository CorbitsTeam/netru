import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';

class ProfileCompletionProgress extends StatelessWidget {
  final int currentStep;
  final List<String> stepTitles;

  const ProfileCompletionProgress({
    super.key,
    required this.currentStep,
    required this.stepTitles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Column(
        children: [
          Text(
            'خطوة ${currentStep + 1} من ${stepTitles.length}',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
              fontFamily: 'Almarai',
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            stepTitles[currentStep],
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
              fontFamily: 'Almarai',
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Row(
            children: List.generate(
              stepTitles.length,
              (index) => Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  height: 4.h,
                  decoration: BoxDecoration(
                    color:
                        index <= currentStep
                            ? AppColors.primary
                            : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
