// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:intl/intl.dart';
// import 'package:flutter/services.dart';
// import 'package:printing/printing.dart';
// import '../../domain/entities/reports_entity.dart';

// class PdfGeneratorService {
//   static pw.Font? _arabicFont;
//   static pw.Font? _englishFont;
//   static pw.Font? _boldArabicFont;
//   static pw.Font? _boldEnglishFont;
//   static bool _fontsLoaded = false;
//   static pw.ImageProvider? _egyptFlag;
//   static pw.ImageProvider? _ministryLogo;
//   static bool _imagesLoaded = false;

//   // Egyptian Ministry colors
//   static final egyptianRed = PdfColor.fromHex('#CE1126');
//   static final egyptianGold = PdfColor.fromHex('#FFD700');
//   static final ministryBlue = PdfColor.fromHex('#1B4D72');
//   static final ministryNavy = PdfColor.fromHex('#0F2A44');
//   static final officialGreen = PdfColor.fromHex('#228B22');
//   static final documentGray = PdfColor.fromHex('#F8F9FA');
//   static final borderGray = PdfColor.fromHex('#E9ECEF');

//   // Load fonts and images with proper error handling
//   static Future<void> _loadAssets() async {
//     if (_fontsLoaded && _imagesLoaded) return;

//     // Load fonts
//     try {
//       _arabicFont = await PdfGoogleFonts.amiriRegular();
//       _englishFont = await PdfGoogleFonts.robotoRegular();
//       _boldArabicFont = await PdfGoogleFonts.amiriBold();
//       _boldEnglishFont = await PdfGoogleFonts.robotoBold();
//       _fontsLoaded = true;
//       print('Google Fonts loaded successfully');
//     } catch (e) {
//       print('Failed to load Google Fonts: $e');
//       try {
//         final arabicFontData = await rootBundle.load(
//           'assets/fonts/Cairo-Regular.ttf',
//         );
//         final boldArabicFontData = await rootBundle.load(
//           'assets/fonts/Cairo-Bold.ttf',
//         );
//         _arabicFont = pw.Font.ttf(arabicFontData);
//         _boldArabicFont = pw.Font.ttf(boldArabicFontData);
//         _englishFont = await PdfGoogleFonts.robotoRegular();
//         _boldEnglishFont = await PdfGoogleFonts.robotoBold();
//         _fontsLoaded = true;
//         print('Asset fonts loaded successfully');
//       } catch (e2) {
//         print('Failed to load asset fonts: $e2');
//         _arabicFont = await PdfGoogleFonts.notoSansArabicRegular();
//         _englishFont = await PdfGoogleFonts.robotoRegular();
//         _boldArabicFont = await PdfGoogleFonts.notoSansArabicBold();
//         _boldEnglishFont = await PdfGoogleFonts.robotoBold();
//         _fontsLoaded = true;
//       }
//     }

//     // Load images
//     try {
//       final flagData = await rootBundle.load('assets/images/egypt_flag.svg');
//       final logoData = await rootBundle.load(
//         'assets/images/ministry_interior_logo.svg',
//       );
//       _egyptFlag = pw.MemoryImage(flagData.buffer.asUint8List());
//       _ministryLogo = pw.MemoryImage(logoData.buffer.asUint8List());
//       _imagesLoaded = true;
//       print('Images loaded successfully');
//     } catch (e) {
//       print('Failed to load images: $e');
//       _imagesLoaded = false;
//     }
//   }

//   static Future<pw.Document> generateReport(ReportEntity report) async {
//     await _loadAssets();

//     final doc = pw.Document();
//     final primaryColor = PdfColor.fromHex('#1B4D3E');
//     final grayColor = PdfColor.fromHex('#F5F5F5');
//     final accentColor = PdfColor.fromHex('#2E7D32');

//     // Define text styles with proper font selection
//     final englishTextStyle = pw.TextStyle(
//       font: _englishFont,
//       fontSize: 12,
//       color: PdfColors.black,
//       fontFallback: [_englishFont!, _arabicFont!], // Ensure English font first
//     );

