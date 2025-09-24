import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../heatmap/presentation/cubit/heatmap_cubit.dart';
import '../../../heatmap/presentation/cubit/heatmap_state.dart';

class RealTimeStatisticsCards extends StatelessWidget {
  const RealTimeStatisticsCards({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HeatmapCubit, HeatmapState>(
      builder: (context, state) {
        if (state is HeatmapLoading) {
          return _buildLoadingCards();
        } else if (state is HeatmapLoaded) {
          return _buildStatisticsCards(state.statistics);
        } else if (state is HeatmapStatisticsLoaded) {
          return _buildStatisticsCards(state.statistics);
        } else if (state is HeatmapFailure) {
          return _buildErrorCards(state.error);
        }

        // تحميل البيانات إذا لم تكن متاحة
        context.read<HeatmapCubit>().loadStatistics();
        return _buildLoadingCards();
      },
    );
  }

  Widget _buildStatisticsCards(dynamic statistics) {
    final cardsData = [
      {
        'icon': AppIcons.alarm,
        'iconBackgroundColor': const Color(0xFFFEE2E2),
        'iconColor': const Color(0xFFDC2626),
        'title': 'إجمالي البلاغات',
        'number': statistics.totalReports.toString(),
        'percentage': _calculateTotalPercentage(statistics),
        'percentageText': 'من جميع البلاغات',
        'percentageColor': const Color(0xFF38A169),
      },
      {
        'icon': AppIcons.ratio,
        'iconBackgroundColor': const Color(0xFFFFEDD5),
        'iconColor': const Color(0xFFEA580C),
        'title': 'الأكثر انتشاراً',
        'number': statistics.mostCommonType,
        'percentage':
            '${statistics.mostCommonTypePercentage.toStringAsFixed(1)}%',
        'percentageText': 'من جميع الجرائم',
        'percentageColor': const Color(0xFF6B7280),
      },
      {
        'icon': AppIcons.circle,
        'iconBackgroundColor': const Color(0xFFDBEAFE),
        'iconColor': const Color(0xFF2563EB),
        'title': 'قيد المراجعة',
        'number': statistics.pendingReports.toString(),
        'percentage': _calculatePendingPercentage(statistics),
        'percentageText': 'في الانتظار',
        'percentageColor': const Color(0xFFE53E3E),
      },
    ];

    return SizedBox(
      height: 120.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cardsData.length,
        itemBuilder: (context, index) {
          final cardData = cardsData[index];
          return Container(
            width: 170.w,
            margin: EdgeInsets.only(
              left: index == cardsData.length - 1 ? 0 : 12.w,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(12.w),
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
                          color: cardData['iconBackgroundColor'] as Color,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            cardData['icon'] as String,
                            width: 18.w,
                            height: 18.h,
                            colorFilter: ColorFilter.mode(
                              cardData['iconColor'] as Color,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // النص
                      Expanded(
                        child: Text(
                          cardData['title'] as String,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // الرقم
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        cardData['number'].toString(),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // النسبة والنص
                  Row(
                    children: [
                      Text(
                        cardData['percentage'] as String,
                        style: TextStyle(
                          color: cardData['percentageColor'] as Color,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          cardData['percentageText'] as String,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingCards() {
    return SizedBox(
      height: 120.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 170.w,
            margin: EdgeInsets.only(left: index == 2 ? 0 : 12.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32.w,
                        height: 32.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Container(
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    height: 16.h,
                    width: 60.w,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    height: 10.h,
                    width: 100.w,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6.r),
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

  Widget _buildErrorCards(String error) {
    return Container(
      height: 120.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 32.w),
            SizedBox(height: 8.h),
            Text(
              'خطأ في تحميل الإحصائيات',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.red[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'اضغط للإعادة المحاولة',
              style: TextStyle(fontSize: 12.sp, color: Colors.red[600]),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateTotalPercentage(dynamic statistics) {
    if (statistics.totalReports == 0) return '0%';

    final resolved = statistics.resolvedReports;
    final percentage = (resolved / statistics.totalReports) * 100;
    return '${percentage.toStringAsFixed(1)}%';
  }

  String _calculatePendingPercentage(dynamic statistics) {
    if (statistics.totalReports == 0) return '0%';

    final pending = statistics.pendingReports;
    final percentage = (pending / statistics.totalReports) * 100;
    return '${percentage.toStringAsFixed(1)}%';
  }
}
