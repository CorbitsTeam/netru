import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import '../../../../domain/entities/reports_entity.dart';
import 'info_row.dart';

class ReporterInfoCard extends StatelessWidget {
  final ReportEntity report;

  const ReporterInfoCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: AppColors.primaryColor, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'معلومات مقدم البلاغ',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          InfoRow(
            label: 'الاسم الأول',
            value: report.firstName,
            icon: Icons.person_outline,
          ),
          SizedBox(height: 16.h),
          InfoRow(
            label: 'الاسم الأخير',
            value: report.lastName,
            icon: Icons.person_outline,
          ),
          SizedBox(height: 16.h),
          InfoRow(
            label: 'رقم الهوية',
            value: report.nationalId,
            icon: Icons.credit_card,
          ),
          SizedBox(height: 16.h),
          InfoRow(label: 'رقم الهاتف', value: report.phone, icon: Icons.phone),
        ],
      ),
    );
  }
}
