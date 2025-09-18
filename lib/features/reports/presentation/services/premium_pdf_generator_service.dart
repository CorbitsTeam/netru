import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import '../../domain/entities/reports_entity.dart';

class PremiumPdfGeneratorService {
  static pw.Font? _arabicFont;
  static pw.Font? _englishFont;
  static pw.Font? _boldArabicFont;
  static pw.Font? _boldEnglishFont;
  static bool _fontsLoaded = false;

  // Egyptian Official Colors
  static final egyptianRed = PdfColor.fromHex('#CE1126');
  static final egyptianGold = PdfColor.fromHex('#FFD700');
  static final ministryBlue = PdfColor.fromHex('#1B4D72');
  static final ministryNavy = PdfColor.fromHex('#0F2A44');
  static final officialGreen = PdfColor.fromHex('#228B22');
  static final documentWhite = PdfColor.fromHex('#FFFFFF');
  static final documentGray = PdfColor.fromHex('#F8F9FA');
  static final borderGray = PdfColor.fromHex('#E9ECEF');
  static final textDark = PdfColor.fromHex('#212529');
  static final textMuted = PdfColor.fromHex('#6C757D');

  // Load fonts with comprehensive fallback for Arabic support
  static Future<void> _loadFonts() async {
    if (_fontsLoaded) return;

    try {
      // Try local fonts first (best Arabic support)
      final arabicFontData = await rootBundle.load(
        'assets/fonts/Cairo-Regular.ttf',
      );
      final boldArabicFontData = await rootBundle.load(
        'assets/fonts/Cairo-Bold.ttf',
      );
      _arabicFont = pw.Font.ttf(arabicFontData);
      _boldArabicFont = pw.Font.ttf(boldArabicFontData);
      _englishFont = await PdfGoogleFonts.robotoRegular();
      _boldEnglishFont = await PdfGoogleFonts.robotoBold();
      _fontsLoaded = true;
      print('Cairo fonts loaded successfully - Full Arabic support');
    } catch (e) {
      try {
        // Fallback to Google Fonts with better Arabic support
        _arabicFont = await PdfGoogleFonts.notoSansArabicRegular();
        _boldArabicFont = await PdfGoogleFonts.notoSansArabicBold();
        _englishFont = await PdfGoogleFonts.notoSansRegular();
        _boldEnglishFont = await PdfGoogleFonts.notoSansBold();
        _fontsLoaded = true;
        print('Noto Sans Arabic fonts loaded successfully');
      } catch (e2) {
        // Ultimate fallback
        _arabicFont = await PdfGoogleFonts.cairoRegular();
        _boldArabicFont = await PdfGoogleFonts.cairoBold();
        _englishFont = await PdfGoogleFonts.robotoRegular();
        _boldEnglishFont = await PdfGoogleFonts.robotoBold();
        _fontsLoaded = true;
        print('Cairo Google fonts loaded as ultimate fallback');
      }
    }
  }

