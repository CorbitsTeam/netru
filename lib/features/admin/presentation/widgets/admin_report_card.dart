import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/admin_report_entity.dart';
import '../cubit/admin_reports_cubit.dart';

class AdminReportCard extends StatelessWidget {
  final AdminReportEntity report;
  final VoidCallback? onDetailsPressed;

  const AdminReportCard({
    super.key,
    required this.report,
    this.onDetailsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDetailsPressed ?? () => _navigateToDetails(context),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
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
            color: _getStatusColor(report.reportStatus).withOpacity(0.2),
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
                      color: _getStatusColor(report.reportStatus),
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: _getStatusColor(
                            report.reportStatus,
                          ).withOpacity(0.3),
                          spreadRadius: 0,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      report.reportStatus.arabicName,
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

              // Reporter info
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.person,
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
                          'المبلغ',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${report.reporterFirstName} ${report.reporterLastName}',
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
                  if (report.priorityLevel == PriorityLevel.high ||
                      report.priorityLevel == PriorityLevel.urgent)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(
                          report.priorityLevel,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: _getPriorityColor(report.priorityLevel),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.priority_high,
                            size: 12.sp,
                            color: _getPriorityColor(report.priorityLevel),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            report.priorityLevel.arabicName,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: _getPriorityColor(report.priorityLevel),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              SizedBox(height: 16.h),

              // Report details
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تفاصيل البلاغ',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      report.reportDetails,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
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
                            ).format(report.submittedAt),
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
                  if (report.incidentLocationAddress != null) ...[
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.location_on,
                      size: 16.sp,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        report.incidentLocationAddress!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),

              SizedBox(height: 16.h),

              // Progress indicator for admin view
              _buildAdminProgressBar(),

              SizedBox(height: 16.h),

              // Admin action buttons
              _buildAdminActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminProgressBar() {
    final progressValue = _getProgressValue();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'تقدم معالجة البلاغ',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: _getVerificationColor(
                      report.verificationStatus,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    _getVerificationText(report.verificationStatus),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: _getVerificationColor(report.verificationStatus),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '${(progressValue * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: _getStatusColor(report.reportStatus),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 6.h),
        LinearProgressIndicator(
          value: progressValue,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            _getStatusColor(report.reportStatus),
          ),
          minHeight: 6.h,
        ),
      ],
    );
  }

  Widget _buildAdminActionButtons(BuildContext context) {
    return Row(
      children: [
        // View details button
        Expanded(
          flex: 2,
          child: Container(
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
        ),

        SizedBox(width: 8.w),

        // Quick action buttons
        if (report.reportStatus == AdminReportStatus.pending) ...[
          _buildQuickActionButton(
            context,
            icon: Icons.check,
            color: Colors.green,
            onTap: () => _approveReport(context),
            tooltip: 'موافقة',
          ),
          SizedBox(width: 8.w),
          _buildQuickActionButton(
            context,
            icon: Icons.close,
            color: Colors.red,
            onTap: () => _rejectReport(context),
            tooltip: 'رفض',
          ),
        ] else if (report.reportStatus ==
            AdminReportStatus.underInvestigation) ...[
          _buildQuickActionButton(
            context,
            icon: Icons.done_all,
            color: Colors.green,
            onTap: () => _resolveReport(context),
            tooltip: 'حل',
          ),
          SizedBox(width: 8.w),
          _buildQuickActionButton(
            context,
            icon: Icons.person_add,
            color: Colors.blue,
            onTap: () => _assignReport(context),
            tooltip: 'تعيين',
          ),
        ] else if (report.reportStatus == AdminReportStatus.received) ...[
          _buildQuickActionButton(
            context,
            icon: Icons.play_arrow,
            color: Colors.orange,
            onTap: () => _startInvestigation(context),
            tooltip: 'بدء التحقيق',
          ),
        ],
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Icon(icon, color: color, size: 20.sp),
        ),
      ),
    );
  }

  double _getProgressValue() {
    switch (report.reportStatus) {
      case AdminReportStatus.received:
        return 0.15;
      case AdminReportStatus.pending:
        return 0.3;
      case AdminReportStatus.underInvestigation:
        return 0.6;
      case AdminReportStatus.resolved:
        return 1.0;
      case AdminReportStatus.closed:
        return 1.0;
      case AdminReportStatus.rejected:
        return 0.1;
    }
  }

  Color _getStatusColor(AdminReportStatus status) {
    switch (status) {
      case AdminReportStatus.received:
        return AppColors.primaryColor;
      case AdminReportStatus.pending:
        return Colors.orange;
      case AdminReportStatus.underInvestigation:
        return Colors.purple;
      case AdminReportStatus.resolved:
        return Colors.green;
      case AdminReportStatus.closed:
        return Colors.grey;
      case AdminReportStatus.rejected:
        return Colors.red;
    }
  }

  Color _getPriorityColor(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.low:
        return Colors.blue;
      case PriorityLevel.medium:
        return Colors.orange;
      case PriorityLevel.high:
        return Colors.red;
      case PriorityLevel.urgent:
        return Colors.purple;
    }
  }

  Color _getVerificationColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.unverified:
        return Colors.orange;
      case VerificationStatus.verified:
        return Colors.green;
      case VerificationStatus.flagged:
        return Colors.red;
    }
  }

  String _getVerificationText(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.unverified:
        return 'غير محقق';
      case VerificationStatus.verified:
        return 'محقق';
      case VerificationStatus.flagged:
        return 'مشكوك فيه';
    }
  }

  void _navigateToDetails(BuildContext context) {
    // Navigate to report details page
    Navigator.pushNamed(context, '/admin/reports/details', arguments: report);
  }

  void _approveReport(BuildContext context) {
    context.read<AdminReportsCubit>().approveReport(
      report.id,
      notes: 'تمت الموافقة على البلاغ من قبل الإدارة',
    );
  }

  void _rejectReport(BuildContext context) {
    _showRejectDialog(context);
  }

  void _resolveReport(BuildContext context) {
    context.read<AdminReportsCubit>().approveReport(
      report.id,
      notes: 'تم حل البلاغ بنجاح',
    );
  }

  void _assignReport(BuildContext context) {
    _showAssignDialog(context);
  }

  void _startInvestigation(BuildContext context) {
    context.read<AdminReportsCubit>().updateReportStatusById(
      report.id,
      AdminReportStatus.underInvestigation,
      notes: 'تم بدء التحقيق في البلاغ',
    );
  }

  void _showRejectDialog(BuildContext context) {
    String reason = '';
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('رفض البلاغ'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('يرجى إدخال سبب الرفض:'),
                SizedBox(height: 16.h),
                TextField(
                  onChanged: (value) => reason = value,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'سبب الرفض...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AdminReportsCubit>().rejectReport(
                    report.id,
                    notes: reason.isNotEmpty ? reason : 'تم رفض البلاغ',
                  );
                },
                child: const Text('رفض البلاغ'),
              ),
            ],
          ),
    );
  }

  void _showAssignDialog(BuildContext context) {
    String investigatorId = '';
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تعيين محقق'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('يرجى إدخال معرف المحقق:'),
                SizedBox(height: 16.h),
                TextField(
                  onChanged: (value) => investigatorId = value,
                  decoration: const InputDecoration(
                    hintText: 'معرف المحقق...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (investigatorId.isNotEmpty) {
                    context
                        .read<AdminReportsCubit>()
                        .assignReportToInvestigator(
                          report.id,
                          investigatorId,
                          notes: 'تم تعيين المحقق للبلاغ',
                        );
                  }
                },
                child: const Text('تعيين'),
              ),
            ],
          ),
    );
  }
}
