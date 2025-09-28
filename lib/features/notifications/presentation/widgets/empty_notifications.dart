import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class EmptyNotifications extends StatelessWidget {
  const EmptyNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Notification Icon with improved design
            Container(
              width: 140.w,
              height: 140.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primaryLight.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.notifications_off_rounded,
                size: 70.sp,
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 32.h),

            // Title with improved styling
            Text(
              'لا توجد إشعارات',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 12.h),

            // Subtitle with better formatting
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'لم تتلق أي إشعارات بعد\nسيتم إشعارك فور وصول أي تحديثات مهمة',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                  height: 1.6,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 40.h),

            // Features section with improved design
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: AppColors.borderLight,
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'ستتلقى إشعارات لـ:',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        _buildFeatureItem(
                          icon: Icons.newspaper_rounded,
                          color: AppColors.success,
                          title: 'الأخبار الجديدة',
                          subtitle: 'إشعارات فورية عند نشر أخبار مهمة',
                        ),
                        SizedBox(height: 16.h),
                        _buildFeatureItem(
                          icon: Icons.assignment_turned_in_rounded,
                          color: AppColors.warning,
                          title: 'تحديثات البلاغات',
                          subtitle: 'متابعة حالة بلاغاتك والردود عليها',
                        ),
                        SizedBox(height: 16.h),
                        _buildFeatureItem(
                          icon: Icons.admin_panel_settings_rounded,
                          color: AppColors.info,
                          title: 'تنبيهات النظام',
                          subtitle: 'تحديثات الأمان والصيانة',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 48.w,
          height: 48.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Icon(icon, color: color, size: 24.sp),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                  height: 1.4,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
