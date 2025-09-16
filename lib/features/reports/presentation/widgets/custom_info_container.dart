import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

class CustomInfoContainer extends StatelessWidget {
  final String value;
  final String label;
  final double? height;
  final Color? textColor;
  const CustomInfoContainer({
    super.key,
    required this.label,
    required this.value,
    this.textColor,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11.sp)),
        SizedBox(height: 5.h),
        Container(
          height: height ?? 40.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.grey.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(5.r),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                color: textColor ?? AppColors.grey.withValues(alpha: 0.9),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
