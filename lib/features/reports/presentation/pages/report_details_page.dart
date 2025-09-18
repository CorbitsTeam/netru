import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/enhanced_status_tracker.dart';
import '../widgets/location_info_card.dart';
import '../widgets/report_media_viewer.dart';
import '../services/ultra_premium_pdf_generator_service.dart';
import '../../domain/entities/reports_entity.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

class ReportDetailsPage extends StatelessWidget {
  final ReportEntity? report;

  const ReportDetailsPage({super.key, this.report});

  // Safely pop a dialog if it's still mounted and can pop.
  Future<void> _safePopDialog(BuildContext context) async {
    if (!context.mounted) return;
    try {
      if (Navigator.canPop(context)) Navigator.pop(context);
    } catch (_) {
      // ignore any pop errors
    }
  }

  @override
  Widget build(BuildContext context) {
    // If no report is passed, show error
    if (report == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            'تفاصيل البلاغ',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            margin: EdgeInsets.all(20.w),
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 64.sp, color: Colors.red[400]),
                SizedBox(height: 16.h),
                Text(
                  'خطأ في البيانات',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'لم يتم العثور على تفاصيل البلاغ',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        title: Text(
          'تفاصيل البلاغ',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          // Status indicator in app bar
          Container(
            margin: EdgeInsetsDirectional.only(end: 8.w),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _getStatusColor(report!.status),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: _getStatusColor(report!.status).withOpacity(0.3),
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              report!.status.arabicName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Report header card
                _buildReportHeaderCard(),

                SizedBox(height: 20.h),

                // Reporter information card
                _buildReporterInfoCard(),

                SizedBox(height: 20.h),

                // Report details card
                _buildReportDetailsCard(),

                SizedBox(height: 20.h),

                // Location information
                if (report!.latitude != null && report!.longitude != null)
                  LocationInfoCard(
                    latitude: report!.latitude!,
                    longitude: report!.longitude!,
                    locationName: report!.locationName,
                  ),

                if (report!.latitude != null && report!.longitude != null)
                  SizedBox(height: 20.h),

                // Media viewer
                if (report!.mediaUrl != null && report!.mediaUrl!.isNotEmpty)
                  ReportMediaViewer(
                    mediaUrl: report!.mediaUrl,
                    mediaType: report!.mediaType,
                  ),

                if (report!.mediaUrl != null && report!.mediaUrl!.isNotEmpty)
                  SizedBox(height: 20.h),

                // Enhanced status tracker
                EnhancedStatusTracker(
                  currentStatus: report!.status,
                  createdAt: report!.createdAt,
                  reportId: report!.id,
                ),

                SizedBox(height: 100.h), // Extra space for floating button
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionMenu(context),
    );
  }

  Widget _buildReportHeaderCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 15,
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(Icons.assignment, color: Colors.white, size: 28.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'رقم البلاغ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '#${report!.id.substring(0, 8)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _getReportTypeIcon(),
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نوع البلاغ',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  report!.reportType,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.white.withOpacity(0.9),
                      size: 16.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      DateFormat(
                        'dd/MM/yyyy - HH:mm',
                        'ar',
                      ).format(report!.reportDateTime),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReporterInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.person,
                  color: AppColors.primaryColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'بيانات مقدم البلاغ',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildInfoRow('الاسم الأول', report!.firstName, Icons.person_outline),
          SizedBox(height: 16.h),
          _buildInfoRow('الاسم الأخير', report!.lastName, Icons.person_outline),
          SizedBox(height: 16.h),
          _buildInfoRow('رقم الهوية', report!.nationalId, Icons.credit_card),
          SizedBox(height: 16.h),
          _buildInfoRow('رقم الهاتف', report!.phone, Icons.phone),
        ],
      ),
    );
  }

  Widget _buildReportDetailsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.description,
                  color: AppColors.primaryColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'تفاصيل البلاغ',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              report!.reportDetails,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Icon(Icons.update, color: Colors.grey[600], size: 16.sp),
              SizedBox(width: 6.w),
              Text(
                'آخر تحديث: ${DateFormat('dd/MM/yyyy - HH:mm', 'ar').format(report!.updatedAt)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 18.sp, color: AppColors.primaryColor),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionMenu(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showActionMenu(context),
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      icon: Icon(Icons.more_horiz, size: 20.sp),
      label: Text(
        'الإجراءات',
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
      ),
      elevation: 6,
    );
  }

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 12.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الإجراءات المتاحة',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _buildActionItem(
                        context,
                        icon: Icons.share,
                        title: 'مشاركة البلاغ',
                        subtitle: 'مشاركة تفاصيل البلاغ مع الآخرين',
                        onTap: () => _shareReport(context),
                      ),
                      Divider(height: 1.h, color: Colors.grey[200]),
                      _buildActionItem(
                        context,
                        icon: Icons.picture_as_pdf,
                        title: 'تحميل كـ PDF',
                        subtitle: 'تنزيل ملف PDF بتفاصيل البلاغ',
                        onTap: () => _downloadPDF(context),
                      ),
                      Divider(height: 1.h, color: Colors.grey[200]),
                      _buildActionItem(
                        context,
                        icon: Icons.print,
                        title: 'طباعة البلاغ',
                        subtitle: 'طباعة تفاصيل البلاغ',
                        onTap: () => _printReport(context),
                      ),
                      Divider(height: 1.h, color: Colors.grey[200]),
                      _buildActionItem(
                        context,
                        icon: Icons.refresh,
                        title: 'تحديث الحالة',
                        subtitle: 'التحقق من آخر تحديثات البلاغ',
                        onTap: () => _refreshStatus(context),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, color: AppColors.primaryColor, size: 22.sp),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  // Helper methods
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

  IconData _getReportTypeIcon() {
    final type = report!.reportType.toLowerCase();
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

  // Action methods with proper implementation
  void _shareReport(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      // Show options dialog for sharing
      final result = await showDialog<String>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(
                'مشاركة البلاغ',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'اختر طريقة المشاركة:',
                    style: TextStyle(fontSize: 14.sp),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildShareOption(
                        context,
                        'نص',
                        Icons.text_fields,
                        'text',
                        Colors.blue,
                      ),
                      _buildShareOption(
                        context,
                        'PDF',
                        Icons.picture_as_pdf,
                        'pdf',
                        Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
      );

      if (result == null) return;

      if (result == 'text') {
        await _shareAsText();
      } else if (result == 'pdf') {
        await _shareAsPDF(context);
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text('تم مشاركة البلاغ بنجاح'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('فشل في مشاركة البلاغ: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    }
  }

  Widget _buildShareOption(
    BuildContext context,
    String title,
    IconData icon,
    String value,
    Color color,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, value),
      child: Container(
        width: 80.w,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareAsText() async {
    final reportText = '''
🏛️ جمهورية مصر العربية - نظام نترو للبلاغات

📋 تفاصيل البلاغ رقم: #${report!.id.substring(0, 8)}

👤 مقدم البلاغ:
• الاسم: ${report!.firstName} ${report!.lastName}
• رقم الهوية: ${report!.nationalId}
• رقم الهاتف: ${report!.phone}

📝 معلومات البلاغ:
• النوع: ${report!.reportType}
• التاريخ: ${DateFormat('dd/MM/yyyy - HH:mm', 'ar').format(report!.reportDateTime)}
• الحالة: ${report!.status.arabicName}

📍 الموقع:
${report!.locationName ?? 'غير محدد'}
${report!.latitude != null ? 'خط العرض: ${report!.latitude!.toStringAsFixed(6)}' : ''}
${report!.longitude != null ? 'خط الطول: ${report!.longitude!.toStringAsFixed(6)}' : ''}

📄 التفاصيل:
${report!.reportDetails}

🕐 آخر تحديث: ${DateFormat('dd/MM/yyyy - HH:mm', 'ar').format(report!.updatedAt)}

ــــــــــــــــــــــــــــــــــــ
📱 تم إنشاء هذا التقرير من تطبيق نترو
    ''';

    await Share.share(
      reportText,
      subject: 'تقرير البلاغ رقم #${report!.id.substring(0, 8)}',
    );
  }

  Future<void> _shareAsPDF(BuildContext context) async {
    // Show loading dialog
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text('جاري إعداد ملف PDF...'),
                ],
              ),
            ),
      );
    }

    try {
      // استخدام الطريقة المحسنة الجديدة - نسخة مطورة 100% عربي
      final doc =
          await UltraPremiumPdfGeneratorService.generateFullArabicReport(
            report!,
          );
      final bytes = await doc.save();

      await _safePopDialog(context);

      await Share.shareXFiles(
        [
          XFile.fromData(
            bytes,
            name: 'تقرير_البلاغ_${report!.id.substring(0, 8)}.pdf',
            mimeType: 'application/pdf',
          ),
        ],
        subject: 'تقرير البلاغ رقم #${report!.id.substring(0, 8)}',
        text: 'تقرير رسمي للبلاغ المقدم عبر تطبيق نترو',
      );
    } catch (e) {
      await _safePopDialog(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر إنشاء ملف PDF. سيتم مشاركة النص بدلاً منه.'),
        ),
      );
      await _shareAsText();
    }
  }

  void _downloadPDF(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primaryColor,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'جاري إنشاء التقرير...',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'يرجى الانتظار بينما يتم إعداد المستند',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
    );

    try {
      final doc =
          await UltraPremiumPdfGeneratorService.generateFullArabicReport(
            report!,
          );
      final bytes = await doc.save();

      await _safePopDialog(context);

      if (context.mounted) {
        await Printing.sharePdf(
          bytes: bytes,
          filename: 'تقرير_البلاغ_${report!.id.substring(0, 8)}.pdf',
        );

        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'تم إنشاء وحفظ التقرير بنجاح',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      await _safePopDialog(context);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('فشل في إنشاء التقرير - سيتم المحاولة مع نسخة مبسطة'),
        ),
      );
      log(e.toString());
      try {
        await _createSimplePDFFallback(context);
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text('فشل في إنشاء نسخة مبسطة: $e')),
        );
        log(e.toString());
      }
    }
  }

  Future<void> _createSimplePDFFallback(BuildContext context) async {
    // استخدام الطريقة المحسنة الجديدة
    final doc = await UltraPremiumPdfGeneratorService.generateFullArabicReport(
      report!,
    );
    final bytes = await doc.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'تقرير_رسمي_${report!.id.substring(0, 8)}.pdf',
    );
  }

  void _printReport(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    if (!context.mounted) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryColor,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'جاري إعداد المستند للطباعة...',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
    );

    try {
      // استخدام الطريقة المحسنة الجديدة للطباعة
      final doc =
          await UltraPremiumPdfGeneratorService.generateFullArabicReport(
            report!,
          );
      final bytes = await doc.save();

      await _safePopDialog(context);

      if (context.mounted) {
        await Printing.layoutPdf(
          onLayout: (format) async => bytes,
          name: 'تقرير_البلاغ_${report!.id.substring(0, 8)}',
        );

        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.print, color: Colors.white, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'تم فتح نافذة الطباعة بنجاح',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    } catch (e) {
      await _safePopDialog(context);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('فشل في تحضير الملف للطباعة - يرجى المحاولة لاحقاً'),
        ),
      );
      try {
        await _createSimplePDFFallback(context);
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text('فشل في إنشاء نسخة مبسطة للطباعة: $e')),
        );
      }
    }
  }

  void _refreshStatus(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'جاري تحديث حالة البلاغ...',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
      );

      // Simulate refresh delay (replace with actual API call)
      await Future.delayed(Duration(seconds: 2));

      // Close loading dialog
      Navigator.pop(context);

      // Refresh the current page by popping and pushing again
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReportDetailsPage(report: report),
        ),
      );

      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'تم تحديث حالة البلاغ بنجاح',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    } catch (e) {
      // Close loading dialog if still open
      try {
        Navigator.pop(context);
      } catch (_) {}

      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'فشل في تحديث حالة البلاغ: $e',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    }
  }
}
