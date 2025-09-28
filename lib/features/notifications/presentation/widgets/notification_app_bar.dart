import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

class NotificationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onMarkAllAsRead;
  final int unreadCount;

  const NotificationAppBar({
    super.key,
    required this.onMarkAllAsRead,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: const BoxDecoration(
      // color: Colors.white,
      //   boxShadow: [
      //     BoxShadow(
      //       color: AppColors.shadow,
      //       blurRadius: 8,
      //       offset: Offset(0, 2),
      //     ),
      //   ],
      // ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.borderLight, width: 1),
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary,
              size: 18.sp,
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primaryLight.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.notifications_active_rounded,
                color: AppColors.primary,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'التنبيهات',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            if (unreadCount > 0) ...[
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.error, AppColors.errorLight],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '$unreadCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (unreadCount > 0)
            Container(
              margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
              child: ElevatedButton.icon(
                onPressed: onMarkAllAsRead,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: AppColors.primary.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                ),
                icon: Icon(Icons.done_all_rounded, size: 16.sp),
                label: Text(
                  'قراءة الكل',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          SizedBox(width: 8.w),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.h);
}
