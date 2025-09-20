import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../domain/entities/reports_entity.dart';
import '../../../../core/utils/user_data_helper.dart';

/// خدمة إنشاء تقارير PDF احترافية للحكومة المصرية
/// Professional PDF Report Generator Service for Egyptian Government
class ProfessionalEgyptianPdfService {
  static pw.Font? _arabicFont;
  static pw.Font? _arabicBoldFont;
  static pw.MemoryImage? _egyptLogo;
  static pw.MemoryImage? _netruLogo;

  // الألوان الرسمية للحكومة المصرية
  // Official Egyptian Government Colors
  static const _egyptRed = PdfColor.fromInt(0xFFCE1126); // أحمر العلم المصري
  static const _egyptGold = PdfColor.fromInt(0xFFFFD700); // الذهبي
  static const _egyptBlack = PdfColor.fromInt(0xFF000000); // الأسود
  static const _egyptWhite = PdfColor.fromInt(0xFFFFFFFF); // الأبيض
  static const _officialBlue = PdfColor.fromInt(0xFF1B4D72); // الأزرق الرسمي
  static const _darkGray = PdfColor.fromInt(0xFF2C3E50); // رمادي داكن
  static const _lightGray = PdfColor.fromInt(0xFFF8F9FA); // رمادي فاتح

  /// تحميل الخطوط والشعارات مرة واحدة فقط
  static Future<void> _ensureAssetsLoaded() async {
    if (_arabicFont != null &&
        _arabicBoldFont != null &&
        _egyptLogo != null &&
        _netruLogo != null) {
      return;
    }

    try {
      // تحميل الخطوط العربية
      if (_arabicFont == null) {
        final arabicFontData = await rootBundle.load(
          'assets/fonts/Tajawal-Regular.ttf',
        );
        _arabicFont = pw.Font.ttf(arabicFontData);
      }

      if (_arabicBoldFont == null) {
        final arabicBoldFontData = await rootBundle.load(
          'assets/fonts/Tajawal-Bold.ttf',
        );
        _arabicBoldFont = pw.Font.ttf(arabicBoldFontData);
      }

      // تحميل شعار مصر
      if (_egyptLogo == null) {
        try {
          final egyptLogoData = await rootBundle.load(
            'assets/images/egypt.png',
          );
          _egyptLogo = pw.MemoryImage(egyptLogoData.buffer.asUint8List());
          print('✅ تم تحميل شعار مصر بنجاح');
        } catch (e) {
          print('⚠️ خطأ في تحميل شعار مصر: $e');
        }
      }

      // تحميل شعار التطبيق
      if (_netruLogo == null) {
        try {
          final netruLogoData = await rootBundle.load(
            'assets/images/mainLogo.png',
          );
          _netruLogo = pw.MemoryImage(netruLogoData.buffer.asUint8List());
          print('✅ تم تحميل شعار التطبيق بنجاح');
        } catch (e) {
          print('⚠️ خطأ في تحميل شعار التطبيق: $e');
        }
      }
    } catch (e) {
      print('خطأ في تحميل الأصول: $e');
      // استخدام الخط الافتراضي
    }
  }

