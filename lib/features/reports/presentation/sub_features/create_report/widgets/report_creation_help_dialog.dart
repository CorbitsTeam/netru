import 'package:flutter/material.dart';

class ReportCreationHelpDialog extends StatelessWidget {
  const ReportCreationHelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.help_outline, color: Colors.blue[800], size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'مساعدة إنشاء البلاغ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Help Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHelpItem(
                  '📝 املأ جميع البيانات الشخصية المطلوبة',
                  'تأكد من صحة الاسم الأول والأخير ورقم الهوية ورقم الهاتف',
                ),
                _buildHelpItem(
                  '📍 حدد الموقع بدقة',
                  'استخدم GPS أو أدخل العنوان يدوياً للحصول على أفضل خدمة',
                ),
                _buildHelpItem(
                  '📅 اختر التاريخ والوقت الصحيح',
                  'حدد متى وقع الحدث بالضبط لمساعدتنا في المتابعة',
                ),
                _buildHelpItem(
                  '📸 أرفق صور أو مقاطع فيديو',
                  'الأدلة البصرية تساعد في سرعة معالجة البلاغ',
                ),
                _buildHelpItem(
                  '✅ راجع البيانات قبل الإرسال',
                  'تأكد من جميع المعلومات قبل الضغط على "إرسال البلاغ"',
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'فهمت',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, left: 8),
            decoration: BoxDecoration(
              color: Colors.blue[800],
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ReportCreationHelpDialog(),
    );
  }
}
