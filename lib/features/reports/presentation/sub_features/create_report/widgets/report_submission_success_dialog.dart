import 'package:flutter/material.dart';

class ReportSubmissionSuccessDialog extends StatelessWidget {
  final VoidCallback onNewReport;
  final VoidCallback onGoBack;

  const ReportSubmissionSuccessDialog({
    super.key,
    required this.onNewReport,
    required this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Animation Container
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                size: 60,
                color: Colors.green[600],
              ),
            ),
            const SizedBox(height: 20),

            // Success Title
            const Text(
              'تم إرسال البلاغ بنجاح',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Success Message
            Text(
              'شكراً لك على إرسال البلاغ. سيتم مراجعته من قبل فريقنا في أقرب وقت ممكن.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onNewReport,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: Colors.blue[800]!),
                    ),
                    child: Text(
                      'بلاغ جديد',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onGoBack,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'العودة',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    required VoidCallback onNewReport,
    required VoidCallback onGoBack,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => ReportSubmissionSuccessDialog(
            onNewReport: onNewReport,
            onGoBack: onGoBack,
          ),
    );
  }
}
