import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/widgets/app_widgets.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:netru_app/features/reports/domain/entities/reports_entity.dart';
import 'package:intl/intl.dart';

/// A reusable widget for displaying report status with consistent styling
class AppReportStatusBadge extends StatelessWidget {
  final ReportStatus status;
  final double? fontSize;
  final EdgeInsets? padding;

  const AppReportStatusBadge({
    super.key,
    required this.status,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: UIConstants.borderRadiusSmall,
        border: Border.all(
          color: _getStatusColor(status).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        status.arabicName,
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: fontSize ?? UIConstants.fontSizeSmall,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.received:
        return Colors.blue;
      case ReportStatus.underReview:
        return Colors.orange;
      case ReportStatus.dataVerification:
        return Colors.amber;
      case ReportStatus.actionTaken:
        return Colors.purple;
      case ReportStatus.completed:
        return Colors.green;
      case ReportStatus.rejected:
        return Colors.red;
    }
  }
}

/// A reusable widget for displaying a report summary card
class AppReportSummaryCard extends StatelessWidget {
  final int totalReports;
  final int pendingReports;
  final int resolvedReports;
  final EdgeInsets? margin;

  const AppReportSummaryCard({
    super.key,
    required this.totalReports,
    required this.pendingReports,
    required this.resolvedReports,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin:
          margin ?? UIConstants.paddingHorizontalMedium.copyWith(bottom: 20.h),
      padding: UIConstants.paddingLarge,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: UIConstants.borderRadiusLarge,
        boxShadow: UIConstants.cardShadow,
      ),
      child: Row(
        children: [
          _buildSummaryItem(
            'المجموع',
            totalReports.toString(),
            Icons.receipt_long,
          ),
          const Spacer(),
          _buildSummaryItem(
            'قيد المراجعة',
            pendingReports.toString(),
            Icons.pending_actions,
          ),
          const Spacer(),
          _buildSummaryItem(
            'محلولة',
            resolvedReports.toString(),
            Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: UIConstants.paddingSmall,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: UIConstants.borderRadiusSmall,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: UIConstants.iconSizeLarge,
          ),
        ),
        UIConstants.verticalSpaceSmall,
        Text(
          value,
          style: TextStyle(
            fontSize: UIConstants.fontSizeTitle,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: UIConstants.fontSizeSmall,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

/// Enhanced report card widget with improved design and functionality
class EnhancedReportCard extends StatelessWidget {
  final ReportEntity report;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final VoidCallback? onDownload;
  final EdgeInsets? margin;

  const EnhancedReportCard({
    super.key,
    required this.report,
    this.onTap,
    this.onShare,
    this.onDownload,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      onTap: onTap,
      child: Padding(
        padding: UIConstants.paddingMedium,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with ID and Status
            Row(
              children: [
                Container(
                  padding: UIConstants.paddingSmall,
                  decoration: BoxDecoration(
                    color: _getReportTypeColor().withValues(alpha: 0.1),
                    borderRadius: UIConstants.borderRadiusSmall,
                  ),
                  child: Icon(
                    _getReportTypeIcon(),
                    size: UIConstants.iconSizeMedium,
                    color: _getReportTypeColor(),
                  ),
                ),
                UIConstants.horizontalSpaceSmall,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'بلاغ #${report.id.substring(0, 8)}',
                        style: TextStyle(
                          fontSize: UIConstants.fontSizeMedium,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                      ),
                      Text(
                        report.reportType,
                        style: TextStyle(
                          fontSize: UIConstants.fontSizeSmall,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                AppReportStatusBadge(status: report.status),
              ],
            ),

            UIConstants.verticalSpaceMedium,

            // Report Details
            Text(
              report.reportDetails,
              style: TextStyle(
                fontSize: UIConstants.fontSizeMedium,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            UIConstants.verticalSpaceMedium,

            // Date and Location Info
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: UIConstants.iconSizeSmall,
                  color: Colors.grey[600],
                ),
                UIConstants.horizontalSpaceSmall,
                Text(
                  DateFormat(
                    'dd/MM/yyyy - HH:mm',
                    'ar',
                  ).format(report.reportDateTime),
                  style: TextStyle(
                    fontSize: UIConstants.fontSizeSmall,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                if (report.locationName != null) ...[
                  Icon(
                    Icons.location_on,
                    size: UIConstants.iconSizeSmall,
                    color: Colors.grey[600],
                  ),
                  UIConstants.horizontalSpaceSmall,
                  Flexible(
                    child: Text(
                      report.locationName!,
                      style: TextStyle(
                        fontSize: UIConstants.fontSizeSmall,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),

            // Action Buttons
            if (onShare != null || onDownload != null) ...[
              UIConstants.verticalSpaceMedium,
              const AppDivider(),
              UIConstants.verticalSpaceSmall,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (onShare != null)
                    TextButton.icon(
                      onPressed: onShare,
                      icon: Icon(Icons.share, size: UIConstants.iconSizeSmall),
                      label: const Text('مشاركة'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                      ),
                    ),
                  if (onDownload != null)
                    TextButton.icon(
                      onPressed: onDownload,
                      icon: Icon(
                        Icons.download,
                        size: UIConstants.iconSizeSmall,
                      ),
                      label: const Text('تحميل'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getReportTypeColor() {
    final type = report.reportType.toLowerCase();
    if (type.contains('حريق') || type.contains('fire')) {
      return Colors.red;
    } else if (type.contains('طبي') ||
        type.contains('medical') ||
        type.contains('إسعاف')) {
      return Colors.green;
    } else if (type.contains('جريمة') ||
        type.contains('crime') ||
        type.contains('سرقة')) {
      return Colors.orange;
    }
    return AppColors.primaryColor;
  }

  IconData _getReportTypeIcon() {
    final type = report.reportType.toLowerCase();
    if (type.contains('حريق') || type.contains('fire')) {
      return Icons.local_fire_department;
    } else if (type.contains('طبي') ||
        type.contains('medical') ||
        type.contains('إسعاف')) {
      return Icons.medical_services;
    } else if (type.contains('جريمة') ||
        type.contains('crime') ||
        type.contains('سرقة')) {
      return Icons.security;
    } else if (type.contains('حادث') || type.contains('accident')) {
      return Icons.car_crash;
    } else if (type.contains('مشاجرة') || type.contains('fight')) {
      return Icons.groups;
    }
    return Icons.report_problem;
  }
}
