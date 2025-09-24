import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/features/auth/widgets/animated_button.dart';
import '../../../../../core/theme/app_colors.dart';

class SignupNavigationButtons extends StatelessWidget {
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final String nextButtonText;
  final String previousButtonText;
  final bool isLoading;
  final bool canProceed;
  final bool showPreviousButton;

  const SignupNavigationButtons({
    super.key,
    this.onPrevious,
    this.onNext,
    this.nextButtonText = 'التالي',
    this.previousButtonText = 'السابق',
    this.isLoading = false,
    this.canProceed = true,
    this.showPreviousButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showPreviousButton && onPrevious != null) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : onPrevious,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  minimumSize: Size(double.infinity, 48.h),
                ),
                child: Text(
                  previousButtonText,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Almarai',
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
          ],
          Expanded(
            flex: showPreviousButton ? 1 : 2,
            child: AnimatedButton(
              text: nextButtonText,
              onPressed: (canProceed && !isLoading) ? onNext : null,
              isLoading: isLoading,
              backgroundColor: AppColors.primary,
              textColor: Colors.white,
              borderRadius: 12.r,
              height: 48.h,
            ),
          ),
        ],
      ),
    );
  }
}
