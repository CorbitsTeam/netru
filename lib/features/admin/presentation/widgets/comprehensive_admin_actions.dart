import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/admin_report_entity.dart';
import '../cubit/admin_reports_cubit.dart';
import '../../../reports/presentation/services/professional_egyptian_pdf_service.dart';
import '../../../reports/domain/entities/reports_entity.dart';

class ComprehensiveAdminActions extends StatelessWidget {
  final AdminReportEntity report;

  const ComprehensiveAdminActions({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
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
                  Icons.admin_panel_settings,
                  color: AppColors.primaryColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'الإجراءات الإدارية',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Quick Status Actions
          Text(
            'إجراءات سريعة:',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              if (report.reportStatus == AdminReportStatus.pending) ...[
                _buildQuickActionButton(
                  context,
                  'بدء التحقيق',
                  Icons.search,
                  Colors.blue,
                  () => _startInvestigation(context),
                ),
                SizedBox(width: 8.w),
              ],
              if (report.reportStatus ==
                  AdminReportStatus.underInvestigation) ...[
                _buildQuickActionButton(
                  context,
                  'حل البلاغ',
                  Icons.check_circle,
                  Colors.green,
                  () => _resolveReport(context),
                ),
                SizedBox(width: 8.w),
              ],
              _buildQuickActionButton(
                context,
                'رفض البلاغ',
                Icons.cancel,
                Colors.red,
                () => _rejectReport(context),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Assignment Actions
          Text(
            'إجراءات التكليف:',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  'تكليف محقق',
                  Icons.assignment_ind,
                  Colors.purple,
                  () => _assignInvestigator(context),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildActionButton(
                  context,
                  'تغيير الأولوية',
                  Icons.priority_high,
                  Colors.orange,
                  () => _changePriority(context),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Documentation Actions
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  'إضافة ملاحظة',
                  Icons.note_add,
                  Colors.indigo,
                  () => _addNote(context),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildActionButton(
                  context,
                  'إضافة تعليق',
                  Icons.comment,
                  Colors.teal,
                  () => _addComment(context),
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Advanced Actions
          ExpansionTile(
            title: Text(
              'إجراءات متقدمة',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            children: [
              ListTile(
                leading: Icon(Icons.verified, color: Colors.green),
                title: const Text('توثيق البلاغ'),
                onTap: () => _verifyReport(context),
              ),
              ListTile(
                leading: Icon(Icons.flag, color: Colors.red),
                title: const Text('الإبلاغ عن محتوى مشكوك فيه'),
                onTap: () => _flagReport(context),
              ),
              ListTile(
                leading: Icon(
                  Icons.transfer_within_a_station,
                  color: Colors.blue,
                ),
                title: const Text('نقل إلى قسم آخر'),
                onTap: () => _transferReport(context),
              ),
              ListTile(
                leading: Icon(Icons.archive, color: Colors.grey),
                title: const Text('أرشفة البلاغ'),
                onTap: () => _archiveReport(context),
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('تصدير تقرير PDF'),
                onTap: () => _generateAndSharePdf(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16.sp),
        label: Text(
          title,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18.sp),
      label: Text(
        title,
        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  // Action Methods
  void _startInvestigation(BuildContext context) {
    context.read<AdminReportsCubit>().updateReportStatusById(
      report.id,
      AdminReportStatus.underInvestigation,
      notes: 'تم بدء التحقيق في البلاغ',
    );
    _showSuccessMessage(context, 'تم بدء التحقيق بنجاح');
  }

  void _resolveReport(BuildContext context) {
    _showNotesDialog(
      context,
      title: 'حل البلاغ',
      hintText: 'اكتب ملاحظات الحل...',
      onSubmit: (notes) {
        context.read<AdminReportsCubit>().updateReportStatusById(
          report.id,
          AdminReportStatus.resolved,
          notes: notes,
        );
        _showSuccessMessage(context, 'تم حل البلاغ بنجاح');
      },
    );
  }

  void _rejectReport(BuildContext context) {
    _showNotesDialog(
      context,
      title: 'رفض البلاغ',
      hintText: 'اكتب سبب الرفض...',
      onSubmit: (notes) {
        context.read<AdminReportsCubit>().updateReportStatusById(
          report.id,
          AdminReportStatus.rejected,
          notes: notes,
        );
        _showSuccessMessage(context, 'تم رفض البلاغ');
      },
    );
  }

  void _assignInvestigator(BuildContext context) {
    // Show dialog to select investigator
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تكليف محقق'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('اختر المحقق المراد تكليفه:'),
                SizedBox(height: 16.h),
                // TODO: Add dropdown for investigators
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'معرف المحقق',
                    hintText: 'أدخل معرف المحقق',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Implement assign investigator
                  _showSuccessMessage(context, 'تم تكليف المحقق بنجاح');
                },
                child: const Text('تكليف'),
              ),
            ],
          ),
    );
  }

  void _changePriority(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تغيير الأولوية'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  PriorityLevel.values.map((priority) {
                    return ListTile(
                      title: Text(priority.arabicName),
                      leading: Radio<PriorityLevel>(
                        value: priority,
                        groupValue: report.priorityLevel,
                        onChanged: (value) {
                          Navigator.pop(context);
                          // TODO: Implement priority change
                          _showSuccessMessage(
                            context,
                            'تم تغيير الأولوية بنجاح',
                          );
                        },
                      ),
                    );
                  }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
            ],
          ),
    );
  }

  void _addNote(BuildContext context) {
    _showNotesDialog(
      context,
      title: 'إضافة ملاحظة إدارية',
      hintText: 'اكتب الملاحظة...',
      onSubmit: (notes) {
        // TODO: Implement add note
        _showSuccessMessage(context, 'تم إضافة الملاحظة بنجاح');
      },
    );
  }

  void _addComment(BuildContext context) {
    _showNotesDialog(
      context,
      title: 'إضافة تعليق',
      hintText: 'اكتب التعليق...',
      onSubmit: (comment) {
        context.read<AdminReportsCubit>().addComment(
          report.id,
          comment,
          isInternal: true,
        );
        _showSuccessMessage(context, 'تم إضافة التعليق بنجاح');
      },
    );
  }

  void _verifyReport(BuildContext context) {
    context.read<AdminReportsCubit>().verifyReportById(
      report.id,
      VerificationStatus.verified,
      notes: 'تم توثيق البلاغ من قبل الإدارة',
    );
    _showSuccessMessage(context, 'تم توثيق البلاغ بنجاح');
  }

  void _flagReport(BuildContext context) {
    context.read<AdminReportsCubit>().verifyReportById(
      report.id,
      VerificationStatus.flagged,
      notes: 'تم الإبلاغ عن محتوى مشكوك فيه',
    );
    _showSuccessMessage(context, 'تم الإبلاغ عن البلاغ');
  }

  void _transferReport(BuildContext context) {
    // TODO: Implement transfer logic
    _showSuccessMessage(context, 'تم نقل البلاغ');
  }

  void _archiveReport(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('أرشفة البلاغ'),
            content: const Text('هل أنت متأكد من أرشفة هذا البلاغ؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Implement archive logic
                  _showSuccessMessage(context, 'تم أرشفة البلاغ');
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: const Text('أرشفة'),
              ),
            ],
          ),
    );
  }

