import 'package:flutter/material.dart';
import '../../../../core/services/simple_notification_service.dart';

/// صفحة اختبار نظام الإشعارات المحسن
class NotificationTestPage extends StatefulWidget {
  const NotificationTestPage({super.key});

  @override
  State<NotificationTestPage> createState() => _NotificationTestPageState();
}

class _NotificationTestPageState extends State<NotificationTestPage> {
  final SimpleNotificationService _notificationService =
      SimpleNotificationService();
  String _status = 'جاهز للاختبار';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار نظام الإشعارات المحسن'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // حالة النظام
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  const Icon(Icons.info, color: Colors.blue, size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    'حالة النظام',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // أزرار الاختبار
            _buildTestButton(
              '📩 اختبار إشعار استلام البلاغ',
              () => _testReportStatusNotification('received'),
              Colors.green,
            ),

            const SizedBox(height: 12),

            _buildTestButton(
              '🔍 اختبار إشعار بدء التحقيق',
              () => _testReportStatusNotification('under_investigation'),
              Colors.orange,
            ),

            const SizedBox(height: 12),

            _buildTestButton(
              '✅ اختبار إشعار حل البلاغ',
              () => _testReportStatusNotification('resolved'),
              Colors.blue,
            ),

            const SizedBox(height: 12),

            _buildTestButton(
              '❌ اختبار إشعار رفض البلاغ',
              () => _testReportStatusNotification('rejected'),
              Colors.red,
            ),

            const SizedBox(height: 12),

            _buildTestButton(
              '🔔 اختبار إشعار عام',
              () => _testGeneralNotification(),
              Colors.purple,
            ),

            const SizedBox(height: 12),

            _buildTestButton(
              '📱 اختبار إشعار محلي',
              () => _testLocalNotification(),
              Colors.teal,
            ),

            const Spacer(),

            // معلومات إضافية
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'معلومات النظام:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• الإشعارات تُحفظ في جدول notifications\n'
                    '• رموز FCM تُسترجع من جدول user_fcm_tokens\n'
                    '• يتم إرسال إشعار محلي كبديل عند الحاجة\n'
                    '• النظام يدعم البلاغات المجهولة وغير المجهولة',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            if (_isLoading) const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(String text, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _testReportStatusNotification(String status) async {
    setState(() {
      _isLoading = true;
      _status = 'اختبار إشعار تحديث حالة البلاغ: $status';
    });

    try {
      // إنشاء معرف بلاغ وهمي للاختبار
      const testReportId = 'test-report-12345';
      const testReporterName = 'أحمد محمد (اختبار)';
      const testCaseNumber = 'TEST-001';
      const testInvestigator = 'المحقق أحمد علي';

      await _notificationService.sendReportStatusNotification(
        reportId: testReportId,
        reportStatus: status,
        reportOwnerName: testReporterName,
        caseNumber: testCaseNumber,
        investigatorName: testInvestigator,
      );

      setState(() {
        _status = '✅ تم إرسال إشعار تحديث الحالة بنجاح!\nالحالة: $status';
      });

      _showSuccessSnackBar('تم إرسال الإشعار بنجاح');
    } catch (e) {
      setState(() {
        _status = '❌ خطأ في إرسال الإشعار: $e';
      });

      _showErrorSnackBar('فشل إرسال الإشعار: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testGeneralNotification() async {
    setState(() {
      _isLoading = true;
      _status = 'اختبار إشعار عام';
    });

    try {
      // لأغراض الاختبار، نستخدم معرف مستخدم وهمي
      const testUserId = 'test-user-12345';

      await _notificationService.sendNotificationToUser(
        userId: testUserId,
        title: '📢 إشعار عام - اختبار',
        body:
            'هذا إشعار اختبار من نظام الإشعارات المحسن. تم إرسال الإشعار بنجاح!',
        type: 'general',
        data: {'test': true, 'timestamp': DateTime.now().toIso8601String()},
      );

      setState(() {
        _status = '✅ تم إرسال الإشعار العام بنجاح!';
      });

      _showSuccessSnackBar('تم إرسال الإشعار العام بنجاح');
    } catch (e) {
      setState(() {
        _status = '❌ خطأ في إرسال الإشعار العام: $e';
      });

      _showErrorSnackBar('فشل إرسال الإشعار العام: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testLocalNotification() async {
    setState(() {
      _isLoading = true;
      _status = 'اختبار الإشعار المحلي';
    });

    try {
      await _notificationService.showLocalNotification(
        title: '📱 إشعار محلي - اختبار',
        body: 'هذا إشعار محلي من نظام الإشعارات. يظهر مباشرة على الجهاز!',
      );

      setState(() {
        _status = '✅ تم عرض الإشعار المحلي بنجاح!';
      });

      _showSuccessSnackBar('تم عرض الإشعار المحلي بنجاح');
    } catch (e) {
      setState(() {
        _status = '❌ خطأ في عرض الإشعار المحلي: $e';
      });

      _showErrorSnackBar('فشل عرض الإشعار المحلي: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
