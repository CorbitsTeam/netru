import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/dashboard_stats_entity.dart';

class DashboardStatsCards extends StatelessWidget {
  final DashboardStatsEntity stats;

  const DashboardStatsCards({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        children: [
          _buildStatsCard(
            context,
            title: 'إجمالي البلاغات',
            value: stats.totalReports.toString(),
            icon: Icons.report,
            color: Colors.blue,
            subtitle: 'جميع البلاغات المسجلة',
          ),
          _buildStatsCard(
            context,
            title: 'البلاغات المعلقة',
            value: stats.pendingReports.toString(),
            icon: Icons.pending,
            color: Colors.orange,
            subtitle: 'في انتظار المراجعة',
          ),
          _buildStatsCard(
            context,
            title: 'قيد التحقيق',
            value: stats.underInvestigationReports.toString(),
            icon: Icons.search,
            color: Colors.purple,
            subtitle: 'قيد التحقيق حالياً',
          ),
          _buildStatsCard(
            context,
            title: 'البلاغات المحلولة',
            value: stats.resolvedReports.toString(),
            icon: Icons.check_circle,
            color: Colors.green,
            subtitle: 'تم حلها بنجاح',
          ),
          _buildStatsCard(
            context,
            title: 'البلاغات المرفوضة',
            value: stats.rejectedReports.toString(),
            icon: Icons.cancel,
            color: Colors.red,
            subtitle: 'تم رفضها',
          ),
          _buildStatsCard(
            context,
            title: 'إجمالي المستخدمين',
            value: stats.totalUsers.toString(),
            icon: Icons.people,
            color: Colors.indigo,
            subtitle: 'جميع المستخدمين',
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 28.sp, color: color),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class QuickStatsRow extends StatelessWidget {
  final DashboardStatsEntity stats;

  const QuickStatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickStat(
            context,
            'البلاغات اليوم',
            '${stats.totalReports}', // You might want to add daily stats to the entity
            Icons.today,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildQuickStat(
            context,
            'المستخدمين النشطين',
            '${stats.totalUsers}',
            Icons.people_alt,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildQuickStat(
            context,
            'معدل الحل',
            '${((stats.resolvedReports / stats.totalReports) * 100).toStringAsFixed(1)}%',
            Icons.trending_up,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildQuickStat(
            context,
            'متوسط وقت الاستجابة',
            '2.3 ساعة', // You might want to add this to the entity
            Icons.timer,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStat(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