  /// توليد ومشاركة تقرير PDF احترافي
  Future<void> _generateAndSharePdf(BuildContext context) async {
    try {
      // عرض شاشة تحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // تحويل AdminReportEntity إلى ReportEntity
      final reportEntity = ReportEntity(
        id: report.id,
        firstName: report.reporterFirstName,
        lastName: report.reporterLastName,
        nationalId: report.reporterNationalId,
        phone: report.reporterPhone,
        reportType: report.reportTypeName ?? 'بلاغ عام',
        reportTypeId: report.reportTypeId ?? 1,
        reportDetails: report.reportDetails,
        latitude: report.incidentLocationLatitude,
        longitude: report.incidentLocationLongitude,
        locationName: report.incidentLocationAddress,
        reportDateTime: report.incidentDateTime ?? report.submittedAt,
        mediaUrl: report.media.isNotEmpty ? report.media.first.fileUrl : null,
        mediaType:
            report.media.isNotEmpty ? report.media.first.mediaType.name : null,
        status: _convertAdminStatusToReportStatus(report.reportStatus),
        submittedBy: report.userId,
        createdAt: report.submittedAt,
        updatedAt: report.updatedAt,
      );

      // توليد PDF
      final pdfBytes =
          await ProfessionalEgyptianPdfService.generateProfessionalReportPdf(
            reportEntity,
          );

      // إنهاء شاشة التحميل
      Navigator.pop(context);

      // حفظ الملف مؤقتاً
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/report_${report.id.substring(0, 8)}.pdf',
      );
      await file.writeAsBytes(pdfBytes);

      // مشاركة الملف
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'تقرير بلاغ رقم #${report.id.substring(0, 8)}');

      _showSuccessMessage(context, 'تم توليد التقرير بنجاح');
    } catch (e) {
      // إنهاء شاشة التحميل في حالة الخطأ
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في توليد التقرير: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// تحويل حالة الإدارة إلى حالة التقرير
  ReportStatus _convertAdminStatusToReportStatus(AdminReportStatus status) {
    switch (status) {
      case AdminReportStatus.pending:
        return ReportStatus.received;
      case AdminReportStatus.underInvestigation:
        return ReportStatus.underReview;
      case AdminReportStatus.resolved:
        return ReportStatus.completed;
      case AdminReportStatus.closed:
        return ReportStatus.completed;
      case AdminReportStatus.rejected:
        return ReportStatus.rejected;
      case AdminReportStatus.received:
        return ReportStatus.received;
    }
  }

  void _showNotesDialog(
    BuildContext context, {
    required String title,
    required String hintText,
    required Function(String) onSubmit,
  }) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: hintText,
                border: const OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    Navigator.pop(context);
                    onSubmit(controller.text.trim());
                  }
                },
                child: const Text('حفظ'),
              ),
            ],
          ),
    );
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Text(message),
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
}
