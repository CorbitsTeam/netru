import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

class ProceduresSection extends StatelessWidget {
  const ProceduresSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'procedures'.tr(),
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          width: 135.w,
          height: 25.h,
          decoration: BoxDecoration(
            color: AppColors.orange,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Text(
              "تم التحويل للجهات المعنية",
              style: TextStyle(fontSize: 10.sp, color: Colors.white),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Icon(Icons.info_rounded, size: 18.sp),
            SizedBox(width: 5.w),
            Expanded(
              child: Text(
                "يتم التحقيق من قبل لجهات المعنية في محتوى البلاغ وسيتم إتخاذ إجراء فوري عند التحقق من صحة البلاغ .",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.primaryColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