//     final arabicTextStyle = pw.TextStyle(
//       font: _arabicFont,
//       fontSize: 12,
//       color: PdfColors.black,
//       fontFallback: [_arabicFont!, _englishFont!], // Ensure Arabic font first
//     );

//     final titleStyle = pw.TextStyle(
//       font: _englishFont,
//       fontSize: 22,
//       fontWeight: pw.FontWeight.bold,
//       color: PdfColors.white,
//       letterSpacing: 1.2,
//       fontFallback: [_englishFont!, _arabicFont!],
//     );

//     final arabicTitleStyle = pw.TextStyle(
//       font: _arabicFont,
//       fontSize: 18,
//       color: PdfColors.white,
//       fontFallback: [_arabicFont!, _englishFont!],
//     );

//     doc.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(20),
//         textDirection: pw.TextDirection.rtl,
//         theme: pw.ThemeData.withFont(
//           base: _englishFont!,
//           bold: _englishFont!,
//           italic: _englishFont!,
//           boldItalic: _englishFont!,
//           fontFallback: [_englishFont!, _arabicFont!],
//         ),
//         build:
//             (context) => pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 _buildHeader(
//                   report,
//                   primaryColor,
//                   accentColor,
//                   titleStyle,
//                   arabicTitleStyle,
//                 ),
//                 pw.SizedBox(height: 25),
//                 _buildInfoSection(
//                   'REPORT INFORMATION',
//                   'معلومات التقرير',
//                   [
//                     'Type: ${report.reportType}',
//                     'Date: ${_formatDate(report.reportDateTime)}',
//                     'Status: ${report.status.arabicName}',
//                   ],
//                   primaryColor,
//                   grayColor,
//                   englishTextStyle,
//                   arabicTextStyle,
//                 ),
//                 pw.SizedBox(height: 20),
//                 _buildInfoSection(
//                   'REPORTER INFORMATION',
//                   'معلومات المبلغ',
//                   [
//                     'Name: ${report.firstName} ${report.lastName}',
//                     'National ID: ${report.nationalId}',
//                     'Phone: ${report.phone}',
//                   ],
//                   primaryColor,
//                   grayColor,
//                   englishTextStyle,
//                   arabicTextStyle,
//                 ),
//                 pw.SizedBox(height: 20),
//                 _buildDetailsSection(
//                   report,
//                   primaryColor,
//                   grayColor,
//                   arabicTextStyle,
//                 ),
//                 if (report.latitude != null && report.longitude != null) ...[
//                   pw.SizedBox(height: 20),
//                   _buildInfoSection(
//                     'LOCATION INFORMATION',
//                     'معلومات الموقع',
//                     [
//                       'Location: ${report.locationName ?? "Not specified"}',
//                       'Latitude: ${report.latitude?.toStringAsFixed(6) ?? 'N/A'}',
//                       'Longitude: ${report.longitude?.toStringAsFixed(6) ?? 'N/A'}',
//                     ],
//                     primaryColor,
//                     grayColor,
//                     englishTextStyle,
//                     arabicTextStyle,
//                   ),
//                 ],
//                 pw.Spacer(),
//                 _buildFooter(primaryColor, englishTextStyle, arabicTextStyle),
//               ],
//             ),
//       ),
//     );
//     return doc;
//   }

