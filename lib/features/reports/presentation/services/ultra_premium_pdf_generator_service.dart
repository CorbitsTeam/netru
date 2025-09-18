import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../domain/entities/reports_entity.dart';

class UltraPremiumPdfGeneratorService {
  static pw.Font? _arabicFont;
  static pw.Font? _englishFont;
  static bool _fontsLoaded = false;

  // تحميل خط بسيط ومضمون - بدون تعقيدات
  static Future<void> _loadFonts() async {
    if (_fontsLoaded) return;

    try {
      _arabicFont = await PdfGoogleFonts.notoSansArabicRegular();
      _englishFont = await PdfGoogleFonts.robotoRegular();
      _fontsLoaded = true;
      print('تم تحميل الخط بنجاح');
    } catch (e) {
      // في حالة فشل تحميل الخط العربي، استخدم خط افتراضي
      _arabicFont = await PdfGoogleFonts.robotoRegular();
      _englishFont = await PdfGoogleFonts.robotoRegular();
      _fontsLoaded = true;
      print('تم تحميل خط افتراضي');
    }
  }

  // دالة بسيطة جداً لإنشاء PDF
  static Future<pw.Document> generateFullArabicReport(
    ReportEntity report,
  ) async {
    await _loadFonts();

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build:
            (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // عنوان بسيط
                pw.Container(
                  width: double.infinity,
                  padding: pw.EdgeInsets.all(15),
                  color: PdfColor.fromHex('#1B4D72'),
                  child: pw.Text(
                    'تقرير البلاغ - ${report.id.substring(0, 8)}',
                    style: pw.TextStyle(
                      font: _arabicFont,
                      fontSize: 16,
                      color: PdfColors.white,
                      fontFallback: [_arabicFont!, _englishFont!],
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),

                pw.SizedBox(height: 20),

                // البيانات الأساسية
                pw.Text(
                  'نوع البلاغ: ${report.reportType}',
                  style: pw.TextStyle(
                    font: _arabicFont,
                    fontSize: 12,
                    fontFallback: [_arabicFont!, _englishFont!],
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'الاسم: ${report.firstName} ${report.lastName}',
                  style: pw.TextStyle(
                    font: _arabicFont,
                    fontSize: 12,
                    fontFallback: [_arabicFont!, _englishFont!],
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'رقم الهوية: ${report.nationalId}',
                  style: pw.TextStyle(
                    font: _arabicFont,
                    fontSize: 12,
                    fontFallback: [_arabicFont!, _englishFont!],
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'رقم الهاتف: ${report.phone}',
                  style: pw.TextStyle(
                    font: _arabicFont,
                    fontSize: 12,
                    fontFallback: [_arabicFont!, _englishFont!],
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'الحالة: ${report.status.arabicName}',
                  style: pw.TextStyle(
                    font: _arabicFont,
                    fontSize: 12,
                    fontFallback: [_arabicFont!, _englishFont!],
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'التاريخ: ${DateFormat('dd/MM/yyyy').format(report.reportDateTime)}',
                  style: pw.TextStyle(
                    font: _arabicFont,
                    fontSize: 12,
                    fontFallback: [_arabicFont!, _englishFont!],
                  ),
                ),

                pw.SizedBox(height: 20),

                // تفاصيل البلاغ
                pw.Text(
                  'تفاصيل البلاغ:',
                  style: pw.TextStyle(
                    font: _arabicFont,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    fontFallback: [_arabicFont!, _englishFont!],
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  width: double.infinity,
                  padding: pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(border: pw.Border.all()),
                  child: pw.Text(
                    report.reportDetails,
                    style: pw.TextStyle(
                      font: _arabicFont,
                      fontSize: 11,
                      fontFallback: [_arabicFont!, _englishFont!],
                    ),
                  ),
                ),

                pw.Spacer(),

                // تذييل
                pw.Center(
                  child: pw.Text(
                    'تم إنشاؤه بواسطة نظام نترو',
                    style: pw.TextStyle(
                      font: _arabicFont,
                      fontSize: 10,
                      color: PdfColors.grey,
                      fontFallback: [_arabicFont!, _englishFont!],
                    ),
                  ),
                ),
              ],
            ),
      ),
    );

    return doc;
  }

  // دوال التوافق
  static Future<pw.Document> generateReport(ReportEntity report) async {
    return generateFullArabicReport(report);
  }

  static Future<pw.Document> generatePremiumReport(ReportEntity report) async {
    return generateFullArabicReport(report);
  }
}
