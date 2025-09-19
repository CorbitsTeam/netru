import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:netru_app/core/routing/routes.dart';
import 'package:netru_app/core/utils/user_data_helper.dart';

class UserHeaderWidget extends StatelessWidget {
  const UserHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userHelper = UserDataHelper();
    final isLoggedIn = userHelper.isUserLoggedIn();
    final userName = userHelper.getUserFullName();
    final location = userHelper.getCurrentUser()?.location ?? '';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Notification icon
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: IconButton(
              onPressed:
                  () => Navigator.pushNamed(context, Routes.notificationsPage),
              icon: Icon(
                Icons.notifications_outlined,
                color: AppColors.primary,
                size: 20.sp,
              ),
              padding: EdgeInsets.zero,
            ),
          ),

          SizedBox(width: 12.w),

          // User info section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'الرئيسية',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (isLoggedIn) ...[
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          userName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (location.isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        Container(
                          width: 3.w,
                          height: 3.h,
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: Text(
                            location,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary.withOpacity(0.8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),

          SizedBox(width: 12.w),

          // User profile section
          GestureDetector(
            onTap:
                isLoggedIn
                    ? () => Navigator.pushNamed(context, Routes.profileScreen)
                    : () => Navigator.pushNamed(context, Routes.loginScreen),
            child: Container(
              width: 45.w,
              height: 45.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22.5.r),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: _buildProfileImage(userHelper),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(UserDataHelper userHelper) {
    final profileImage = userHelper.getUserProfileImage();

    if (profileImage != null && profileImage.isNotEmpty) {
      return Image.network(
        profileImage,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) => _buildDefaultAvatar(userHelper),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildDefaultAvatar(userHelper);
        },
      );
    }

    return _buildDefaultAvatar(userHelper);
  }

  Widget _buildDefaultAvatar(UserDataHelper userHelper) {
    final isLoggedIn = userHelper.isUserLoggedIn();
    final firstName = userHelper.getUserFirstName();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary.withOpacity(0.8), AppColors.primary],
        ),
      ),
      child: Center(
        child:
            isLoggedIn && firstName.isNotEmpty
                ? Text(
                  firstName.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                )
                : Icon(Icons.person, color: Colors.white, size: 24.sp),
      ),
    );
  }
}