  static Future<pw.Document> generatePremiumReport(ReportEntity report) async {
    await _loadFonts();

    final doc = pw.Document();

    // Enhanced text styles
    final arabicHeaderStyle = pw.TextStyle(
      font: _boldArabicFont,
      fontSize: 18,
      color: documentWhite,
      fontWeight: pw.FontWeight.bold,
      fontFallback: [
        _boldArabicFont!,
        _arabicFont!,
        _boldEnglishFont!,
        _englishFont!,
      ],
    );

    final arabicTitleStyle = pw.TextStyle(
      font: _boldArabicFont,
      fontSize: 16,
      color: ministryNavy,
      fontWeight: pw.FontWeight.bold,
      fontFallback: [
        _boldArabicFont!,
        _arabicFont!,
        _boldEnglishFont!,
        _englishFont!,
      ],
    );

    final arabicBodyStyle = pw.TextStyle(
      font: _arabicFont,
      fontSize: 12,
      color: textDark,
      lineSpacing: 1.5,
      fontFallback: [
        _arabicFont!,
        _boldArabicFont!,
        _englishFont!,
        _boldEnglishFont!,
      ],
    );

    final englishHeaderStyle = pw.TextStyle(
      font: _boldEnglishFont,
      fontSize: 20,
      color: documentWhite,
      fontWeight: pw.FontWeight.bold,
      letterSpacing: 1.2,
      fontFallback: [
        _boldEnglishFont!,
        _englishFont!,
        _boldArabicFont!,
        _arabicFont!,
      ],
    );

    final englishBodyStyle = pw.TextStyle(
      font: _englishFont,
      fontSize: 11,
      color: textDark,
      fontFallback: [
        _englishFont!,
        _boldEnglishFont!,
        _arabicFont!,
        _boldArabicFont!,
      ],
    );

    final smallTextStyle = pw.TextStyle(
      font: _arabicFont,
      fontSize: 10,
      color: textMuted,
      fontFallback: [
        _arabicFont!,
        _boldArabicFont!,
        _englishFont!,
        _boldEnglishFont!,
      ],
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(15),
        textDirection: pw.TextDirection.rtl,
        build:
            (context) => [
              _buildOfficialHeader(
                report,
                arabicHeaderStyle,
                englishHeaderStyle,
              ),
              pw.SizedBox(height: 25),
              _buildReportSummary(report, arabicTitleStyle, arabicBodyStyle),
              pw.SizedBox(height: 20),
              _buildReporterInfo(
                report,
                arabicTitleStyle,
                arabicBodyStyle,
                englishBodyStyle,
              ),
              pw.SizedBox(height: 20),
              _buildIncidentDetails(report, arabicTitleStyle, arabicBodyStyle),
              pw.SizedBox(height: 20),
              _buildLocationInfo(
                report,
                arabicTitleStyle,
                arabicBodyStyle,
                englishBodyStyle,
              ),
              pw.SizedBox(height: 20),
              _buildStatusTimeline(report, arabicTitleStyle, arabicBodyStyle),
              pw.SizedBox(height: 30),
            ],
        footer:
            (context) => _buildOfficialFooter(smallTextStyle, englishBodyStyle),
      ),
    );