//   static pw.Widget _buildHeader(
//     ReportEntity report,
//     PdfColor primaryColor,
//     PdfColor accentColor,
//     pw.TextStyle titleStyle,
//     pw.TextStyle arabicTitleStyle,
//   ) {
//     return pw.Container(
//       width: double.infinity,
//       padding: const pw.EdgeInsets.all(20),
//       decoration: pw.BoxDecoration(
//         color: primaryColor,
//         borderRadius: pw.BorderRadius.all(
//           pw.Radius.circular(12),
//         ), // Explicit BorderRadius
//       ),
//       child: pw.Column(
//         children: [
//           pw.Text('NETRU REPORT', style: titleStyle),
//           pw.SizedBox(height: 8),
//           pw.Text(
//             'تقرير نترو',
//             style: arabicTitleStyle,
//             textDirection: pw.TextDirection.rtl,
//           ),
//           pw.SizedBox(height: 12),
//           pw.Container(
//             padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: pw.BoxDecoration(
//               color: PdfColors.white,
//               borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
//             ),
//             child: pw.Text(
//               'Report ID: ${report.id.substring(0, 10)}',
//               style: pw.TextStyle(
//                 font: _englishFont,
//                 fontSize: 14,
//                 color: primaryColor,
//                 fontWeight: pw.FontWeight.bold,
//                 fontFallback: [_englishFont!, _arabicFont!],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   static pw.Widget _buildInfoSection(
//     String titleEn,
//     String titleAr,
//     List<String> items,
//     PdfColor titleColor,
//     PdfColor backgroundColor,
//     pw.TextStyle englishTextStyle,
//     pw.TextStyle arabicTextStyle,
//   ) {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Container(
//           width: double.infinity,
//           padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//           decoration: pw.BoxDecoration(
//             color: titleColor,
//             borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
//           ),
//           child: pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//             children: [
//               pw.Text(
//                 titleEn,
//                 style: pw.TextStyle(
//                   font: _englishFont,
//                   fontSize: 14,
//                   fontWeight: pw.FontWeight.bold,
//                   color: PdfColors.white,
//                   fontFallback: [_englishFont!, _arabicFont!],
//                 ),
//               ),
//               pw.Text(
//                 titleAr,
//                 style: pw.TextStyle(
//                   font: _arabicFont,
//                   fontSize: 12,
//                   fontWeight: pw.FontWeight.bold,
//                   color: PdfColors.white,
//                   fontFallback: [_arabicFont!, _englishFont!],
//                 ),
//                 textDirection: pw.TextDirection.rtl,
//               ),
//             ],
//           ),
//         ),
//         pw.SizedBox(height: 8),
//         pw.Container(
//           width: double.infinity,
//           padding: const pw.EdgeInsets.all(16),
//           decoration: pw.BoxDecoration(
//             color: backgroundColor,
//             borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
//             border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
//           ),
//           child: pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children:
//                 items
//                     .map(
//                       (item) => pw.Padding(
//                         padding: const pw.EdgeInsets.only(bottom: 6),
//                         child: pw.Row(
//                           crossAxisAlignment: pw.CrossAxisAlignment.start,
//                           children: [
//                             pw.Text(
//                               '• ',
//                               style: pw.TextStyle(
//                                 font: _englishFont,
//                                 fontSize: 12,
//                                 color: titleColor,
//                                 fontWeight: pw.FontWeight.bold,
//                               ),
//                             ),
//                             pw.Expanded(
//                               child: _buildMixedText(
//                                 item,
//                                 englishTextStyle,
//                                 arabicTextStyle,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     )
//                     .toList(),
//           ),
//         ),
//       ],
//     );
//   }

//   static pw.Widget _buildDetailsSection(
//     ReportEntity report,
//     PdfColor primaryColor,
//     PdfColor grayColor,
//     pw.TextStyle arabicTextStyle,
//   ) {
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.start,
//       children: [
//         pw.Container(
//           width: double.infinity,
//           padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//           decoration: pw.BoxDecoration(
//             color: primaryColor,
//             borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
//           ),
//           child: pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//             children: [
//               pw.Text(
//                 'REPORT DETAILS',
//                 style: pw.TextStyle(
//                   font: _englishFont,
//                   fontSize: 14,
//                   fontWeight: pw.FontWeight.bold,
//                   color: PdfColors.white,
//                   fontFallback: [_englishFont!, _arabicFont!],
//                 ),
//               ),
//               pw.Text(
//                 'تفاصيل التقرير',
//                 style: pw.TextStyle(
//                   font: _arabicFont,
//                   fontSize: 12,
//                   fontWeight: pw.FontWeight.bold,
//                   color: PdfColors.white,
//                   fontFallback: [_arabicFont!, _englishFont!],
//                 ),
//                 textDirection: pw.TextDirection.rtl,
//               ),
//             ],
//           ),
//         ),
//         pw.SizedBox(height: 8),
//         pw.Container(
//           width: double.infinity,
//           padding: const pw.EdgeInsets.all(16),
//           decoration: pw.BoxDecoration(
//             color: grayColor,
//             borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
//             border: pw.Border(
//               left: pw.BorderSide(color: primaryColor, width: 4),
//             ),
//           ),
//           child: pw.Text(
//             report.reportDetails,
//             style: arabicTextStyle,
//             textDirection: pw.TextDirection.rtl,
//           ),
//         ),
//       ],
//     );
//   }

