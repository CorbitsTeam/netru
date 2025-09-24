import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/reports_entity.dart';

class EnhancedStatusTracker extends StatelessWidget {
  final ReportStatus currentStatus;
  final DateTime? createdAt;
  final String reportId;

  const EnhancedStatusTracker({
    super.key,
    required this.currentStatus,
    this.createdAt,
    required this.reportId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.track_changes, color: Colors.white, size: 20.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تتبع حالة البلاغ',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'الحالة الحالية: ${currentStatus.arabicName}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (createdAt != null) ...[
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.white,
                          size: 12.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'تاريخ الإنشاء: ${DateFormat('dd/MM/yyyy - hh:mm a', 'ar').format(createdAt!)}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Status Timeline using Stepper
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مراحل معالجة البلاغ',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildStepper(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    final statuses = [
      {
        'status': ReportStatus.received,
        'title': 'استلام البلاغ',
        'description': 'تم استلام البلاغ وتسجيله في النظام',
        'icon': Icons.receipt_long,
      },
      {
        'status': ReportStatus.underReview,
        'title': 'مراجعة البلاغ',
        'description': 'يتم مراجعة البلاغ من قبل الفريق المختص',
        'icon': Icons.search,
      },
      {
        'status': ReportStatus.dataVerification,
        'title': 'التحقق من البيانات',
        'description': 'التحقق من صحة البيانات المرسلة',
        'icon': Icons.fact_check,
      },
      {
        'status': ReportStatus.actionTaken,
        'title': 'اتخاذ الإجراء',
        'description': 'اتخاذ الإجراء المناسب حسب نوع البلاغ',
        'icon': Icons.engineering,
      },
      {
        'status': ReportStatus.completed,
        'title': 'مكتمل',
        'description': 'تم إنجاز البلاغ بنجاح',
        'icon': Icons.check_circle,
      },
    ];

    return Column(
      children:
          statuses.asMap().entries.map((entry) {
            final index = entry.key;
            final statusData = entry.value;
            final status = statusData['status'] as ReportStatus;
            final isCompleted = _isStepCompleted(status);
            final isActive = status == currentStatus;
            final isLast = index == statuses.length - 1;
            final isRejected =
                currentStatus == ReportStatus.rejected && !isCompleted;

            return _buildCustomStep(
              statusData: statusData,
              isCompleted: isCompleted,
              isActive: isActive,
              isLast: isLast,
              isRejected: isRejected,
            );
          }).toList(),
    );
  }

  Widget _buildCustomStep({
    required Map<String, dynamic> statusData,
    required bool isCompleted,
    required bool isActive,
    required bool isLast,
    required bool isRejected,
  }) {
    Color stepColor;
    Color backgroundColor;

    if (isRejected) {
      stepColor = Colors.red;
      backgroundColor = Colors.red.withValues(alpha: 0.1);
    } else if (isCompleted) {
      stepColor = Colors.green;
      backgroundColor = Colors.green.withValues(alpha: 0.1);
    } else if (isActive) {
      stepColor = AppColors.primaryColor;
      backgroundColor = AppColors.primaryColor.withValues(alpha: 0.1);
    } else {
      stepColor = Colors.grey[400]!;
      backgroundColor = Colors.grey[100]!;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Indicator Column
          Column(
            children: [
              // Step Circle
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: stepColor, width: 2.w),
                  boxShadow:
                      isActive || isCompleted
                          ? [
                            BoxShadow(
                              color: stepColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : [],
                ),
                child: Center(
                  child:
                      isCompleted
                          ? Icon(Icons.check, color: stepColor, size: 20.sp)
                          : Icon(
                            statusData['icon'] as IconData,
                            color: stepColor,
                            size: 18.sp,
                          ),
                ),
              ),
              // Connector Line
              if (!isLast)
                Container(
                  width: 2.w,
                  height: 50.h,
                  margin: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color:
                        isCompleted || isActive ? stepColor : Colors.grey[300],
                    borderRadius: BorderRadius.circular(1.r),
                  ),
                ),
            ],
          ),

          SizedBox(width: 16.w),

          // Content Column
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    statusData['title'] as String,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color:
                          isActive || isCompleted
                              ? stepColor
                              : Colors.grey[700],
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Description
                  Text(
                    statusData['description'] as String,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),

                  // Active Status Badge
                  if (isActive) ...[
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: stepColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: stepColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.h,
                            decoration: BoxDecoration(
                              color: stepColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'المرحلة الحالية',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: stepColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Completed Status Badge
                  if (isCompleted && !isActive) ...[
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 12.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'مكتمل',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isStepCompleted(ReportStatus status) {
    final statusOrder = [
      ReportStatus.received,
      ReportStatus.underReview,
      ReportStatus.dataVerification,
      ReportStatus.actionTaken,
      ReportStatus.completed,
    ];

    final currentIndex = statusOrder.indexOf(currentStatus);
    final stepIndex = statusOrder.indexOf(status);

    if (currentStatus == ReportStatus.completed) {
      return true; // All steps completed
    }

    if (currentStatus == ReportStatus.rejected) {
      return stepIndex == 0; // Only first step completed if rejected
    }

    return stepIndex <= currentIndex;
  }
}