  /// إنشاء تقرير PDF احترافي
  static Future<Uint8List> generateProfessionalReportPdf(
    ReportEntity report,
  ) async {
    await _ensureAssetsLoaded();

    final pdf = pw.Document(
      title: 'تقرير البلاغ الرسمي - ${report.id.substring(0, 8)}',
      author: 'نظام نترو - جمهورية مصر العربية',
      subject: 'تقرير رسمي للبلاغ',
      keywords: 'بلاغ, تقرير, نترو, مصر',
      creator: 'تطبيق نترو الحكومي',
    );

    // إضافة الصفحة الرئيسية
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        textDirection: pw.TextDirection.rtl,
        theme: _createPdfTheme(),
        header: (context) => _buildOfficialHeader(context),
        footer: (context) => _buildOfficialFooter(context, report),
        build:
            (context) => [
              // معلومات التقرير الأساسية
              _buildReportIdentification(report),
              pw.SizedBox(height: 25),

              // جدول معلومات مقدم البلاغ
              _buildReporterTable(report),
              pw.SizedBox(height: 25),

              // جدول تفاصيل البلاغ
              _buildReportDetailsTable(report),
              pw.SizedBox(height: 25),

              // معلومات الموقع (إن وجدت)
              if (report.locationName != null || report.latitude != null)
                _buildLocationTable(report),

              if (report.locationName != null || report.latitude != null)
                pw.SizedBox(height: 25),

              // جدول حالة البلاغ
              _buildStatusTable(report),
              pw.SizedBox(height: 25),

              // التوقيع الرقمي والختم
              _buildDigitalSignature(report),
            ],
      ),
    );

    return pdf.save();
  }

  /// إنشاء نمط PDF مع الخطوط العربية
  static pw.ThemeData _createPdfTheme() {
    return pw.ThemeData.withFont(
      base: _arabicFont,
      bold: _arabicBoldFont ?? _arabicFont,
    );
  }

  /// بناء الهيدر الرسمي
  static pw.Widget _buildOfficialHeader(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        children: [
          // الشريط العلوي بألوان العلم المصري
          pw.Container(
            height: 8,
            decoration: const pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [_egyptRed, _egyptWhite, _egyptBlack],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          pw.SizedBox(height: 15),

          // الهيدر الرئيسي مع الشعارات
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // شعار مصر - الصورة الحقيقية
              if (_egyptLogo != null)
                pw.Container(
                  width: 60,
                  height: 60,
                  decoration: pw.BoxDecoration(
                    shape: pw.BoxShape.circle,
                    border: pw.Border.all(color: _egyptGold, width: 2),
                  ),
                  child: pw.ClipOval(
                    child: pw.Image(_egyptLogo!, fit: pw.BoxFit.cover),
                  ),
                )
              else
                // احتياطي نصي إذا فشل تحميل الصورة
                pw.Container(
                  width: 60,
                  height: 60,
                  decoration: pw.BoxDecoration(
                    color: _egyptGold,
                    shape: pw.BoxShape.circle,
                    border: pw.Border.all(color: _egyptRed, width: 2),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      '🇪🇬',
                      style: const pw.TextStyle(fontSize: 24),
                    ),
                  ),
                ),

              // العنوان الرئيسي
              pw.Expanded(
                child: pw.Container(
                  margin: const pw.EdgeInsets.symmetric(horizontal: 20),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'جمهورية مصر العربية',
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: _darkGray,
                        ),
                        textAlign: pw.TextAlign.center,
                        textDirection: pw.TextDirection.rtl,
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'نظام نترو الموحد للبلاغات والإبلاغ',
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: _officialBlue,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                        textDirection: pw.TextDirection.rtl,
                      ),
                      pw.SizedBox(height: 3),
                      pw.Container(width: 150, height: 2, color: _egyptGold),
                    ],
                  ),
                ),
              ),

              // شعار نترو - الصورة الحقيقية
              if (_netruLogo != null)
                pw.Container(
                  width: 60,
                  height: 60,

                  child: pw.Center(
                    child: pw.Image(
                      _netruLogo!,
                      width: 70,
                      height: 50,
                      fit: pw.BoxFit.contain,
                    ),
                  ),
                )
              else
                // احتياطي نصي إذا فشل تحميل الصورة
                pw.Container(
                  width: 80,
                  height: 60,
                  decoration: pw.BoxDecoration(
                    color: _officialBlue,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Center(
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text(
                          'NETRU',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: _egyptWhite,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'نترو',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: _egyptGold,
                          ),
                          textDirection: pw.TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          pw.SizedBox(height: 15),

          // خط فاصل
          pw.Container(height: 2, color: _officialBlue),
        ],
      ),
    );
  }

  /// بناء معلومات التقرير الأساسية
  static pw.Widget _buildReportIdentification(ReportEntity report) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: _lightGray,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: _officialBlue, width: 2),
      ),
      padding: const pw.EdgeInsets.all(20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Center(
            child: pw.Text(
              'تقرير البلاغ الرسمي',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: _egyptRed,
              ),
              textDirection: pw.TextDirection.rtl,
            ),
          ),
          pw.SizedBox(height: 15),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: _buildInfoBox(
                  'رقم البلاغ المرجعي',
                  '#${report.id.substring(0, 8).toUpperCase()}',
                  _egyptRed,
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: _buildInfoBox(
                  'تاريخ الإنشاء',
                  _formatArabicDate(report.reportDateTime),
                  _officialBlue,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 15),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: _buildInfoBox(
                  'حالة البلاغ',
                  report.status.arabicName,
                  _getStatusColor(report.status),
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: _buildInfoBox(
                  'نوع البلاغ',
                  report.reportType,
                  _darkGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// بناء صندوق معلومات صغير
  static pw.Widget _buildInfoBox(String label, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _egyptWhite,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: color, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: pw.FontWeight.bold,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              color: _darkGray,
              fontWeight: pw.FontWeight.bold,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  /// بناء جدول معلومات مقدم البلاغ
  static pw.Widget _buildReporterTable(ReportEntity report) {
    // الحصول على بيانات المستخدم الحقيقية
    final userHelper = UserDataHelper();
    final currentUser = userHelper.getCurrentUser();

    return _buildOfficialTable(
      title: 'بيانات مقدم البلاغ',
      icon: '●',
      data: [
        [
          'الاسم الكامل',
          currentUser?.fullName ?? '${report.firstName} ${report.lastName}',
        ],
        [
          'رقم الهوية الوطنية',
          currentUser?.nationalId ??
              userHelper.getUserNationalId() ??
              report.nationalId,
        ],
        [
          'رقم الهاتف',
          currentUser?.phone ?? userHelper.getUserPhone() ?? report.phone,
        ],
        [
          'العنوان',
          currentUser?.address ?? userHelper.getUserAddress() ?? 'غير محدد',
        ],
        ['تاريخ تقديم البلاغ', _formatArabicDate(report.reportDateTime)],
      ],
    );
  }

  /// بناء جدول تفاصيل البلاغ
  static pw.Widget _buildReportDetailsTable(ReportEntity report) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('تفاصيل البلاغ والوصف', '✎'),
        pw.SizedBox(height: 10),

        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: _egyptWhite,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: _officialBlue, width: 1),
          ),
          child: pw.Text(
            report.reportDetails,
            style: const pw.TextStyle(
              fontSize: 12,
              height: 1.8,
              color: _darkGray,
            ),
            textDirection: pw.TextDirection.rtl,
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );
  }

  /// بناء جدول معلومات الموقع
  static pw.Widget _buildLocationTable(ReportEntity report) {
    List<List<String>> locationData = [];

    if (report.locationName != null) {
      locationData.add(['اسم الموقع', report.locationName!]);
    }

    if (report.latitude != null && report.longitude != null) {
      locationData.add(['خط العرض', report.latitude!.toStringAsFixed(6)]);
      locationData.add(['خط الطول', report.longitude!.toStringAsFixed(6)]);
      locationData.add([
        'الإحداثيات المختصرة',
        '${report.latitude!.toStringAsFixed(4)}, ${report.longitude!.toStringAsFixed(4)}',
      ]);
    }

    return _buildOfficialTable(
      title: 'معلومات الموقع الجغرافي',
      icon: '⬤',
      data: locationData,
    );
  }

  /// بناء جدول حالة البلاغ
  static pw.Widget _buildStatusTable(ReportEntity report) {
    return _buildOfficialTable(
      title: 'معلومات حالة البلاغ',
      icon: '≡',
      data: [
        ['الحالة الحالية', report.status.arabicName],
        ['تاريخ آخر تحديث', _formatArabicDate(report.updatedAt)],
        ['تاريخ الإنشاء', _formatArabicDate(report.createdAt)],
        [
          'مدة المعالجة',
          _calculateProcessingDuration(report.createdAt, report.updatedAt),
        ],
      ],
    );
  }

  /// بناء جدول رسمي موحد
  static pw.Widget _buildOfficialTable({
    required String title,
    required String icon,
    required List<List<String>> data,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title, icon),
        pw.SizedBox(height: 10),

        pw.Table(
          border: pw.TableBorder.all(color: _officialBlue, width: 1),
          columnWidths: {
            0: const pw.FlexColumnWidth(4),
            1: const pw.FlexColumnWidth(2),
          },
          children:
              data
                  .map(
                    (row) => pw.TableRow(
                      decoration: const pw.BoxDecoration(color: _egyptWhite),
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(12),
                          child: pw.Text(
                            row[1],
                            style: const pw.TextStyle(
                              fontSize: 11,
                              color: _darkGray,
                            ),
                            textDirection: pw.TextDirection.rtl,
                            textAlign: pw.TextAlign.right,
                          ),
                        ),

                        pw.Container(
                          padding: const pw.EdgeInsets.all(12),
                          decoration: const pw.BoxDecoration(color: _lightGray),
                          child: pw.Text(
                            row[0],
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: _darkGray,
                            ),
                            textDirection: pw.TextDirection.rtl,
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  /// بناء عنوان القسم
  static pw.Widget _buildSectionHeader(String title, String icon) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: pw.BoxDecoration(
        color: _officialBlue,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        children: [
          pw.Text(icon, style: const pw.TextStyle(fontSize: 16)),
          pw.SizedBox(width: 10),
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: _egyptWhite,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  /// بناء التوقيع الرقمي والختم
  static pw.Widget _buildDigitalSignature(ReportEntity report) {
    final now = DateTime.now();
    final reportCode =
        'NTR-${now.year}-${report.id.substring(0, 8).toUpperCase()}';

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 30),
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _egyptGold, width: 3),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        children: [
          // الختم الرقمي
          pw.Container(
            width: 120,
            height: 120,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              border: pw.Border.all(color: _egyptRed, width: 3),
              color: _lightGray,
            ),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'ختم إلكتروني',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: _egyptRed,
                  ),
                  textDirection: pw.TextDirection.rtl,
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'نترو',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: _officialBlue,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  _formatArabicDate(now),
                  style: const pw.TextStyle(fontSize: 8, color: _darkGray),
                  textDirection: pw.TextDirection.rtl,
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // معلومات التوقيع
          pw.Text(
            'هذا المستند مُصدق إلكترونياً من نظام نترو الحكومي',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: _darkGray,
            ),
            textDirection: pw.TextDirection.rtl,
            textAlign: pw.TextAlign.center,
          ),

          pw.SizedBox(height: 10),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'كود التحقق: $reportCode',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: _egyptRed,
                  fontWeight: pw.FontWeight.bold,
                ),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.Text(
                'تاريخ الإصدار: ${_formatArabicDate(now)}',
                style: const pw.TextStyle(fontSize: 10, color: _darkGray),
                textDirection: pw.TextDirection.rtl,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// بناء التذييل الرسمي
  static pw.Widget _buildOfficialFooter(
    pw.Context context,
    ReportEntity report,
  ) {
    // الحصول على بيانات المستخدم
    final userHelper = UserDataHelper();
    final currentUser = userHelper.getCurrentUser();

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      padding: const pw.EdgeInsets.symmetric(vertical: 15),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _officialBlue, width: 2)),
      ),
      child: pw.Column(
        children: [
          // الشريط السفلي بألوان العلم
          pw.Container(
            height: 6,
            decoration: const pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [_egyptRed, _egyptWhite, _egyptBlack],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          pw.SizedBox(height: 10),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'نظام نترو - جمهورية مصر العربية',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: _darkGray,
                    ),
                    textDirection: pw.TextDirection.rtl,
                  ),
                  pw.Text(
                    'هاتف: 16000 | البريد: info@netru.gov.eg',
                    style: const pw.TextStyle(fontSize: 8, color: _darkGray),
                    textDirection: pw.TextDirection.rtl,
                  ),
                  if (currentUser?.fullName != null)
                    pw.Text(
                      'مقدم البلاغ: ${currentUser!.fullName}',
                      style: const pw.TextStyle(fontSize: 8, color: _darkGray),
                      textDirection: pw.TextDirection.rtl,
                    ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'صفحة ${context.pageNumber} من ${context.pagesCount}',
                    style: const pw.TextStyle(fontSize: 10, color: _darkGray),
                    textDirection: pw.TextDirection.rtl,
                  ),
                  pw.Text(
                    'تم الإنشاء: ${_formatArabicDate(DateTime.now())}',
                    style: const pw.TextStyle(fontSize: 8, color: _darkGray),
                    textDirection: pw.TextDirection.rtl,
                  ),
                  if (currentUser?.nationalId != null)
                    pw.Text(
                      'هوية المبلغ: ${currentUser!.nationalId}',
                      style: const pw.TextStyle(fontSize: 8, color: _darkGray),
                      textDirection: pw.TextDirection.rtl,
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // دوال مساعدة

  /// تنسيق التاريخ بالعربية
  static String _formatArabicDate(DateTime date) {
    try {
      return DateFormat('dd/MM/yyyy - HH:mm', 'ar').format(date);
    } catch (e) {
      return DateFormat('dd/MM/yyyy - HH:mm').format(date);
    }
  }

  /// حساب مدة المعالجة
  static String _calculateProcessingDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);

    if (duration.inDays > 0) {
      return '${duration.inDays} يوم';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} ساعة';
    } else {
      return '${duration.inMinutes} دقيقة';
    }
  }

  /// الحصول على لون الحالة
  static PdfColor _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.received:
        return _officialBlue;
      case ReportStatus.underReview:
        return const PdfColor.fromInt(0xFFFF8C00);
      case ReportStatus.dataVerification:
        return const PdfColor.fromInt(0xFFFFD700);
      case ReportStatus.actionTaken:
        return const PdfColor.fromInt(0xFF1E90FF);
      case ReportStatus.completed:
        return const PdfColor.fromInt(0xFF32CD32);
      case ReportStatus.rejected:
        return _egyptRed;
    }
  }
}
