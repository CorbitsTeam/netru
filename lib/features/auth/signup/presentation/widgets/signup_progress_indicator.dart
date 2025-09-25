import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../../core/theme/app_colors.dart';

class SignupProgressIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> stepTitles;

  const SignupProgressIndicator({
    super.key,
    required this.currentStep,
    required this.stepTitles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Current step info
          FadeInDown(
            duration: const Duration(milliseconds: 400),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Column(
                children: [
                  Text(
                    'خطوة ${currentStep + 1} من ${stepTitles.length}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    stepTitles[currentStep],
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Progress steps
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(stepTitles.length * 2 - 1, (index) {
              if (index.isOdd) {
                // This is a connector line
                final stepIndex = index ~/ 2;
                return Container(
                  width: 4.w,
                  height: 3.h,
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  decoration: BoxDecoration(
                    color:
                        stepIndex < currentStep
                            ? AppColors.success
                            : AppColors.border.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                );
              } else {
                // This is a step circle
                final stepIndex = index ~/ 2;
                final isCompleted = stepIndex < currentStep;
                final isCurrent = stepIndex == currentStep;

                return Flexible(
                  child: SlideInUp(
                    duration: Duration(milliseconds: 300 + (stepIndex * 100)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 35.w,
                      height: 35.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isCompleted
                                ? AppColors.success
                                : isCurrent
                                ? AppColors.primary
                                : Colors.white,
                        border: Border.all(
                          color:
                              isCompleted
                                  ? AppColors.success
                                  : isCurrent
                                  ? AppColors.primary
                                  : AppColors.border.withValues(alpha: 0.5),
                          width: 2.5,
                        ),
                        boxShadow:
                            isCurrent || isCompleted
                                ? [
                                  BoxShadow(
                                    color: (isCompleted
                                            ? AppColors.success
                                            : AppColors.primary)
                                        .withValues(alpha: 0.3),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                                : null,
                      ),
                      child: Center(
                        child:
                            isCompleted
                                ? FadeIn(
                                  duration: const Duration(milliseconds: 300),
                                  child: Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 22.sp,
                                  ),
                                )
                                : Text(
                                  '${stepIndex + 1}',
                                  style: TextStyle(
                                    color:
                                        isCurrent
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                  ),
                );
              }
            }),
          ),

          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}
