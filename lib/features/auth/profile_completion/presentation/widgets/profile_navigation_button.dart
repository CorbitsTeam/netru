import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:netru_app/features/auth/signup/presentation/cubits/signup_cubit.dart';
import 'package:netru_app/features/auth/signup/presentation/cubits/signup_state.dart';
import 'package:netru_app/features/auth/widgets/animated_button.dart';

class ProfileNavigationButtons extends StatelessWidget {
  final int currentStep;
  final bool canProceed;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onSubmit;

  const ProfileNavigationButtons({
    super.key,
    required this.currentStep,
    required this.canProceed,
    required this.onNext,
    required this.onPrevious,
    required this.onSubmit,
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
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous Button
          if (currentStep > 0) ...[
            Expanded(
              child: AnimatedButton(
                text: 'السابق',
                onPressed: onPrevious,
                backgroundColor: Colors.grey[300],
                textColor: Colors.grey[700],
                height: 50.h,
              ),
            ),
            SizedBox(width: 16.w),
          ],

          // Next/Submit Button
          Expanded(
            child: BlocBuilder<SignupCubit, SignupState>(
              builder: (context, state) {
                final isLastStep = currentStep == 2; // Assuming 3 steps (0,1,2)
                final isLoading = state is SignupLoading;

                return AnimatedButton(
                  text: isLastStep ? 'إكمال التسجيل' : 'التالي',
                  onPressed:
                      canProceed ? (isLastStep ? onSubmit : onNext) : null,
                  backgroundColor: AppColors.primary,
                  height: 50.h,
                  isLoading: isLoading,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
