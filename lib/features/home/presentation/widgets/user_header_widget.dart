import 'dart:developer';

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
    final isLoggedIn =
        userHelper.isUserLoggedIn();
    final fullName = userHelper.getUserFullName();
    final firstTwoNames = fullName
        .split(' ')
        .take(2)
        .join(' ');

    final location =
        userHelper.getCurrentUser()?.location ??
        '';
    final firstLocationWord =
        location.split(' ').first;

    log("👤 Name: $firstTwoNames");
    log("📍 Location: $firstLocationWord");

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 12.h,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          // User profile section - تم تعديله ليكون مشابهًا للصورة
          Flexible(
            child: Row(
              children: [
                Container(
                  width: 30.w,
                  height: 30.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: AppColors.primary
                          .withOpacity(0.5),
                      width: 1.w,
                    ),
                  ),
                  child: _buildProfileImage(
                    userHelper,
                  ),
                ),

                Container(
                  width: 1.5.w,
                  height: 20.h,
                  color: AppColors.primary,
                  margin: EdgeInsets.symmetric(
                    horizontal: 4.w,
                  ),
                ),

                // User info section - تم تعديله ليكون مشابهًا للصورة
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    if (isLoggedIn) ...[
                      Text(
                        firstTwoNames,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.black,
                          fontWeight:
                              FontWeight.bold,
                        ),
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                      if (firstLocationWord
                          .isNotEmpty) ...[
                        Text(
                          firstLocationWord,
                          style: TextStyle(
                            fontSize: 8.sp,
                            color: Colors.black,
                            fontWeight:
                                FontWeight.bold,
                          ),
                          overflow:
                              TextOverflow
                                  .ellipsis,
                        ),
                      ],
                    ] else
                      ...[],
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              'الرئيسية',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed:
                () => Navigator.pushNamed(
                  context,
                  Routes.notificationsPage,
                ),
            icon: Icon(
              Icons.notifications_sharp,
              color: AppColors.primary,
              size: 22.sp,
            ),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(
    UserDataHelper userHelper,
  ) {
    final profileImage =
        userHelper.getUserProfileImage();

    if (profileImage != null &&
        profileImage.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: profileImage,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorWidget:
              (context, error, stackTrace) =>
                  _buildDefaultAvatar(userHelper),
          placeholder:
              (context, url) =>
                  _buildDefaultAvatar(userHelper),
        ),
      );
    }

    return _buildDefaultAvatar(userHelper);
  }

  Widget _buildDefaultAvatar(
    UserDataHelper userHelper,
  ) {
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
