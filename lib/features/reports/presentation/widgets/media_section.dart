import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

class MediaSection extends StatelessWidget {
  const MediaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'media'.tr(),
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 170.w,
              height: 100.h,
              decoration: BoxDecoration(
                color: AppColors.grey
                    .withValues(alpha: 0.12),
                borderRadius:
                    BorderRadius.circular(8.r),
                image: const DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(
                    AppAssets.media,
                  ),
                ),
              ),
            ),
            Container(
              width: 170.w,
              height: 100.h,
              decoration: BoxDecoration(
                color: AppColors.grey
                    .withValues(alpha: 0.12),
                borderRadius:
                    BorderRadius.circular(8.r),
                image: const DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(
                    AppAssets.media2,
                  ),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40.sp,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
