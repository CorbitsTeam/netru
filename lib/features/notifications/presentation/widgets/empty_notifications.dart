import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyNotifications extends StatelessWidget {
  const EmptyNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Notification Icon
          Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 60.sp,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 24.h),

          // Title
          Text(
            'لا توجد إشعارات',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),

          // Subtitle
          Text(
            'لم تتلق أي إشعارات بعد\nسيتم إشعارك عند وصول رسائل جديدة',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),

          // Illustration or additional content
          Container(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Column(
              children: [
                _buildFeatureItem(
                  icon: Icons.article_outlined,
                  title: 'أخبار جديدة',
                  subtitle: 'احصل على إشعارات عند نشر أخبار جديدة',
                ),
                SizedBox(height: 16.h),
                _buildFeatureItem(
                  icon: Icons.report_outlined,
                  title: 'تحديثات البلاغات',
                  subtitle: 'تابع حالة بلاغاتك والردود عليها',
                ),
                SizedBox(height: 16.h),
                _buildFeatureItem(
                  icon: Icons.security_outlined,
                  title: 'تنبيهات النظام',
                  subtitle: 'استقبل تحديثات مهمة حول الأمان',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: Colors.blue.shade400, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[500],
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
