import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/dashboard_stats_entity.dart';

class DashboardStatsCards extends StatelessWidget {
  final DashboardStatsEntity stats;

  const DashboardStatsCards({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16.w,
      runSpacing: 16.h,
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
        _buildStatsCard(
          context,
          title: 'المصريين',
          value: stats.citizenUsers.toString(),
          icon: Icons.person,
          color: Colors.teal,
          subtitle: 'مستخدمين مصريين',
        ),
        _buildStatsCard(
          context,
          title: 'الأجانب',
          value: stats.foreignerUsers.toString(),
          icon: Icons.person_outline,
          color: Colors.cyan,
          subtitle: 'مستخدمين أجانب',
        ),
        _buildStatsCard(
          context,
          title: 'طلبات التحقق',
          value: stats.pendingVerifications.toString(),
          icon: Icons.verified_user,
          color: Colors.amber,
          subtitle: 'في انتظار التحقق',
        ),
        _buildStatsCard(
          context,
          title: 'الأخبار المنشورة',
          value: stats.publishedNewsArticles.toString(),
          icon: Icons.article,
          color: Colors.deepPurple,
          subtitle: 'مقالات منشورة',
        ),
      ],
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
    return SizedBox(
      width: 280.w,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          value,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                            fontSize: 24.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          subtitle,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(icon, size: 32.sp, color: color),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuickStatsRow extends StatelessWidget {
  final DashboardStatsEntity stats;

  const QuickStatsRow({Key? key, required this.stats}) : super(key: key);

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
              color: color.withOpacity(0.1),
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
