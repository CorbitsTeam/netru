import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import '../../domain/entities/reports_entity.dart';

class ReportStatusTracker extends StatelessWidget {
  final ReportStatus currentStatus;
  final DateTime? createdAt;

  const ReportStatusTracker({
    super.key,
    required this.currentStatus,
    this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تتبع حالة البلاغ',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(height: 16.h),

          // Status Steps
          _buildStatusStep(
            title: 'تم استلام البلاغ',
            description: 'تم استلام البلاغ وتسجيله في النظام',
            icon: Icons.check_circle,
            color: Colors.green,
            status: ReportStatus.received,
            isCompleted: _isStepCompleted(ReportStatus.received),
            isActive: currentStatus == ReportStatus.received,
          ),

          _buildConnectorLine(_isStepCompleted(ReportStatus.underReview)),

          _buildStatusStep(
            title: 'قيد المراجعة',
            description: 'يتم مراجعة البلاغ من قبل الفريق المختص',
            icon: Icons.visibility,
            color: Colors.orange,
            status: ReportStatus.underReview,
            isCompleted: _isStepCompleted(ReportStatus.underReview),
            isActive: currentStatus == ReportStatus.underReview,
          ),

          _buildConnectorLine(_isStepCompleted(ReportStatus.dataVerification)),

          _buildStatusStep(
            title: 'التحقق من البيانات',
            description: 'سيتم التحقق من صحة البيانات المرسلة',
            icon: Icons.verified,
            color: Colors.blue,
            status: ReportStatus.dataVerification,
            isCompleted: _isStepCompleted(ReportStatus.dataVerification),
            isActive: currentStatus == ReportStatus.dataVerification,
          ),

          _buildConnectorLine(_isStepCompleted(ReportStatus.actionTaken)),

          _buildStatusStep(
            title: 'اتخاذ الإجراء المناسب',
            description: 'سيتم اتخاذ الإجراء المناسب حسب نوع البلاغ',
            icon: Icons.gavel,
            color: Colors.purple,
            status: ReportStatus.actionTaken,
            isCompleted: _isStepCompleted(ReportStatus.actionTaken),
            isActive: currentStatus == ReportStatus.actionTaken,
            isLast: true,
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

  Widget _buildStatusStep({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required ReportStatus status,
    required bool isCompleted,
    required bool isActive,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Icon
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                isCompleted
                    ? color
                    : isActive
                    ? color.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: isCompleted || isActive ? Colors.white : Colors.grey,
            size: 20.sp,
          ),
        ),
        SizedBox(width: 12.w),

        // Status Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isCompleted || isActive ? Colors.black87 : Colors.grey,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isCompleted || isActive ? Colors.black54 : Colors.grey,
                ),
              ),
              if (isActive && createdAt != null) ...[
                SizedBox(height: 4.h),
                Text(
                  'الوقت: ${_formatDateTime(createdAt!)}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnectorLine(bool isCompleted) {
    return Container(
      margin: EdgeInsets.only(left: 20.w, top: 8.h, bottom: 8.h),
      width: 2.w,
      height: 20.h,
      color: isCompleted ? Colors.green : Colors.grey.withOpacity(0.3),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
