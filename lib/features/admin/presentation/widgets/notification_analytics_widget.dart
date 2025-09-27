import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';

import '../cubit/admin_notifications_cubit.dart';

class NotificationAnalyticsWidget extends StatefulWidget {
  const NotificationAnalyticsWidget({super.key});

  @override
  State<NotificationAnalyticsWidget> createState() =>
      _NotificationAnalyticsWidgetState();
}

class _NotificationAnalyticsWidgetState
    extends State<NotificationAnalyticsWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load analytics data
    context.read<AdminNotificationsCubit>().loadStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.analytics, color: Color(0xFF2E7D32), size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'إحصائيات الإشعارات',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<AdminNotificationsCubit>().loadStatistics();
                },
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF2E7D32),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF2E7D32),
            labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'نظرة عامة'),
              Tab(text: 'الأداء اليومي'),
              Tab(text: 'التوزيع الجغرافي'),
              Tab(text: 'أفضل الأوقات'),
            ],
          ),

          SizedBox(height: 16.h),

          // Tab content
          Expanded(
            child:
                BlocBuilder<AdminNotificationsCubit, AdminNotificationsState>(
                  builder: (context, state) {
                    if (state is AdminNotificationsStatsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is AdminNotificationsStatsLoaded) {
                      return TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOverviewTab(state.stats),
                          _buildDailyPerformanceTab(state.stats),
                          _buildGeographicTab(state.stats),
                          _buildOptimalTimesTab(state.stats),
                        ],
                      );
                    }

                    return const Center(
                      child: Text('لا توجد بيانات إحصائية متاحة'),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(NotificationStats stats) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Key metrics cards
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'إجمالي الإشعارات',
                  '${stats.totalNotifications}',
                  Icons.notifications_outlined,
                  const Color(0xFF1976D2),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildMetricCard(
                  'معدل التسليم',
                  '${stats.deliveryRate.toStringAsFixed(1)}%',
                  Icons.delivery_dining,
                  const Color(0xFF388E3C),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'معدل الفتح',
                  '${stats.openRate.toStringAsFixed(1)}%',
                  Icons.open_in_browser,
                  const Color(0xFFFF9800),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildMetricCard(
                  'معدل النقر',
                  '${stats.clickRate.toStringAsFixed(1)}%',
                  Icons.touch_app,
                  const Color(0xFF9C27B0),
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Type breakdown chart
          _buildTypeBreakdownChart(stats.notificationsByType),

          SizedBox(height: 24.h),

          // Priority breakdown chart
          _buildPriorityBreakdownChart(stats.notificationsByPriority),
        ],
      ),
    );
  }

  Widget _buildDailyPerformanceTab(NotificationStats stats) {
    return Column(
      children: [
        // Performance trend
        Expanded(child: _buildDailyTrendChart(stats.dailyStats)),

        SizedBox(height: 16.h),

        // Daily summary
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ملخص الأداء اليومي',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              if (stats.dailyStats.isNotEmpty) ...[
                _buildDailySummaryRow(
                  'أفضل يوم للإرسال',
                  _getBestDay(stats.dailyStats),
                  Icons.trending_up,
                  Colors.green,
                ),
                _buildDailySummaryRow(
                  'متوسط الإرسال اليومي',
                  '${_getAverageDaily(stats.dailyStats)} إشعار',
                  Icons.analytics,
                  Colors.blue,
                ),
                _buildDailySummaryRow(
                  'أعلى معدل فتح',
                  '${_getBestOpenRate(stats.dailyStats)}%',
                  Icons.open_in_browser,
                  Colors.orange,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGeographicTab(NotificationStats stats) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Geographic distribution chart
          SizedBox(
            height: 300.h,
            child: _buildGeographicChart(stats.deliveryRateByGovernorate),
          ),

          SizedBox(height: 24.h),

          // Top performing governorates
          _buildTopGovernoratesTable(stats.deliveryRateByGovernorate),
        ],
      ),
    );
  }

  Widget _buildOptimalTimesTab(NotificationStats stats) {
    return Column(
      children: [
        // Hourly performance chart
        Expanded(child: _buildHourlyChart(stats.hourlyStats)),

        SizedBox(height: 16.h),

        // Recommendations
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.blue[600]),
                  SizedBox(width: 8.w),
                  Text(
                    'توصيات لأفضل أوقات الإرسال',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              ..._getTimeRecommendations(stats.hourlyStats).map(
                (recommendation) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16.sp,
                        color: Colors.blue[600],
                      ),
                      SizedBox(width: 8.w),
                      Expanded(child: Text(recommendation)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBreakdownChart(Map<String, int> data) {
    if (data.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'توزيع الإشعارات حسب النوع',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 200.h,
            child: PieChart(
              PieChartData(
                sections: _createPieSections(data, _getTypeColors()),
                borderData: FlBorderData(show: false),
                centerSpaceRadius: 60,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBreakdownChart(Map<String, int> data) {
    if (data.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'توزيع الإشعارات حسب الأولوية',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 200.h,
            child: BarChart(
              BarChartData(
                barGroups: _createBarGroups(data, _getPriorityColors()),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final keys = data.keys.toList();
                        if (value.toInt() < keys.length) {
                          return Text(
                            keys[value.toInt()],
                            style: TextStyle(fontSize: 10.sp),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTrendChart(List<DailyNotificationStat> dailyStats) {
    if (dailyStats.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اتجاه الأداء اليومي',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots:
                        dailyStats.asMap().entries.map((entry) {
                          return FlSpot(
                            entry.key.toDouble(),
                            entry.value.sent.toDouble(),
                          );
                        }).toList(),
                    isCurved: true,
                    color: const Color(0xFF2E7D32),
                    barWidth: 3,
                  ),
                ],
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeographicChart(Map<String, double> data) {
    if (data.isEmpty) return const SizedBox.shrink();

    return BarChart(
      BarChartData(
        barGroups:
            data.entries.map((entry) {
              final index = data.keys.toList().indexOf(entry.key);
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: entry.value,
                    color: const Color(0xFF2E7D32),
                    width: 20,
                  ),
                ],
              );
            }).toList(),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final keys = data.keys.toList();
                if (value.toInt() < keys.length) {
                  return Text(
                    keys[value.toInt()],
                    style: TextStyle(fontSize: 8.sp),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHourlyChart(List<HourlyNotificationStat> hourlyStats) {
    if (hourlyStats.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الأداء حسب الساعة',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: BarChart(
              BarChartData(
                barGroups:
                    hourlyStats.map((stat) {
                      return BarChartGroupData(
                        x: stat.hour,
                        barRods: [
                          BarChartRodData(
                            toY: stat.deliveryRate,
                            color: _getHourColor(stat.deliveryRate),
                            width: 16,
                          ),
                        ],
                      );
                    }).toList(),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: true),
                maxY: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopGovernoratesTable(Map<String, double> data) {
    final sortedEntries =
        data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أفضل المحافظات في معدل التسليم',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          ...sortedEntries.take(5).map((entry) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text(entry.key)),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: entry.value / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getPerformanceColor(entry.value),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text('${entry.value.toStringAsFixed(1)}%'),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDailySummaryRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _createPieSections(
    Map<String, int> data,
    Map<String, Color> colors,
  ) {
    final total = data.values.fold<int>(0, (sum, value) => sum + value);

    return data.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        color: colors[entry.key] ?? Colors.grey,
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _createBarGroups(
    Map<String, int> data,
    Map<String, Color> colors,
  ) {
    return data.entries.map((entry) {
      final index = data.keys.toList().indexOf(entry.key);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: colors[entry.key] ?? Colors.grey,
            width: 20,
          ),
        ],
      );
    }).toList();
  }

  Map<String, Color> _getTypeColors() {
    return {
      'general': const Color(0xFF388E3C),
      'news': const Color(0xFF1976D2),
      'report_update': const Color(0xFFFF9800),
      'report_comment': const Color(0xFF9C27B0),
      'system': const Color(0xFFD32F2F),
    };
  }

  Map<String, Color> _getPriorityColors() {
    return {
      'low': Colors.green,
      'normal': Colors.blue,
      'high': Colors.orange,
      'urgent': Colors.red,
    };
  }

  Color _getHourColor(double deliveryRate) {
    if (deliveryRate >= 80) return Colors.green;
    if (deliveryRate >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getPerformanceColor(double rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getBestDay(List<DailyNotificationStat> stats) {
    if (stats.isEmpty) return 'غير محدد';

    final bestDay = stats.reduce(
      (a, b) =>
          (a.delivered / (a.sent + 1)) > (b.delivered / (b.sent + 1)) ? a : b,
    );

    return '${bestDay.date.day}/${bestDay.date.month}';
  }

  int _getAverageDaily(List<DailyNotificationStat> stats) {
    if (stats.isEmpty) return 0;
    return (stats.map((s) => s.sent).reduce((a, b) => a + b) / stats.length)
        .round();
  }

  double _getBestOpenRate(List<DailyNotificationStat> stats) {
    if (stats.isEmpty) return 0;

    final bestDay = stats.reduce(
      (a, b) =>
          (a.opened / (a.delivered + 1)) > (b.opened / (b.delivered + 1))
              ? a
              : b,
    );

    return (bestDay.opened / (bestDay.delivered + 1)) * 100;
  }

  List<String> _getTimeRecommendations(List<HourlyNotificationStat> stats) {
    if (stats.isEmpty) {
      return ['لا توجد بيانات كافية لتقديم توصيات'];
    }

    final recommendations = <String>[];

    // Find peak hours
    final sortedStats = List<HourlyNotificationStat>.from(stats)
      ..sort((a, b) => b.deliveryRate.compareTo(a.deliveryRate));

    if (sortedStats.isNotEmpty) {
      final bestHour = sortedStats.first;
      recommendations.add(
        'أفضل وقت للإرسال: ${bestHour.hour}:00 (معدل تسليم ${bestHour.deliveryRate.toStringAsFixed(1)}%)',
      );
    }

    // Morning vs evening analysis
    final morningStats = stats.where((s) => s.hour >= 6 && s.hour <= 12);
    final eveningStats = stats.where((s) => s.hour >= 18 && s.hour <= 22);

    if (morningStats.isNotEmpty && eveningStats.isNotEmpty) {
      final morningAvg =
          morningStats.map((s) => s.deliveryRate).reduce((a, b) => a + b) /
          morningStats.length;
      final eveningAvg =
          eveningStats.map((s) => s.deliveryRate).reduce((a, b) => a + b) /
          eveningStats.length;

      if (morningAvg > eveningAvg) {
        recommendations.add('الفترة الصباحية (6-12) أفضل من المسائية');
      } else {
        recommendations.add('الفترة المسائية (18-22) أفضل من الصباحية');
      }
    }

    return recommendations;
  }
}
