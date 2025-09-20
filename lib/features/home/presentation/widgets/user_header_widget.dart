import 'package:cached_network_image/cached_network_image.dart';
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
      child: Column(
        children: [
          // Text(
          //   'الرئيسية',
          //   style: TextStyle(
          //     fontSize: 16.sp,
          //     fontWeight: FontWeight.bold,
          //     color: AppColors.textPrimary,
          //   ),
          // ),
          // SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // User profile section - تم تعديله ليكون مشابهًا للصورة
              Row(
                children: [
                  GestureDetector(
                    onTap:
                        isLoggedIn
                            ? () => Navigator.pushNamed(
                              context,
                              Routes.profileScreen,
                            )
                            : () => Navigator.pushNamed(
                              context,
                              Routes.loginScreen,
                            ),
                    child: Container(
                      width: 35.w,
                      height: 35.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: _buildProfileImage(userHelper),
                    ),
                  ),

                  Container(
                    width: 1.5.w,
                    height: 25.h,
                    color: AppColors.primary,
                    margin: EdgeInsets.symmetric(horizontal: 6.w),
                  ),

                  // User info section - تم تعديله ليكون مشابهًا للصورة
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isLoggedIn) ...[
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (location.isNotEmpty) ...[
                          Text(
                            location,
                            style: TextStyle(
                              fontSize: 8.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ] else
                        ...[],
                    ],
                  ),
                ],
              ),

              // Notification icon - تم تعديله ليكون مشابهًا للصورة
              IconButton(
                onPressed:
                    () =>
                        Navigator.pushNamed(context, Routes.notificationsPage),
                icon: Icon(
                  Icons.notifications_sharp,
                  color: AppColors.primary,
                  size: 22.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(UserDataHelper userHelper) {
    final profileImage = userHelper.getUserProfileImage();

    if (profileImage != null && profileImage.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: profileImage,
        fit: BoxFit.cover,
        errorWidget:
            (context, error, stackTrace) => _buildDefaultAvatar(userHelper),
        placeholder: (context, url) => _buildDefaultAvatar(userHelper),
      );
    }

    return _buildDefaultAvatar(userHelper);
  }

  Widget _buildDefaultAvatar(UserDataHelper userHelper) {
    // final isLoggedIn = userHelper.isUserLoggedIn();
    // final firstName = userHelper.getUserFirstName();

    return Center(
      child: Icon(
        Icons.person_outline_rounded,
        color: AppColors.primary,
        size: 22.sp,
      ),
    );
  }
}
