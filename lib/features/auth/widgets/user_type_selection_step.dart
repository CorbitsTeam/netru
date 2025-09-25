import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:netru_app/core/domain/entities/signup_entities.dart';
import '../../../../core/theme/app_colors.dart';

class UserTypeSelectionStep extends StatelessWidget {
  final UserType? selectedUserType;
  final Function(UserType) onUserTypeSelected;

  const UserTypeSelectionStep({
    super.key,
    this.selectedUserType,
    required this.onUserTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        // FadeInDown(
        //   duration: const Duration(milliseconds: 600),
        //   child: Text(
        //     'اختر نوع المستخدم',
        //     style: TextStyle(
        //       fontSize: 24.sp,
        //       fontWeight: FontWeight.bold,
        //       color: AppColors.textPrimary,
        //     ),
        //   ),
        // ),

        // SizedBox(height: 8.h),

        // FadeInDown(
        //   duration: const Duration(milliseconds: 700),
        //   child: Text(
        //     'اختر النوع المناسب لك لبدء عملية التسجيل',
        //     style: TextStyle(
        //       fontSize: 16.sp,
        //       color: AppColors.textSecondary,
        //       height: 1.5,
        //     ),
        //   ),
        // ),

        // SizedBox(height: 40.h),

        // User type options
        _buildUserTypeOption(
          context: context,
          userType: UserType.citizen,
          title: 'مواطن مصري',
          subtitle: 'أحمل بطاقة رقم قومي مصرية',
          icon: Icons.credit_card,
          delay: 800,
        ),

        SizedBox(height: 20.h),

        _buildUserTypeOption(
          context: context,
          userType: UserType.foreigner,
          title: 'مقيم أجنبي',
          subtitle: 'أحمل جواز سفر أجنبي',
          icon: Icons.travel_explore,
          delay: 900,
        ),

        SizedBox(height: 40.h),

        // Info card
        FadeInUp(
          duration: const Duration(milliseconds: 1000),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 24.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'سيتم طلب مستندات مختلفة حسب نوع المستخدم المختار',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.primary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserTypeOption({
    required BuildContext context,
    required UserType userType,
    required String title,
    required String subtitle,
    required IconData icon,
    required int delay,
  }) {
    final isSelected = selectedUserType == userType;

    return SlideInLeft(
      duration: Duration(milliseconds: delay),
      child: GestureDetector(
        onTap: () => onUserTypeSelected(userType),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color:
                isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                blurRadius: isSelected ? 12 : 8,
                offset: Offset(0, isSelected ? 6 : 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon container
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 45.w,
                height: 45.h,
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColors.primary : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  size: 24.sp,
                ),
              ),

              SizedBox(width: 16.w),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color:
                            isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Selection indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 18.w,
                height: 18.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                        : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
