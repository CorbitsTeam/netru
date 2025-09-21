import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:netru_app/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:netru_app/features/onboarding/presentation/cubit/onboarding_state.dart';
import '../../../../core/theme/app_colors.dart';

/// Data model for onboarding slide content
class OnboardingSlideData {
  final String image;
  final String title;
  final String subtitle;

  const OnboardingSlideData({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}

/// Reusable onboarding slide widget
class OnboardingSlide extends StatelessWidget {
  final OnboardingSlideData slideData;
  final int slideIndex;

  const OnboardingSlide({
    super.key,
    required this.slideData,
    required this.slideIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Image with animation
        Expanded(
          flex: 5,
          child: Stack(
            children: [
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: Duration(milliseconds: 100 * slideIndex),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        blurRadius: 20.r,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    slideData.image,
                    fit: BoxFit.cover,
                    width: double.infinity,

                    height: 877.h,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback for missing images
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryColor.withValues(alpha: 0.3),
                              AppColors.primaryColor.withValues(alpha: 0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Icon(
                          Icons.image_outlined,
                          size: 80.sp,
                          color: AppColors.primaryColor,
                        ),
                      );
                    },
                  ),
                ),
              ),

              Align(
                alignment: AlignmentDirectional.topStart,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(top: 40.h),
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 200),
                    child: BlocBuilder<OnboardingCubit, OnboardingState>(
                      builder: (context, state) {
                        final cubit = context.read<OnboardingCubit>();
                        return TextButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            cubit.skipOnboarding();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.background,
                            padding: EdgeInsets.symmetric(
                              horizontal: 22.w,
                              // vertical: 8.h,
                            ),
                          ),
                          child: Text(
                            'تخطي',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.background,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        // Title with animation
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          delay: Duration(milliseconds: 200 * slideIndex),
          child: Text(
            slideData.title,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        SizedBox(height: 16.h),

        // Subtitle with animation
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          delay: Duration(milliseconds: 300 * slideIndex),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 22.0.w),
            child: Text(
              slideData.subtitle,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        SizedBox(height: 40.h),
      ],
    );
  }
}
