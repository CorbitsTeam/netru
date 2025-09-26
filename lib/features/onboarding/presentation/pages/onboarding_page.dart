import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../widgets/onboarding_slide.dart';
import '../widgets/onboarding_dots.dart';

/// Main onboarding page with slides and navigation
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  // Onboarding slides data - can be easily modified or localized
  static const List<OnboardingSlideData>
  _slides = [
    OnboardingSlideData(
      image: AppAssets.onboarding1,
      title: "بلغ بسهولة وسرعة",
      subtitle:
          "أرسل بلاغك فورًا بخطوة واحدة، مع تحديد الموقع تلقائيًا وحماية خصوصيتك.",
    ),
    OnboardingSlideData(
      image:
          AppAssets
              .onboarding2, // Using media or custom onboarding image
      title: "مساعدك الذكي دومًا معك",
      subtitle:
          "سوبيك يوجّهك قانونيا ويقدّم نصائح أمنية فورية.",
    ),
    OnboardingSlideData(
      image:
          AppAssets
              .onboarding3, // Using media2 or custom onboarding image

      title: 'اعرف مستوى الأمان حولك',
      subtitle:
          "شاهد مناطق الأمان والخطر بالألوان لحماية نفسك واختيار طريقك بأمان.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingCubit(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      OnboardingCubit,
      OnboardingState
    >(
      listener: (context, state) {
        if (state is OnboardingCompleted) {
          // Navigate to login screen
          context
              .read<OnboardingCubit>()
              .navigateToLogin(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Main content area with PageView
            Expanded(
              flex: 6,
              child: _buildPageView(context),
            ),

            // Bottom section with dots and navigation
            _buildBottomSection(context),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  /// Top section with skip button

  /// Main PageView with slides
  Widget _buildPageView(BuildContext context) {
    return BlocBuilder<
      OnboardingCubit,
      OnboardingState
    >(
      builder: (context, state) {
        final cubit =
            context.read<OnboardingCubit>();

        return PageView.builder(
          controller: cubit.pageController,
          onPageChanged: (index) {
            // Close keyboard if open
            FocusScope.of(context).unfocus();
            cubit.onPageChanged(index);
          },
          itemCount:
              OnboardingPage._slides.length,
          itemBuilder: (context, index) {
            return OnboardingSlide(
              slideData:
                  OnboardingPage._slides[index],
              slideIndex: index,
            );
          },
        );
      },
    );
  }

  /// Bottom section with dots indicator and navigation buttons
  Widget _buildBottomSection(
    BuildContext context,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24.w,
      ),
      child: BlocBuilder<
        OnboardingCubit,
        OnboardingState
      >(
        builder: (context, state) {
          final cubit =
              context.read<OnboardingCubit>();
          final currentIndex = cubit.currentIndex;
          final isLastPage = cubit.isLastPage;

          return Column(
            children: [
              // Dots indicator
              FadeInUp(
                duration: const Duration(
                  milliseconds: 600,
                ),
                child: CustomOnboardingDots(
                  currentIndex: currentIndex,
                  totalDots:
                      OnboardingPage
                          ._slides
                          .length,
                  onDotTapped: (index) {
                    HapticFeedback.selectionClick();
                    cubit.goToPage(index);
                  },
                ),
              ),

              SizedBox(height: 32.h),

              // Navigation buttons
              Row(
                children: [
                  // Previous button (only show if not on first page)
                  if (currentIndex > 0)
                    FadeInLeft(
                      duration: const Duration(
                        milliseconds: 400,
                      ),
                      child: _buildNavigationButton(
                        context: context,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          cubit.previousPage();
                        },
                        text: 'السابق',
                        isSecondary: true,
                      ),
                    ),

                  const Spacer(),

                  // Next/Start button
                  FadeInRight(
                    duration: const Duration(
                      milliseconds: 400,
                    ),
                    child: _buildNavigationButton(
                      context: context,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        cubit.nextPage();
                      },
                      text:
                          isLastPage
                              ? 'ابدأ الآن'
                              : 'التالي',
                      isSecondary: false,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  /// Navigation button widget
  Widget _buildNavigationButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required String text,
    required bool isSecondary,
  }) {
    return Container(
      height: 40.h,
      constraints: BoxConstraints(
        minWidth: 100.w,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSecondary
                  ? Colors.transparent
                  : AppColors.primaryColor,
          foregroundColor:
              isSecondary
                  ? AppColors.primaryColor
                  : Colors.white,
          side:
              isSecondary
                  ? const BorderSide(
                    color: AppColors.primaryColor,
                    width: 1.5,
                  )
                  : null,
          elevation: isSecondary ? 0 : 2,
          shadowColor: AppColors.primaryColor
              .withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              25.r,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 24.w,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!isSecondary) ...[
              SizedBox(width: 8.w),
              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
