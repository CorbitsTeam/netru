// Test script for the enhanced notification system
// Run this to test various notification scenarios

import 'package:flutter_test/flutter_test.dart';
import 'package:netru_app/core/services/notification_template_service.dart';

void main() {
  group('Notification Template Service Tests', () {
    test(
      'should generate proper report status notification for resolved case',
      () {
        final template = NotificationTemplateService.reportStatusUpdate(
          status: 'resolved',
          reporterName: 'أحمد محمد',
          caseNumber: 'NTR001',
          investigatorName: 'المحقق سارة أحمد',
        );

        expect(template['title'], contains('تم حل بلاغكم'));
        expect(template['body'], contains('أحمد محمد'));
        expect(template['body'], contains('NTR001'));
        expect(template['emoji'], equals('✅'));
      },
    );

    test('should generate investigator assignment notification', () {
      final template = NotificationTemplateService.investigatorAssignment(
        reportId: 'report_123',
        reporterName: 'فاطمة علي',
        caseNumber: 'NTR002',
        reportType: 'بلاغ أمني',
        priority: 'high',
      );

      expect(template['title'], contains('تكليف جديد'));
      expect(template['body'], contains('فاطمة علي'));
      expect(template['body'], contains('NTR002'));
      expect(template['emoji'], equals('🔴'));
    });

    test('should generate user assignment notification', () {
      final template = NotificationTemplateService.reportAssignmentToUser(
        reporterName: 'محمود حسن',
        caseNumber: 'NTR003',
        investigatorName: 'المحقق أحمد السيد',
        investigatorTitle: 'محقق أول',
      );

      expect(template['title'], contains('تم تعيين محقق'));
      expect(template['body'], contains('محمود حسن'));
      expect(template['body'], contains('أحمد السيد'));
      expect(template['emoji'], equals('👨‍💼'));
    });

    test('should generate welcome notification for new citizen', () {
      final template = NotificationTemplateService.welcomeUser(
        userName: 'عبدالله أحمد',
        userType: 'citizen',
      );

      expect(template['title'], contains('أهلاً وسهلاً عبدالله أحمد'));
      expect(template['body'], contains('مواطن'));
      expect(template['body'], contains('تقديم البلاغات'));
      expect(template['emoji'], equals('🎉'));
    });

    test('should generate security alert notification', () {
      final template = NotificationTemplateService.securityAlert(
        alertType: 'emergency',
        location: 'شارع النصر',
        severity: 'عالي',
        description: 'حادث مروري كبير',
      );

      expect(template['title'], contains('تنبيه أمني عاجل'));
      expect(template['body'], contains('شارع النصر'));
      expect(template['body'], contains('حادث مروري'));
      expect(template['emoji'], equals('🚨'));
    });

    test('should generate app update notification', () {
      final template = NotificationTemplateService.appUpdate(
        version: '2.1.0',
        updateType: 'mandatory',
        newFeatures: ['تحسين الأداء', 'واجهة جديدة'],
        bugFixes: ['إصلاح مشكلة الإشعارات'],
      );

      expect(template['title'], contains('تحديث مطلوب'));
      expect(template['body'], contains('2.1.0'));
      expect(template['body'], contains('تحسين الأداء'));
      expect(template['emoji'], equals('⚠️'));
    });
  });

  group('Edge Function Integration Tests', () {
    // Test FCM token registration
    test('should register FCM token successfully', () async {
      // This would be an integration test
      // Mock the Supabase client and test token registration

      // Example of what the test would check:
      // 1. Token is properly formatted
      // 2. User ID exists
      // 3. Device type is valid
      // 4. Token is stored in database
    });

    // Test notification sending
    test('should send bulk notifications via edge function', () async {
      // This would test the actual edge function
      // Mock the HTTP request and verify:
      // 1. Notifications are created in database
      // 2. FCM requests are sent
      // 3. Status is updated correctly
    });
  });

  group('Real-world Usage Scenarios', () {
    test('Complete report lifecycle notifications', () {
      // Test the complete flow:

      // 1. Report received
      var template = NotificationTemplateService.reportStatusUpdate(
        status: 'received',
        reporterName: 'سالم الأحمد',
        caseNumber: 'NTR100',
      );
      expect(template['title'], contains('تم استلام'));

      // 2. Under investigation
      template = NotificationTemplateService.reportStatusUpdate(
        status: 'under_investigation',
        reporterName: 'سالم الأحمد',
        caseNumber: 'NTR100',
        investigatorName: 'المحقق محمد علي',
      );
      expect(template['title'], contains('بدء التحقيق'));

      // 3. Resolved
      template = NotificationTemplateService.reportStatusUpdate(
        status: 'resolved',
        reporterName: 'سالم الأحمد',
        caseNumber: 'NTR100',
        investigatorName: 'المحقق محمد علي',
      );
      expect(template['title'], contains('تم حل'));
    });
  });
}

// Sample usage examples that can be used in the actual app
class NotificationExamples {
  /// Example: Send status update notification
  static Future<void> sendStatusUpdateExample() async {
    // This is how you would use it in the actual AdminReportRemoteDataSource

    final template = NotificationTemplateService.reportStatusUpdate(
      status: 'resolved',
      reporterName: 'أحمد محمد',
      caseNumber: 'NTR001',
      investigatorName: 'المحقق سارة أحمد',
    );

    // Then send via edge function:
    // await edgeFunctionsService.sendBulkNotifications(
    //   userIds: [userId],
    //   title: template['title']!,
    //   body: template['body']!,
    //   data: {
    //     'report_id': reportId,
    //     'type': 'report_status_update',
    //     'action': 'view_report',
    //   },
    // );
  }

  /// Example: Welcome new user
  static Future<void> sendWelcomeNotificationExample() async {
    final template = NotificationTemplateService.welcomeUser(
      userName: 'فاطمة أحمد',
      userType: 'citizen',
      quickTips: [
        'يمكنك تقديم بلاغ من الصفحة الرئيسية',
        'تابع حالة بلاغاتك من "بلاغاتي"',
        'فعّل الإشعارات للحصول على التحديثات',
      ],
    );

    print('Welcome notification generated:');
    print('Title: ${template['title']}');
    print('Body: ${template['body']}');
  }

  /// Example: Send security alert
  static Future<void> sendSecurityAlertExample() async {
    final template = NotificationTemplateService.securityAlert(
      alertType: 'warning',
      location: 'منطقة وسط البلد',
      severity: 'متوسط',
      description: 'ازدحام مروري شديد',
      safetyInstructions: 'يُنصح بتجنب المنطقة واستخدام طرق بديلة',
    );

    print('Security alert generated:');
    print('Title: ${template['title']}');
    print('Body: ${template['body']}');
  }
}
