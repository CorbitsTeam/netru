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
    return Container(
      width: double.infinity,
      height: 115.h,
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffCBCBCB), width: 0.8),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 18.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'بلاغ رقم #${report.id.substring(0, 8)}',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          '| ${report.reportType}',
                          style: TextStyle(fontSize: 14.sp),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 25.h,
                  width: 135.w,
                  decoration: BoxDecoration(
                    color: _getStatusColor(report.status),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      report.status.arabicName,
                      style: TextStyle(color: Colors.white, fontSize: 10.sp),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            Row(
              children: [
                Text(
                  DateFormat(
                    'dd MMMM yyyy - HH:mm',
                    'ar',
                  ).format(report.reportDateTime),
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _getLocationText(),
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: onDetailsPressed ?? () => _navigateToDetails(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('تفاصيل البلاغ', style: TextStyle(fontSize: 12.sp)),
                      Icon(Icons.arrow_forward_ios, size: 14.sp),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return AppColors.grey;
      case ReportStatus.inProgress:
        return AppColors.orange;
      case ReportStatus.completed:
        return AppColors.green;
      case ReportStatus.rejected:
        return AppColors.red;
    }
  }

  String _getLocationText() {
    if (report.latitude != null && report.longitude != null) {
      return '${report.latitude!.toStringAsFixed(6)}, ${report.longitude!.toStringAsFixed(6)}';
    }
    return 'الموقع غير محدد';
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.pushNamed(context, Routes.reportDetailsPage, arguments: report);
  }
}
