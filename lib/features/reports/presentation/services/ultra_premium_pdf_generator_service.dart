import 'package:flutter/services.dart';
import '../../domain/entities/reports_entity.dart';
import 'professional_egyptian_pdf_service.dart';

class SimplifiedPdfGeneratorService {
  // تم استبدال هذه الخدمة بالخدمة الاحترافية الجديدة
  // This service has been replaced with the new professional service

  static Future<Uint8List> generateReportPdf(ReportEntity report) async {
    // استخدام الخدمة الاحترافية الجديدة
    return ProfessionalEgyptianPdfService.generateProfessionalReportPdf(report);
  }
}
