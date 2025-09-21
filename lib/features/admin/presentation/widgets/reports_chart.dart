import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import '../../domain/entities/dashboard_stats_entity.dart';

class ReportsChart extends StatelessWidget {
  final DashboardStatsEntity stats;

  const ReportsChart({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight =
                constraints.hasBoundedHeight
                    ? constraints.maxHeight
                    : MediaQuery.of(context).size.height;
            final needsScroll = availableHeight < 400.h;

            final content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'إحصائيات البلاغات',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, size: 20.sp),
                      onSelected: (value) {
                        // Handle chart options
                      },
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'export',
                              child: Text('تصدير البيانات'),
                            ),
                            const PopupMenuItem(
                              value: 'refresh',
                              child: Text('تحديث'),
                            ),
                          ],
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Pie Chart for Report Status (responsive, constrained)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmallScreen = constraints.maxWidth < 600;
                    final availableHeight =
                        constraints.hasBoundedHeight
                            ? constraints.maxHeight
                            : MediaQuery.of(context).size.height;
                    final targetHeight = isSmallScreen ? 250.h : 300.h;
                    final chartHeight = math.min(
                      targetHeight,
                      availableHeight * 0.6,
                    );

                    if (isSmallScreen) {
                      // vertical arrangement: chart above, legend below (scrollable)
                      return SizedBox(
                        height: chartHeight,
                        child: Column(
                          children: [
                            SizedBox(
                              height: (chartHeight * 0.7).clamp(
                                80.h,
                                chartHeight,
                              ),
                              child: PieChart(
                                PieChartData(
                                  sections: _buildPieChartSections(),
                                  centerSpaceRadius: 40.r,
                                  sectionsSpace: 2,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            SizedBox(
                              height: (chartHeight * 0.25).clamp(
                                30.h,
                                chartHeight * 0.4,
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _buildLegendItems(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // horizontal arrangement on larger screens
                    final leftWidth = math.max(
                      constraints.maxWidth * 0.55,
                      180.w,
                    );
                    return SizedBox(
                      height: chartHeight,
                      child: Row(
                        children: [
                          SizedBox(
                            width: leftWidth,
                            child: PieChart(
                              PieChartData(
                                sections: _buildPieChartSections(),
                                centerSpaceRadius: 60.r,
                                sectionsSpace: 2,
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _buildLegendItems(context),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(height: 24.h),

                // Line Chart for Trends
                if (stats.reportTrends.isNotEmpty) ...[
                  Text(
                    'اتجاه البلاغات (آخر 30 يوم)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    height: 180.h,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: _buildLineChartSpots(),
                            isCurved: true,
                            color: Theme.of(context).primaryColor,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                            ),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 &&
                                    index < stats.reportTrends.length) {
                                  final date = stats.reportTrends[index].date;
                                  return Text(
                                    '${date.day}/${date.month}',
                                    style: TextStyle(fontSize: 8.sp),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 5,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey[300]!,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ],
              ],
            );

            if (needsScroll) {
              return SizedBox(
                height: availableHeight,
                child: SingleChildScrollView(child: content),
              );
            }

            return content;
          },
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
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: stats.underInvestigationReports.toDouble(),
        color: Colors.purple,
        title:
            '${((stats.underInvestigationReports / total) * 100).toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: stats.resolvedReports.toDouble(),
        color: Colors.green,
        title: '${((stats.resolvedReports / total) * 100).toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: stats.rejectedReports.toDouble(),
        color: Colors.red,
        title: '${((stats.rejectedReports / total) * 100).toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  List<Widget> _buildLegendItems(BuildContext context) {
    return [
      _buildLegendItem(context, 'معلقة', stats.pendingReports, Colors.orange),
      _buildLegendItem(
        context,
        'قيد التحقيق',
        stats.underInvestigationReports,
        Colors.purple,
      ),
      _buildLegendItem(context, 'محلولة', stats.resolvedReports, Colors.green),
      _buildLegendItem(context, 'مرفوضة', stats.rejectedReports, Colors.red),
    ];
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    int value,
    Color color,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.w,
            height: 12.h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value.toString(),
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _buildLineChartSpots() {
    return stats.reportTrends.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.count.toDouble());
    }).toList();
  }
}

class ReportsBarChart extends StatelessWidget {
  final Map<String, int> reportsByGovernorate;

  const ReportsBarChart({Key? key, required this.reportsByGovernorate})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (reportsByGovernorate.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('لا توجد بيانات متاحة')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'البلاغات حسب المحافظة',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: math.min(
                300.h,
                MediaQuery.of(context).size.height * 0.35,
              ),
              child: BarChart(
                BarChartData(
                  barGroups: _buildBarGroups(),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final keys = reportsByGovernorate.keys.toList();
                          final index = value.toInt();
                          if (index >= 0 && index < keys.length) {
                            return Text(
                              keys[index],
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    final entries = reportsByGovernorate.entries.toList();
    return entries.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.value.toDouble(),
            color: Colors.blue,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }
}
