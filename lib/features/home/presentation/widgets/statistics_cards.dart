import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/constants/app_assets.dart';

class StatisticsCards extends StatelessWidget {
  const StatisticsCards({super.key});

  // بيانات الـ cards
  final List<Map<String, dynamic>> _cardsData = const [
    {
      'icon': AppIcons.alarm,
      'iconBackgroundColor': Color(0xFFFEE2E2),
      'iconColor': Color(0xFFDC2626),
      'title': 'إجمالي الجرائم',
      'number': '1,247',
      'percentage': '8.2%',
      'percentageText': 'مقابل الشهر الماضي',
      'percentageColor': Color(0xFF38A169),
    },
    {
      'icon': AppIcons.ratio,
      'iconBackgroundColor': Color(0xFFFFEDD5),
      'iconColor': Color(0xFFEA580C),
      'title': 'الاكثر انتشارا',
      'number': 'السرقة',
      'percentage': '34.2%',
      'percentageText': 'من جميع الجرائم',
      'percentageColor': Color(0xFF6B7280),
    },
    {
      'icon': AppIcons.circle,
      'iconBackgroundColor': Color(0xFFDBEAFE),
      'iconColor': Color(0xFF2563EB),
      'title': 'الاسبوع القادم',
      'number': '298',
      'percentage': '3.1%',
      'percentageText': 'متوقع',
      'percentageColor': Color(0xFFE53E3E),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _cardsData.length,
        itemBuilder: (context, index) {
          final cardData = _cardsData[index];
          return Container(
            width: 170.w,
            margin: EdgeInsets.only(
              left: index == _cardsData.length - 1 ? 0 : 12.w,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
            ),
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  // النصوص والأرقام
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            // الأيقون مع خلفيته
                            Container(
                              width: 32.w,
                              height: 32.h,
                              decoration: BoxDecoration(
                                color: cardData['iconBackgroundColor'],
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: SvgPicture.asset(
                                  cardData['icon'],
                                  height: 12.h,
                                  width: 12.w,
                                  color: cardData['iconColor'],
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            // النص
                            Text(
                              cardData['title'],
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ],
                        ),
                        SizedBox(height: 5.h),
                        // الرقم
                        Text(
                          cardData['number'],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        // النسبة والنص
                        Row(
                          children: [
                            Text(
                              cardData['percentage'],
                              style: TextStyle(
                                color: cardData['percentageColor'],
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                cardData['percentageText'],
                                style: TextStyle(
                                  color: cardData['percentageColor'],
                                  fontSize: 12.sp,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
