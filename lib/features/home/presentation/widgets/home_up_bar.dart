import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/constants/app_constants.dart';

class HomeUpBar extends StatelessWidget {
  const HomeUpBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 10.h,
      ),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                width: 30.w,
                height: 30.h,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
                child: ClipOval(
                  child: Image.asset(
                      AppAssets.imageProfile,
                      fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 1.w,
                height: 28.h,
                color: AppColors.primaryColor,
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Text(
                    "أحمد اسعد",
                    style: TextStyle(
                      fontSize: 11.sp,
                    ),
                  ),
                  Text(
                    "القاهره",
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(
            flex: 1,
          ),
          Text(
            "home".tr(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(
            flex: 2,
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications,
              color: AppColors.primaryColor,
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }
}
