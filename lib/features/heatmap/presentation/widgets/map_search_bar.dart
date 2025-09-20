import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

class MapSearchBar extends StatelessWidget {
  const MapSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          // زر البحث
          const Padding(
            padding: EdgeInsets.all(5.0),
            child: Icon(Icons.search, color: Colors.grey, size: 20),
          ),

          // حقل البحث
          Expanded(
            child: TextField(
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'ابحث عن منطقة أو عنوان...',
                hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),

          // زر الفلتر
          Container(
            width: 38.w,
            height: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: const Icon(Icons.tune, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}
