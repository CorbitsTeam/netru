import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/constants/app_assets.dart';
import 'package:netru_app/features/profile/presentation/widgets/account_info.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'الأعدادات',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30.r,
                      backgroundImage:
                          const AssetImage(
                            AppAssets
                                .imageProfile,
                          ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      'عبدالرحمن سمكه',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'القاهره',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 30.h),
            Text(
              'معلومات الحساب',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 25.h),
            const AccountInfo(),
          ],
        ),
      ),
    );
  }
}
