import 'package:flutter_test/flutter_test.dart';
import 'package:netru_app/core/services/report_notification_service.dart';

void main() {
  group('Report Notification Service Tests', () {
    late ReportNotificationService notificationService;

    setUp(() {
      // تهيئة الخدمة للاختبار
      notificationService = ReportNotificationService();
    });

    test('should create notification service instance', () {
      // اختبار إنشاء مثيل من الخدمة
      expect(notificationService, isNotNull);
      expect(notificationService, isA<ReportNotificationService>());
    });

    test('should generate correct notification type from status', () {
      // اختبار تحديد نوع الإشعار الصحيح حسب الحالة
      final service = ReportNotificationService();

      // اختبار مختلف الحالات
      expect(
        service.getNotificationTypeFromStatusTest('resolved'),
        equals('success'),
      );
      expect(
        service.getNotificationTypeFromStatusTest('rejected'),
        equals('error'),
      );
      expect(
        service.getNotificationTypeFromStatusTest('under_investigation'),
        equals('info'),
      );
      expect(
        service.getNotificationTypeFromStatusTest('received'),
        equals('report_success'),
      );
      expect(
        service.getNotificationTypeFromStatusTest('unknown'),
        equals('info'),
      );
    });

    test('should generate correct priority from status', () {
      // اختبار تحديد الأولوية الصحيحة حسب الحالة
      final service = ReportNotificationService();

      expect(service.getPriorityFromStatusTest('resolved'), equals('high'));
      expect(service.getPriorityFromStatusTest('rejected'), equals('high'));
      expect(
        service.getPriorityFromStatusTest('under_investigation'),
        equals('normal'),
      );
      expect(service.getPriorityFromStatusTest('received'), equals('normal'));
      expect(service.getPriorityFromStatusTest('unknown'), equals('normal'));
    });

    test('should create notification content for different statuses', () {
      // اختبار إنشاء محتوى الإشعار للحالات المختلفة
      final service = ReportNotificationService();

      // اختبار حالة "تم الاستلام"
      final receivedContent = service.createNotificationContentTest(
        status: 'received',
        caseNumber: 'TEST001',
        reporterName: 'أحمد محمد',
      );

      expect(receivedContent['title'], isNotNull);
      expect(receivedContent['body'], isNotNull);
      expect(receivedContent['title']!.contains('استلام'), isTrue);
      expect(receivedContent['body']!.contains('TEST001'), isTrue);

      // اختبار حالة "قيد التحقيق"
      final investigationContent = service.createNotificationContentTest(
        status: 'under_investigation',
        caseNumber: 'TEST002',
        reporterName: 'فاطمة علي',
        investigatorName: 'د. سامر أحمد',
      );

      expect(investigationContent['title'], isNotNull);
      expect(investigationContent['body'], isNotNull);
      expect(investigationContent['title']!.contains('التحقيق'), isTrue);
      expect(investigationContent['body']!.contains('TEST002'), isTrue);
      expect(investigationContent['body']!.contains('د. سامر أحمد'), isTrue);
    });

    // اختبار تكامل مع قاعدة البيانات (يحتاج إلى environment مناسب)
    // test('should save notification to database', () async {
    //   // هذا الاختبار يحتاج إلى تهيئة Supabase للاختبار
    //   // يمكن تفعيله عند توفر بيئة اختبار مناسبة
    // });

    // اختبار تكامل مع Edge Function (يحتاج إلى environment مناسب)
    // test('should send FCM notification via Edge Function', () async {
    //   // هذا الاختبار يحتاج إلى تهيئة Edge Functions للاختبار
    //   // يمكن تفعيله عند توفر بيئة اختبار مناسبة
    // });
  });
}

// Extension لفتح المرئيات private للاختبار
extension ReportNotificationServiceTest on ReportNotificationService {
  String getNotificationTypeFromStatusTest(String status) =>
      _getNotificationTypeFromStatus(status);

  String getPriorityFromStatusTest(String status) =>
      _getPriorityFromStatus(status);

  Map<String, String> createNotificationContentTest({
    required String status,
    required String caseNumber,
    String? reporterName,
    String? investigatorName,
    String? estimatedTime,
    String? adminNotes,
  }) => _createNotificationContent(
    status: status,
    caseNumber: caseNumber,
    reporterName: reporterName,
    investigatorName: investigatorName,
    estimatedTime: estimatedTime,
    adminNotes: adminNotes,
  );
}
