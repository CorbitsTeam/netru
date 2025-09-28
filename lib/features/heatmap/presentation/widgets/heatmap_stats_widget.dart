import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/heatmap_cubit.dart';
import '../cubit/heatmap_state.dart';
import '../../../../core/theme/app_colors.dart';

class HeatmapStatsWidget extends StatelessWidget {
  const HeatmapStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      HeatmapCubit,
      HeatmapState
    >(
      builder: (context, state) {
        if (state is HeatmapLoaded) {
          return _buildStatsContent(state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatsContent(HeatmapLoaded state) {
    final totalReports = state.reports.length;
    final topGovernorates = _getTopGovernorates(
      state.reports,
      3,
    );
    final crimeStats = _analyzeCrimeTypes(
      state.reports,
    );

    return Container(
      margin: EdgeInsets.all(12.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // العنوان الرئيسي
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: AppColors.primaryColor,
                size: 22.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'إحصائيات الأمان الحية',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // الإحصائيات الرئيسية
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'إجمالي البلاغات',
                  value: totalReports.toString(),
                  icon: Icons.report,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  title: 'المحافظات المتأثرة',
                  value:
                      topGovernorates.length
                          .toString(),
                  icon: Icons.location_city,
                  color: Colors.orange,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  title: 'أنواع الجرائم',
                  value:
                      crimeStats.length
                          .toString(),
                  icon: Icons.category,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // أخطر المحافظات
          Text(
            'المناطق الأكثر تأثراً',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          SizedBox(height: 8.h),

          Column(
            children:
                topGovernorates.map((
                  governorate,
                ) {
                  final reports =
                      state.reports
                          .where(
                            (r) =>
                                r.governorate ==
                                governorate.key,
                          )
                          .length;
                  final percentage =
                      (reports /
                              totalReports *
                              100)
                          .round();

                  return Container(
                    margin: EdgeInsets.only(
                      bottom: 6.h,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.h,
                          decoration: BoxDecoration(
                            color:
                                _getDangerLevelColor(
                                  reports,
                                ),
                            shape:
                                BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            governorate.key,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color:
                                  Colors
                                      .grey[700],
                            ),
                          ),
                        ),
                        Text(
                          '$reports ($percentage%)',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight:
                                FontWeight.w600,
                            color:
                                _getDangerLevelColor(
                                  reports,
                                ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      height: 90.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<MapEntry<String, int>> _getTopGovernorates(
    List<dynamic> reports,
    int limit,
  ) {
    final Map<String, int> governorateCount = {};

    for (final report in reports) {
      final governorate =
          report.governorate ?? 'غير محدد';
      if (governorate != 'غير محدد') {
        governorateCount[governorate] =
            (governorateCount[governorate] ?? 0) +
            1;
      }
    }

    final sortedEntries =
        governorateCount.entries.toList()..sort(
          (a, b) => b.value.compareTo(a.value),
        );

    return sortedEntries.take(limit).toList();
  }

  Map<String, int> _analyzeCrimeTypes(
    List<dynamic> reports,
  ) {
    final Map<String, int> crimeTypes = {};

    for (final report in reports) {
      final type =
          report.reportType ?? 'غير محدد';
      if (type != 'غير محدد') {
        crimeTypes[type] =
            (crimeTypes[type] ?? 0) + 1;
      }
    }

    return crimeTypes;
  }

  Color _getDangerLevelColor(int reportCount) {
    if (reportCount >= 20) return Colors.red;
    if (reportCount >= 10) return Colors.orange;
    if (reportCount >= 5) {
      return Colors.yellow[700] ?? Colors.yellow;
    }
    return Colors.green;
  }
}