//   static pw.Widget _buildFooter(
//     PdfColor primaryColor,
//     pw.TextStyle englishTextStyle,
//     pw.TextStyle arabicTextStyle,
//   ) {
//     return pw.Container(
//       width: double.infinity,
//       padding: const pw.EdgeInsets.all(15),
//       decoration: pw.BoxDecoration(
//         border: pw.Border(top: pw.BorderSide(color: primaryColor, width: 2)),
//         color: PdfColors.grey100,
//       ),
//       child: pw.Column(
//         children: [
//           pw.Text(
//             'Generated by Netru App',
//             style: englishTextStyle.copyWith(
//               fontSize: 11,
//               fontWeight: pw.FontWeight.bold,
//               color: primaryColor,
//             ),
//             textAlign: pw.TextAlign.center,
//           ),
//           pw.SizedBox(height: 4),
//           pw.Text(
//             'تم إنشاؤه بواسطة تطبيق نترو',
//             style: arabicTextStyle.copyWith(
//               fontSize: 10,
//               color: PdfColors.grey600,
//             ),
//             textAlign: pw.TextAlign.center,
//             textDirection: pw.TextDirection.rtl,
//           ),
//           pw.SizedBox(height: 4),
//           pw.Text(
//             _formatDate(DateTime.now()),
//             style: englishTextStyle.copyWith(
//               fontSize: 10,
//               color: PdfColors.grey600,
//             ),
//             textAlign: pw.TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   static String _formatDate(DateTime dateTime) {
//     try {
//       return DateFormat('dd/MM/yyyy - HH:mm').format(dateTime);
//     } catch (e) {
//       return dateTime.toString().substring(0, 16);
//     }
//   }

//   // Helper to detect if text contains Arabic characters
//   static bool _isArabic(String text) {
//     final arabicRegex = RegExp(r'[\u0600-\u06FF]');
//     return arabicRegex.hasMatch(text);
//   }

//   // Helper to split and render mixed text
//   static pw.Widget _buildMixedText(
//     String text,
//     pw.TextStyle englishTextStyle,
//     pw.TextStyle arabicTextStyle,
//   ) {
//     final arabicRegex = RegExp(r'[\u0600-\u06FF]+');
//     final parts = text.split(arabicRegex);
//     final arabicMatches =
//         arabicRegex.allMatches(text).map((m) => m.group(0)!).toList();

//     final widgets = <pw.Widget>[];
//     int arabicIndex = 0;

//     for (var part in parts) {
//       if (part.isNotEmpty) {
//         widgets.add(
//           pw.Text(
//             part,
//             style: englishTextStyle,
//             textDirection: pw.TextDirection.ltr,
//           ),
//         );
//       }
//       if (arabicIndex < arabicMatches.length) {
//         widgets.add(
//           pw.Text(
//             arabicMatches[arabicIndex],
//             style: arabicTextStyle,
//             textDirection: pw.TextDirection.rtl,
//           ),
//         );
//         arabicIndex++;
//       }
//     }

//     return pw.Wrap(
//       direction: pw.Axis.horizontal,
//       children: widgets,
//       runAlignment: pw.WrapAlignment.start,
//       // direction: _isArabic(text) ? pw.TextDirection.rtl : pw.TextDirection.ltr
//     );
//   }

//   // Compatibility methods
//   static Future<pw.Document> generateProfessionalReport(
//     ReportEntity report,
//   ) async => generateReport(report);

//   static Future<pw.Document> generateFastReport(ReportEntity report) async =>
//       generateReport(report);

//   static Future<pw.Document> generateEmergencyReport(
//     ReportEntity report,
//   ) async => generateReport(report);

//   static Future<pw.Document> generateReportWithFallback(
//     ReportEntity report,
//   ) async => generateReport(report);

//   static Future<pw.Document> generateUltraFastReport(
//     ReportEntity report,
//   ) async => generateReport(report);
// }
