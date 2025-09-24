import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/reports_entity.dart';

class ReportHeaderCard extends StatelessWidget {
  final ReportEntity report;

  const ReportHeaderCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _getReportTypeIcon(),
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'البلاغ رقم #${report.id.substring(0, 8)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      report.reportType,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  report.status.arabicName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'تاريخ البلاغ: ${DateFormat('dd/MM/yyyy - HH:mm', 'ar').format(report.reportDateTime)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.update,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'آخر تحديث: ${DateFormat('dd/MM/yyyy', 'ar').format(report.updatedAt)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getReportTypeIcon() {
    final type = report.reportType.toLowerCase();
    if (type.contains('حريق') || type.contains('fire')) {
      return Icons.local_fire_department;
    } else if (type.contains('طبي') ||
        type.contains('إسعاف') ||
        type.contains('medical')) {
      return Icons.medical_services;
    } else if (type.contains('جريمة') ||
        type.contains('سرقة') ||
        type.contains('crime')) {
      return Icons.security;
    } else if (type.contains('حادث') ||
        type.contains('مرور') ||
        type.contains('traffic')) {
      return Icons.car_crash;
    } else if (type.contains('كهرباء') || type.contains('electric')) {
      return Icons.electrical_services;
    } else if (type.contains('مياه') || type.contains('water')) {
      return Icons.water_drop;
    } else if (type.contains('طريق') || type.contains('infrastructure')) {
      return Icons.construction;
    } else {
      return Icons.report_problem;
    }
  }
}
