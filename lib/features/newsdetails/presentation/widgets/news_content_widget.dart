import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:netru_app/features/newsdetails/data/models/news_model.dart';

class NewsContentWidget extends StatelessWidget {
  final NewsModel news;

  const NewsContentWidget({
    super.key,
    required this.news,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // العنوان الرئيسي
          Text(
            news.title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
              height: 1.3,
            ),
          ),

          SizedBox(height: 10.h),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 5.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius:
                      BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12.sp,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      news.date,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.blue,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // التصنيف
              if (news.category.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green
                        .withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(
                          12.r,
                        ),
                  ),
                  child: Text(
                    news.category,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 15.h),

          Text(
            news.content,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.grey.withValues(
                alpha: 0.9,
              ),
              height: 1.6,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
