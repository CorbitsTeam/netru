import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../features/reports/presentation/services/premium_pdf_generator_service.dart';
import '../features/reports/domain/entities/reports_entity.dart';

/// Example test file to generate a sample PDF report
/// يمكن استخدام هذا الملف لاختبار إنشاء تقرير PDF نموذجي
class PdfTestHelper {
  /// Creates a sample report entity for testing
  static ReportEntity createSampleReport() {
    return ReportEntity(
      id: 'RPT-2024-001-EGY-12345',
      firstName: 'أحمد',
      lastName: 'محمد عبدالله',
      nationalId: '29801234567890',
      phone: '+201234567890',
      reportType: 'حريق في مبنى سكني',
      reportTypeId: 1,
      reportDetails: '''
تم الإبلاغ عن نشوب حريق في الطابق الثالث من مبنى سكني بالدور الرابع. 
بدأ الحريق في حوالي الساعة 3:45 صباحًا وانتشر بسرعة إلى الشقق المجاورة.

تفاصيل الحادث:
- موقع الحريق: شقة رقم 304، العمارة رقم 15
- سبب الحريق المشتبه: ماس كهربائي في المطبخ
- عدد المتضررين: 12 شخص تم إجلاؤهم بأمان
- الأضرار: أضرار جزئية في 3 شقق
- تدخل فرق الإطفاء: وصلت خلال 8 دقائق من الإبلاغ

الإجراءات المتخذة:
1. إخلاء فوري للمبنى
2. إبلاغ الإطفاء والإسعاف
3. فصل التيار الكهربائي عن المبنى
4. تأمين المنطقة المحيطة

يطلب التدخل العاجل لتقييم الأضرار ومعاينة سلامة المبنى.
      ''',
      latitude: 30.0444196,
      longitude: 31.2357116,
      locationName: 'شارع التحرير، وسط البلد، القاهرة، مصر',
      reportDateTime: DateTime(2024, 9, 19, 3, 45),
      mediaUrl: null,
      mediaType: null,
      status: ReportStatus.underReview,
      submittedBy: 'user_ahmed_123',
      createdAt: DateTime(2024, 9, 19, 4, 15),
      updatedAt: DateTime(2024, 9, 19, 8, 30),
    );
  }

  /// Generates and saves a test PDF report
  static Future<void> generateTestReport([String? outputPath]) async {
    try {
      // Create sample report
      final report = createSampleReport();

      // Generate PDF
      final doc = await PremiumPdfGeneratorService.generatePremiumReport(
        report,
      );
      final bytes = await doc.save();

      // Save to file (for testing purposes)
      if (outputPath != null) {
        final file = File(outputPath);
        await file.writeAsBytes(bytes);
        print('✅ تم إنشاء التقرير بنجاح: $outputPath');
        print('📊 حجم الملف: ${(bytes.length / 1024).toStringAsFixed(2)} KB');
      } else {
        print('✅ تم إنشاء التقرير بنجاح في الذاكرة');
        print('📊 حجم الملف: ${(bytes.length / 1024).toStringAsFixed(2)} KB');
      }
    } catch (e) {
      print('❌ خطأ في إنشاء التقرير: $e');
      rethrow;
    }
  }

  /// Shows report generation instructions
  static void showUsageInstructions() {
    print('''
🏛️ مولد التقارير الرسمية المصرية 
==================================

الاستخدام:
---------
1. في صفحة تفاصيل التقرير، اضغط على زر "المزيد"
2. اختر "تصدير PDF" أو "طباعة التقرير"
3. سيتم إنشاء تقرير رسمي بتصميم وزارة الداخلية

المميزات الجديدة:
-----------------
✅ علم مصر في رأس التقرير
✅ شعار وزارة الداخلية
✅ ألوان رسمية مصرية
✅ خطوط عربية محسنة
✅ تخطيط احترافي
✅ تتبع حالة البلاغ
✅ معلومات الموقع بالتفصيل
✅ تنسيق متوافق مع المعايير الحكومية

ملاحظات:
---------
- يتم تحميل الخطوط تلقائياً من Google Fonts
- في حالة عدم توفر الإنترنت، يتم استخدام خطوط النظام
- التقرير متوافق مع معايير وزارة الداخلية المصرية
- يمكن طباعة التقرير أو مشاركته إلكترونياً
    ''');
  }
}

/// Widget helper for testing in development
class PdfTestWidget extends StatelessWidget {
  const PdfTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار مولد التقارير'),
        backgroundColor: const Color(0xFF1B4D72),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.picture_as_pdf,
              size: 80,
              color: Color(0xFFCE1126),
            ),
            const SizedBox(height: 20),
            const Text(
              'مولد التقارير الرسمية',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B4D72),
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 10),
            const Text(
              'وزارة الداخلية - جمهورية مصر العربية',
              style: TextStyle(fontSize: 16, color: Color(0xFF6C757D)),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await PdfTestHelper.generateTestReport();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ تم إنشاء التقرير بنجاح'),
                        backgroundColor: Color(0xFF228B22),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ خطأ: $e'),
                        backgroundColor: const Color(0xFFCE1126),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.download),
              label: const Text('إنشاء تقرير تجريبي'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF228B22),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                PdfTestHelper.showUsageInstructions();
              },
              icon: const Icon(Icons.info_outline),
              label: const Text('إرشادات الاستخدام'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1B4D72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
