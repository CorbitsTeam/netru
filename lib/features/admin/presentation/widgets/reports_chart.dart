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
                  if (stats.reportTrends.isNotEmpty) ...[
                    SizedBox(height: 20.h),
                    Text(
                      'اتجاه البلاغات',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      height: 120.h,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (
                                  double value,
                                  TitleMeta meta,
                                ) {
                                  if (value.toInt() >= 0 &&
                                      value.toInt() <
                                          stats.reportTrends.length) {
                                    return Text(
                                      '${stats.reportTrends[value.toInt()].date.day}/${stats.reportTrends[value.toInt()].date.month}',
                                      style: TextStyle(fontSize: 9.sp),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _buildLineChartSpots(),
                              isCurved: true,
                              color: Theme.of(context).primaryColor,
                              barWidth: 2,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
        value: stats.pendingReports.toDouble(),
        color: Colors.orange,
        title: '${((stats.pendingReports / total) * 100).toStringAsFixed(1)}%',
        radius: 50.r,
        titleStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: stats.underInvestigationReports.toDouble(),
        color: Colors.purple,
        title:
            '${((stats.underInvestigationReports / total) * 100).toStringAsFixed(1)}%',
        radius: 50.r,
        titleStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: stats.resolvedReports.toDouble(),
        color: Colors.green,
        title: '${((stats.resolvedReports / total) * 100).toStringAsFixed(1)}%',
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
      _buildLegendItem('في الانتظار', Colors.orange, stats.pendingReports),
      SizedBox(height: 8.h),
      _buildLegendItem(
        'قيد التحقيق',
        Colors.purple,
        stats.underInvestigationReports,
      ),
      SizedBox(height: 8.h),
      _buildLegendItem('محلولة', Colors.green, stats.resolvedReports),
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
