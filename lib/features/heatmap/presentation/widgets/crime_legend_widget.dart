import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

class CrimeLegendWidget extends StatelessWidget {
  const CrimeLegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'النشاط الأخير للنقاط الساخنة',
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor),
            ),

            SizedBox(height: 16.h),

            // عنصر المنطقة الخطيرة (أحمر)
            _buildLegendItem(
              color: Colors.red,
              title: 'وسط القاهرة',
              subtitle:
                  'تم الكشف عن نشاط سرقة مرتفع',
              time: 'آخر تحديث: منذ ساعتين',
            ),
            SizedBox(height: 12.h),
            // عنصر المنطقة متوسطة الخطورة (برتقالي)
            _buildLegendItem(
              color: Colors.orange,
              title: 'حي الجيزة',
              subtitle: 'حوادث سرقة معتدلة',
              time: 'آخر تحديث: منذ 4 ساعات',
            ),
            SizedBox(height: 12.h),
            // عنصر المنطقة الآمنة (أخضر)
            _buildLegendItem(
              color: Colors.green,
              title: 'ميناء الإسكندرية',
              subtitle:
                  'حالات الاعتداء المُبلّغ عنها',
              time: 'آخر تحديث: منذ 6 ساعات',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      width: double.infinity,
      height: 80.h,
      decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(8.r),
          color: Colors.white,
          border: Border.all(
            color: Colors.grey[300]!,
          )),
      padding: EdgeInsets.symmetric(
          horizontal: 12.w, vertical: 8.h),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          // النصوص
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          // الدائرة الملونة
          Container(
            width: 12.w,
            height: 12.h,
            margin: EdgeInsets.only(top: 4.h),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
