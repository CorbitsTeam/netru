import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/app_colors.dart';

/// Custom dots indicator for onboarding pages
class CustomOnboardingDots extends StatelessWidget {
  final int currentIndex;
  final int totalDots;
  final Function(int) onDotTapped;

  const CustomOnboardingDots({
    super.key,
    required this.currentIndex,
    required this.totalDots,
    required this.onDotTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalDots,
        (index) => FadeIn(
          duration: Duration(milliseconds: 300 + (index * 100)),
          child: GestureDetector(
            onTap: () => onDotTapped(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              height: 8.h,
              width: index == currentIndex ? 24.w : 8.w,
              decoration: BoxDecoration(
                color:
                    index == currentIndex
                        ? AppColors.primaryColor
                        : AppColors.primaryColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Advanced dots indicator with progress animation
class ProgressOnboardingDots extends StatelessWidget {
  final int currentIndex;
  final int totalDots;
  final Function(int) onDotTapped;

  const ProgressOnboardingDots({
    super.key,
    required this.currentIndex,
    required this.totalDots,
    required this.onDotTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalDots,
        (index) => FadeIn(
          duration: Duration(milliseconds: 300 + (index * 100)),
          child: GestureDetector(
            onTap: () => onDotTapped(index),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  Container(
                    height: 12.h,
                    width: 12.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  // Active dot
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: index == currentIndex ? 12.h : 6.h,
                    width: index == currentIndex ? 12.w : 6.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          index == currentIndex
                              ? AppColors.primaryColor
                              : index < currentIndex
                              ? AppColors.primaryColor.withValues(alpha: 0.6)
                              : AppColors.primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