    return doc;
  }

  static pw.Widget _buildOfficialHeader(
    ReportEntity report,
    pw.TextStyle arabicHeaderStyle,
    pw.TextStyle englishHeaderStyle,
  ) {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [ministryNavy, ministryBlue],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        children: [
          // Header top section with flags and logos
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // Egyptian flag representation
                pw.Container(
                  width: 60,
                  height: 40,
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(4),
                    border: pw.Border.all(color: egyptianGold, width: 2),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Expanded(child: pw.Container(color: egyptianRed)),
                      pw.Expanded(child: pw.Container(color: documentWhite)),
                      pw.Expanded(child: pw.Container(color: PdfColors.black)),
                    ],
                  ),
                ),

                // Center official text
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'جمهورية مصر العربية',
                        style: arabicHeaderStyle.copyWith(fontSize: 16),
                        textDirection: pw.TextDirection.rtl,
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'وزارة الداخلية',
                        style: arabicHeaderStyle.copyWith(fontSize: 14),
                        textDirection: pw.TextDirection.rtl,
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'MINISTRY OF INTERIOR',
                        style: englishHeaderStyle.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // Ministry logo representation
                pw.Container(
                  width: 50,
                  height: 50,
                  decoration: pw.BoxDecoration(
                    shape: pw.BoxShape.circle,
                    gradient: pw.RadialGradient(
                      colors: [egyptianGold, PdfColor.fromHex('#B8860B')],
                    ),
                    border: pw.Border.all(color: documentWhite, width: 2),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      '★',
                      style: pw.TextStyle(
                        font: _englishFont,
                        fontSize: 20,
                        color: ministryNavy,
                        fontFallback: [
                          _englishFont!,
                          _boldEnglishFont!,
                          _arabicFont!,
                          _boldArabicFont!,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Separator line
          pw.Container(
            height: 1,
            margin: const pw.EdgeInsets.symmetric(horizontal: 20),
            color: egyptianGold,
          ),

          // Report title section
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              children: [
                pw.Text('OFFICIAL INCIDENT REPORT', style: englishHeaderStyle),
                pw.SizedBox(height: 8),
                pw.Text(
                  'بلاغ رسمي للحوادث',
                  style: arabicHeaderStyle,
                  textDirection: pw.TextDirection.rtl,
                ),
                pw.SizedBox(height: 15),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  decoration: pw.BoxDecoration(
                    color: egyptianGold,
                    borderRadius: pw.BorderRadius.circular(20),
                  ),
                  child: pw.Text(
                    'رقم البلاغ: ${report.id.substring(0, 12).toUpperCase()}',
                    style: pw.TextStyle(
                      font: _boldArabicFont,
                      fontSize: 14,
                      color: ministryNavy,
                      fontWeight: pw.FontWeight.bold,
                      fontFallback: [
                        _boldArabicFont!,
                        _arabicFont!,
                        _boldEnglishFont!,
                        _englishFont!,
                      ],
                    ),
                    textDirection: pw.TextDirection.rtl,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildReportSummary(
    ReportEntity report,
    pw.TextStyle titleStyle,
    pw.TextStyle bodyStyle,
  ) {
    return _buildSection('ملخص البلاغ', 'REPORT SUMMARY', ministryBlue, [
      _buildDetailRow('نوع البلاغ:', report.reportType, bodyStyle),
      _buildDetailRow(
        'تاريخ الحادث:',
        _formatArabicDate(report.reportDateTime),
        bodyStyle,
      ),
      _buildDetailRow('حالة البلاغ:', report.status.arabicName, bodyStyle),
      _buildDetailRow(
        'تاريخ التقديم:',
        _formatArabicDate(report.createdAt),
        bodyStyle,
      ),
    ]);
  }

  static pw.Widget _buildReporterInfo(
    ReportEntity report,
    pw.TextStyle titleStyle,
    pw.TextStyle bodyStyle,
    pw.TextStyle englishStyle,
  ) {
    return _buildSection(
      'بيانات مقدم البلاغ',
      'REPORTER INFORMATION',
      officialGreen,
      [
        _buildDetailRow(
          'الاسم الكامل:',
          '${report.firstName} ${report.lastName}',
          bodyStyle,
        ),
        _buildDetailRow('رقم الهوية الوطنية:', report.nationalId, bodyStyle),
        _buildDetailRow('رقم الهاتف:', report.phone, bodyStyle),
        if (report.submittedBy != null)
          _buildDetailRow('معرف المستخدم:', report.submittedBy!, englishStyle),
      ],
    );
  }

  static pw.Widget _buildIncidentDetails(
    ReportEntity report,
    pw.TextStyle titleStyle,
    pw.TextStyle bodyStyle,
  ) {
    return _buildSection('تفاصيل الحادث', 'INCIDENT DETAILS', egyptianRed, [
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(15),
        decoration: pw.BoxDecoration(
          color: documentGray,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: borderGray),
        ),
        child: pw.Text(
          report.reportDetails,
          style: bodyStyle.copyWith(lineSpacing: 1.8),
          textDirection: pw.TextDirection.rtl,
          textAlign: pw.TextAlign.justify,
        ),
      ),
    ]);
  }

  static pw.Widget _buildLocationInfo(
    ReportEntity report,
    pw.TextStyle titleStyle,
    pw.TextStyle bodyStyle,
    pw.TextStyle englishStyle,
  ) {
    if (report.latitude == null || report.longitude == null) {
      return pw.Container();
    }

    return _buildSection(
      'موقع الحادث',
      'INCIDENT LOCATION',
      PdfColor.fromHex('#FF8C00'),
      [
        if (report.locationName != null)
          _buildDetailRow('العنوان:', report.locationName!, bodyStyle),
        _buildDetailRow(
          'خط العرض:',
          report.latitude!.toStringAsFixed(6),
          englishStyle,
        ),
        _buildDetailRow(
          'خط الطول:',
          report.longitude!.toStringAsFixed(6),
          englishStyle,
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#FFF8DC'),
            borderRadius: pw.BorderRadius.circular(6),
            border: pw.Border.all(color: PdfColor.fromHex('#DDD')),
          ),
          child: pw.Text(
            'يمكن عرض الموقع الدقيق باستخدام الإحداثيات المرفقة على خرائط جوجل أو أي نظام ملاحة GPS',
            style: bodyStyle.copyWith(fontSize: 10, color: textMuted),
            textDirection: pw.TextDirection.rtl,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildStatusTimeline(
    ReportEntity report,
    pw.TextStyle titleStyle,
    pw.TextStyle bodyStyle,
  ) {
    return _buildSection(
      'تتبع حالة البلاغ',
      'STATUS TIMELINE',
      PdfColor.fromHex('#9C27B0'),
      [
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            gradient: pw.LinearGradient(
              colors: [
                PdfColor.fromHex('#F3E5F5'),
                PdfColor.fromHex('#E1BEE7'),
              ],
              begin: pw.Alignment.topLeft,
              end: pw.Alignment.bottomRight,
            ),
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildStatusItem(
                'تم استلام البلاغ',
                report.createdAt,
                true,
                bodyStyle,
              ),
              _buildStatusItem(
                'قيد المراجعة',
                report.updatedAt,
                [
                  ReportStatus.underReview,
                  ReportStatus.dataVerification,
                  ReportStatus.actionTaken,
                  ReportStatus.completed,
                ].contains(report.status),
                bodyStyle,
              ),
              _buildStatusItem(
                'اتخاذ الإجراء المناسب',
                report.updatedAt,
                [
                  ReportStatus.actionTaken,
                  ReportStatus.completed,
                ].contains(report.status),
                bodyStyle,
              ),
              _buildStatusItem(
                'مكتمل',
                report.updatedAt,
                report.status == ReportStatus.completed,
                bodyStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildStatusItem(
    String title,
    DateTime date,
    bool isCompleted,
    pw.TextStyle bodyStyle,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        children: [
          pw.Container(
            width: 12,
            height: 12,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              color: isCompleted ? officialGreen : borderGray,
              border: pw.Border.all(
                color: isCompleted ? officialGreen : textMuted,
                width: 2,
              ),
            ),
            child:
                isCompleted
                    ? pw.Center(
                      child: pw.Container(
                        width: 6,
                        height: 6,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          color: documentWhite,
                        ),
                      ),
                    )
                    : null,
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  title,
                  style: bodyStyle.copyWith(
                    fontWeight:
                        isCompleted ? pw.FontWeight.bold : pw.FontWeight.normal,
                    color: isCompleted ? textDark : textMuted,
                  ),
                  textDirection: pw.TextDirection.rtl,
                ),
                if (isCompleted)
                  pw.Text(
                    _formatTime(date),
                    style: bodyStyle.copyWith(fontSize: 9, color: textMuted),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSection(
    String arabicTitle,
    String englishTitle,
    PdfColor accentColor,
    List<pw.Widget> children,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          decoration: pw.BoxDecoration(
            gradient: pw.LinearGradient(
              colors: [accentColor, accentColor.shade(0.8)],
              begin: pw.Alignment.centerLeft,
              end: pw.Alignment.centerRight,
            ),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                englishTitle,
                style: pw.TextStyle(
                  font: _boldEnglishFont,
                  fontSize: 12,
                  color: documentWhite,
                  fontWeight: pw.FontWeight.bold,
                  fontFallback: [
                    _boldEnglishFont!,
                    _englishFont!,
                    _boldArabicFont!,
                    _arabicFont!,
                  ],
                ),
              ),
              pw.Text(
                arabicTitle,
                style: pw.TextStyle(
                  font: _boldArabicFont,
                  fontSize: 14,
                  color: documentWhite,
                  fontWeight: pw.FontWeight.bold,
                  fontFallback: [
                    _boldArabicFont!,
                    _arabicFont!,
                    _boldEnglishFont!,
                    _englishFont!,
                  ],
                ),
                textDirection: pw.TextDirection.rtl,
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: documentWhite,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: borderGray),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildDetailRow(
    String label,
    String value,
    pw.TextStyle style,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 120,
            child: pw.Text(
              label,
              style: style.copyWith(
                fontWeight: pw.FontWeight.bold,
                color: ministryNavy,
              ),
              textDirection: pw.TextDirection.rtl,
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Text(
              value,
              style: style,
              textDirection: pw.TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildOfficialFooter(
    pw.TextStyle smallStyle,
    pw.TextStyle englishStyle,
  ) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [ministryNavy, ministryBlue],
          begin: pw.Alignment.centerLeft,
          end: pw.Alignment.centerRight,
        ),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Generated by Netru System',
                style: englishStyle.copyWith(color: egyptianGold, fontSize: 10),
              ),
              pw.Text(
                'تم إنشاؤه بواسطة نظام نترو',
                style: smallStyle.copyWith(color: egyptianGold),
                textDirection: pw.TextDirection.rtl,
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Container(height: 1, color: egyptianGold),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Ministry of Interior - Arab Republic of Egypt',
                style: englishStyle.copyWith(color: documentWhite, fontSize: 9),
              ),
              pw.Text(
                _formatArabicDate(DateTime.now()),
                style: smallStyle.copyWith(color: documentWhite, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods
  static String _formatArabicDate(DateTime dateTime) {
    try {
      final arabicFormatter = DateFormat('dd/MM/yyyy - HH:mm', 'ar');
      return arabicFormatter.format(dateTime);
    } catch (e) {
      return DateFormat('dd/MM/yyyy - HH:mm').format(dateTime);
    }
  }

  static String _formatTime(DateTime dateTime) {
    try {
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return dateTime.toString().substring(11, 16);
    }
  }

  // Compatibility method to replace original service
  static Future<pw.Document> generateReport(ReportEntity report) async {
    return generatePremiumReport(report);
  }
}
