import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/heatmap_cubit.dart';
import '../cubit/heatmap_state.dart';
import '../../../../core/theme/app_colors.dart';

class CrimeLegendWidget extends StatelessWidget {
  const CrimeLegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HeatmapCubit, HeatmapState>(
      builder: (context, state) {
        if (state is HeatmapLoaded) {
          return _buildLegendContent(state, context);
        }
        return _buildDefaultLegend(context);
      },
    );
  }

  Widget _buildLegendContent(HeatmapLoaded state, BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مفتاح الخريطة الحرارية',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),

            SizedBox(height: 16.h),

            // مستويات الخطر
            _buildDangerLevelsSection(),

            SizedBox(height: 20.h),

            // أنواع الجرائم
            _buildCrimeTypesSection(state),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultLegend(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مفتاح الخريطة الحرارية',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),

            SizedBox(height: 16.h),

            _buildDangerLevelsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerLevelsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مستويات الخطر',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),

        SizedBox(height: 12.h),

        _buildLegendItem(
          color: Colors.red,
          icon: Icons.dangerous,
          title: 'خطر عالي',
          subtitle: '20+ بلاغ - يتطلب حذر شديد',
        ),

        SizedBox(height: 8.h),

        _buildLegendItem(
          color: Colors.orange,
          icon: Icons.warning,
          title: 'خطر متوسط',
          subtitle: '10-19 بلاغ - احذر عند التنقل',
        ),

        SizedBox(height: 8.h),

        _buildLegendItem(
          color: Colors.yellow[700] ?? Colors.yellow,
          icon: Icons.info,
          title: 'خطر منخفض',
          subtitle: '5-9 بلاغات - منطقة آمنة نسبياً',
        ),

        SizedBox(height: 8.h),

        _buildLegendItem(
          color: Colors.green,
          icon: Icons.check_circle,
          title: 'آمن',
          subtitle: 'أقل من 5 بلاغات - منطقة آمنة',
        ),
      ],
    );
  }

  Widget _buildCrimeTypesSection(HeatmapLoaded state) {
    final crimeStats = _analyzeCrimeTypes(state.reports);
    final topCrimes =
        crimeStats.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value))
          ..take(5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أنواع الجرائم الشائعة',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),

        SizedBox(height: 12.h),

        ...topCrimes
            .map(
              (crime) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _buildLegendItem(
                  color: _getCrimeTypeColor(crime.key),
                  icon: _getCrimeTypeIcon(crime.key),
                  title: crime.key,
                  subtitle: '${crime.value} بلاغ',
                ),
              ),
            )
            ,
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String title,
    required String subtitle,
    IconData? icon,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: color.withOpacity(0.05),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // الأيقونة أو الدائرة الملونة
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child:
                icon != null
                    ? Icon(icon, color: Colors.white, size: 16.sp)
                    : null,
          ),

          SizedBox(width: 12.w),

          // النصوص
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _analyzeCrimeTypes(List<dynamic> reports) {
    final Map<String, int> crimeTypes = {};
    for (final report in reports) {
      final type = report.reportType ?? 'غير محدد';
      if (type != 'غير محدد') {
        crimeTypes[type] = (crimeTypes[type] ?? 0) + 1;
      }
    }
    return crimeTypes;
  }

  Color _getCrimeTypeColor(String crimeType) {
    if (crimeType.contains('سرقة')) return Colors.red;
    if (crimeType.contains('اعتداء')) return Colors.orange;
    if (crimeType.contains('مرور') || crimeType.contains('حادث')) {
      return Colors.blue;
    }
    if (crimeType.contains('مخدرات')) return Colors.purple;
    if (crimeType.contains('احتيال')) {
      return Colors.yellow[700] ?? Colors.yellow;
    }
    if (crimeType.contains('عنف')) return Colors.pink;
    return Colors.grey;
  }

  IconData _getCrimeTypeIcon(String crimeType) {
    if (crimeType.contains('سرقة')) return Icons.security;
    if (crimeType.contains('اعتداء')) return Icons.warning;
    if (crimeType.contains('مرور') || crimeType.contains('حادث')) {
      return Icons.directions_car;
    }
    if (crimeType.contains('مخدرات')) return Icons.local_pharmacy;
    if (crimeType.contains('احتيال')) return Icons.monetization_on;
    if (crimeType.contains('عنف')) return Icons.home;
    return Icons.report_problem;
  }
}
