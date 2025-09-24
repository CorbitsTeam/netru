import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/app_colors.dart';

class StepperIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;

  const StepperIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Column(
        children: [
          // Progress indicator
          Row(
            children: List.generate(totalSteps, (index) {
              final isCompleted = index < currentStep;
              final isCurrent = index == currentStep;

              return Expanded(
                child: Row(
                  children: [
                    // Step circle
                    SlideInDown(
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 36.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isCompleted
                                  ? AppColors.success
                                  : isCurrent
                                  ? AppColors.primary
                                  : AppColors.border,
                          border: Border.all(
                            color:
                                isCompleted
                                    ? AppColors.success
                                    : isCurrent
                                    ? AppColors.primary
                                    : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child:
                              isCompleted
                                  ? Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18.sp,
                                  )
                                  : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color:
                                          isCurrent
                                              ? Colors.white
                                              : AppColors.textSecondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                        ),
                      ),
                    ),

                    // Connection line (except for last step)
                    if (index < totalSteps - 1)
                      Expanded(
                        child: SlideInRight(
                          duration: Duration(milliseconds: 400 + (index * 100)),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 2.h,
                            margin: EdgeInsets.symmetric(horizontal: 8.w),
                            decoration: BoxDecoration(
                              color:
                                  isCompleted
                                      ? AppColors.success
                                      : AppColors.border,
                              borderRadius: BorderRadius.circular(1.r),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),

          SizedBox(height: 12.h),

          // Step title
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            child: Text(
              stepTitles[currentStep],
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
