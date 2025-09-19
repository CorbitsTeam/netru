import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/routing/routes.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/reports_entity.dart';
import '../../../../core/theme/app_colors.dart';

class ReportCard extends StatelessWidget {
  final ReportEntity report;
  final VoidCallback? onDetailsPressed;

  const ReportCard({super.key, required this.report, this.onDetailsPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDetailsPressed ?? () => _navigateToDetails(context),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: _getStatusColor(report.status).withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with report number and type
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.assignment,
                          size: 16.sp,
                          color: AppColors.primaryColor,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          '#${report.id.substring(0, 8)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(report.status),
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: _getStatusColor(
                            report.status,
                          ).withOpacity(0.3),
                          spreadRadius: 0,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      report.status.arabicName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Report type with icon
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      _getReportTypeIcon(),
                      size: 20.sp,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نوع البلاغ',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          report.reportType,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Date and location info
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16.sp,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            DateFormat(
                              'dd/MM/yyyy - HH:mm',
                              'ar',
                            ).format(report.reportDateTime),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.location_on, size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 4.w),
                  Flexible(
                    child: Text(
                      _getLocationText(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Progress indicator
              _buildProgressBar(),

              SizedBox(height: 16.h),

              // View details button
              Container(
                width: double.infinity,
                height: 40.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor,
                      AppColors.primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'عرض التفاصيل',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progressValue = _getProgressValue();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'تقدم البلاغ',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progressValue * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12.sp,
                color: _getStatusColor(report.status),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        LinearProgressIndicator(
          value: progressValue,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            _getStatusColor(report.status),
          ),
          minHeight: 6.h,
        ),
      ],
    );
  }

  double _getProgressValue() {
    switch (report.status) {
      case ReportStatus.received:
        return 0.2;
      case ReportStatus.underReview:
        return 0.4;
      case ReportStatus.dataVerification:
        return 0.6;
      case ReportStatus.actionTaken:
        return 0.8;
      case ReportStatus.completed:
        return 1.0;
      case ReportStatus.rejected:
        return 0.1;
    }
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

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.received:
        return AppColors.primaryColor;
      case ReportStatus.underReview:
        return Colors.orange;
      case ReportStatus.dataVerification:
        return Colors.amber[700]!;
      case ReportStatus.actionTaken:
        return Colors.blue;
      case ReportStatus.completed:
        return Colors.green;
      case ReportStatus.rejected:
        return Colors.red;
    }
  }

  String _getLocationText() {
    if (report.locationName != null && report.locationName!.isNotEmpty) {
      return report.locationName!;
    } else if (report.latitude != null && report.longitude != null) {
      return 'موقع محدد';
    }
    return 'الموقع غير محدد';
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.pushNamed(context, Routes.reportDetailsPage, arguments: report);
  }
}
