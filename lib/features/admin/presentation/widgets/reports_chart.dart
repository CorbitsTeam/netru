import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/dashboard_stats_entity.dart';

class ReportsChart extends StatelessWidget {
  final DashboardStatsEntity stats;

  const ReportsChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder:
          (context, constraints) => Card(
            elevation: 2,
            margin: EdgeInsets.all(8.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'توزيع البلاغات',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    height: 180.h,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: PieChart(
                              PieChartData(
                                sections: _buildPieChartSections(),
                                centerSpaceRadius: 35.r,
                                sectionsSpace: 2,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          flex: 2,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _buildLegendItems(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final total = stats.totalReports.toDouble();
    if (total == 0) return [];

    return [
      PieChartSectionData(
        value: stats.receivedReports.toDouble(),
        color: Colors.blue,
        title: '${((stats.receivedReports / total) * 100).toStringAsFixed(1)}%',
        radius: 50.r,
        titleStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: stats.underReviewReports.toDouble(),
        color: Colors.orange,
        title:
            '${((stats.underReviewReports / total) * 100).toStringAsFixed(1)}%',
        radius: 50.r,
        titleStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: stats.dataVerificationReports.toDouble(),
        color: Colors.purple,
        title:
            '${((stats.dataVerificationReports / total) * 100).toStringAsFixed(1)}%',
        radius: 50.r,
        titleStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: stats.actionTakenReports.toDouble(),
        color: Colors.teal,
        title:
            '${((stats.actionTakenReports / total) * 100).toStringAsFixed(1)}%',
        radius: 50.r,
        titleStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: stats.completedReports.toDouble(),
        color: Colors.green,
        title:
            '${((stats.completedReports / total) * 100).toStringAsFixed(1)}%',
        radius: 50.r,
        titleStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: stats.rejectedReports.toDouble(),
        color: Colors.red,
        title: '${((stats.rejectedReports / total) * 100).toStringAsFixed(1)}%',
        radius: 50.r,
        titleStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  List<Widget> _buildLegendItems(BuildContext context) {
    return [
      _buildLegendItem('مستلمة', Colors.blue, stats.receivedReports),
      SizedBox(height: 8.h),
      _buildLegendItem('قيد المراجعة', Colors.orange, stats.underReviewReports),
      SizedBox(height: 8.h),
      _buildLegendItem(
        'تحقق من البيانات',
        Colors.purple,
        stats.dataVerificationReports,
      ),
      SizedBox(height: 8.h),
      _buildLegendItem('تم اتخاذ إجراء', Colors.teal, stats.actionTakenReports),
      SizedBox(height: 8.h),
      _buildLegendItem('مكتملة', Colors.green, stats.completedReports),
      SizedBox(height: 8.h),
      _buildLegendItem('مرفوضة', Colors.red, stats.rejectedReports),
    ];
  }

  Widget _buildLegendItem(String title, Color color, int value) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.h,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500),
              ),
              Text(
                '$value',
                style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<FlSpot> _buildLineChartSpots() {
    return stats.reportTrends
        .asMap()
        .entries
        .map(
          (entry) => FlSpot(entry.key.toDouble(), entry.value.count.toDouble()),
        )
        .toList();
  }
}
