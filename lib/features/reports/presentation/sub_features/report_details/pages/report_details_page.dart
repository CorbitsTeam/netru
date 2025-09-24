import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../widgets/enhanced_status_tracker.dart';
import '../../../widgets/location_info_card.dart';
import '../../../widgets/report_media_viewer.dart';
import '../../../services/professional_egyptian_pdf_service.dart';
import '../../../../domain/entities/reports_entity.dart';
import '../widgets/report_details_app_bar.dart';
import '../widgets/report_details_action_menu.dart';
import '../widgets/report_header_card.dart';
import '../widgets/reporter_info_card.dart';
import '../widgets/report_details_card.dart';
import '../widgets/share_options_dialog.dart';

class ReportDetailsPage extends StatelessWidget {
  final ReportEntity? report;

  const ReportDetailsPage({super.key, this.report});

  @override
  Widget build(BuildContext context) {
    if (report == null) {
      return _buildErrorState(context);
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const ReportDetailsAppBar(),
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
                ReportHeaderCard(report: report!),
                SizedBox(height: 20.h),
                ReporterInfoCard(report: report!),
                SizedBox(height: 20.h),
                ReportDetailsCard(report: report!),
                SizedBox(height: 20.h),
                if (report!.latitude != null && report!.longitude != null)
                  LocationInfoCard(
                    latitude: report!.latitude!,
                    longitude: report!.longitude!,
                    locationName: report!.locationName,
                  ),
                if (report!.latitude != null && report!.longitude != null)
                  SizedBox(height: 20.h),
                if (report!.mediaUrl != null && report!.mediaUrl!.isNotEmpty)
                  ReportMediaViewer(
                    mediaUrl: report!.mediaUrl,
                    mediaType: report!.mediaType,
                  ),
                if (report!.mediaUrl != null && report!.mediaUrl!.isNotEmpty)
                  SizedBox(height: 20.h),
                EnhancedStatusTracker(
                  currentStatus: report!.status,
                  createdAt: report!.createdAt,
                  reportId: report!.id,
                ),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: ReportDetailsActionMenu(
        onShare: () => _shareReport(context),
        onDownloadPdf: () => _downloadPDF(context, report),
        onRefreshStatus: () => _refreshStatus(context),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'تفاصيل البلاغ',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(14.w),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.1),
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

  Future<void> _safePopDialog(BuildContext context) async {
    if (!context.mounted) return;
    try {
      if (Navigator.canPop(context)) Navigator.pop(context);
    } catch (_) {
      // ignore any pop errors
    }
  }

  void _shareReport(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final result = await ShareOptionsDialog.show(context);
      if (result == null) return;

      if (result == 'text') {
        await _shareAsText();
      } else if (result == 'pdf') {
        context.mounted ? await _shareAsPDF(context) : null;
      }

      messenger.showSnackBar(
        const SnackBar(
          content: Text('تم مشاركة البلاغ بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('فشلت مشاركة البلاغ'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    if (report == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                SizedBox(height: 16.h),
                const Text('جاري إنشاء ملف PDF...'),
              ],
            ),
          ),
    );

    try {
      final pdfBytes =
          await ProfessionalEgyptianPdfService.generateProfessionalReportPdf(
            report!,
          );

      if (context.mounted) {
        await _safePopDialog(context);
        await Share.shareXFiles([
          XFile.fromData(
            pdfBytes,
            name: 'تقرير_البلاغ_${report!.id.substring(0, 8)}.pdf',
            mimeType: 'application/pdf',
          ),
        ], subject: 'تقرير البلاغ رقم #${report!.id.substring(0, 8)}');
      }
    } catch (e) {
      if (context.mounted) {
        await _safePopDialog(context);
        await _shareAsText();
      }
    }
  }

  void _downloadPDF(BuildContext context, ReportEntity? report) async {
    if (report == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا توجد بيانات للبلاغ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                SizedBox(height: 16.h),
                const Text('جاري تحميل الملف...'),
              ],
            ),
          ),
    );

    try {
      final pdfBytes =
          await ProfessionalEgyptianPdfService.generateProfessionalReportPdf(
            report,
          );

      if (context.mounted) {
        await _safePopDialog(context);
      }

      final tempDir = await getTemporaryDirectory();
      final fileName = 'تقرير_البلاغ_${report.id.substring(0, 8)}.pdf';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      final result = await OpenFile.open(file.path);

      if (context.mounted) {
        if (result.type == ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم فتح الملف بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        await _safePopDialog(context);
        context.mounted
            ? ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('فشل في تحميل الملف'),
                backgroundColor: Colors.red,
              ),
            )
            : null;
      }
    }
  }

  void _refreshStatus(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: 16.h),
                  const Text('جاري تحديث الحالة...'),
                ],
              ),
            ),
      );

      await Future.delayed(const Duration(seconds: 2));

      context.mounted ? Navigator.pop(context) : null;

      context.mounted
          ? Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ReportDetailsPage(report: report),
            ),
          )
          : null;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('تم تحديث حالة البلاغ بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      try {
        context.mounted ? Navigator.pop(context) : null;
      } catch (_) {}

      messenger.showSnackBar(
        const SnackBar(
          content: Text('فشل في تحديث حالة البلاغ'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
