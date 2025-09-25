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
      padding: EdgeInsets.all(18.w),
      child: Row(
        children: [
          if (showPreviousButton && onPrevious != null)
            Expanded(
              child: AnimatedButton(
                text: previousButtonText,
                onPressed: isLoading ? null : onPrevious,
                backgroundColor: Colors.grey[300],
                textColor: AppColors.textPrimary,
                height: 38.h,
              ),
            ),
          if (showPreviousButton && onPrevious != null) SizedBox(width: 16.w),
          Expanded(
            flex: showPreviousButton ? 2 : 1,
            child: AnimatedButton(
              text: nextButtonText,
              onPressed: (canProceed && !isLoading) ? onNext : null,
              isLoading: isLoading,
              height: 38.h,
            ),
          ),
        ],
      ),
    );
  }
}
