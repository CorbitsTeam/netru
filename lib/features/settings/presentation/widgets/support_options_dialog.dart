import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportOptionsDialog extends StatelessWidget {
  const SupportOptionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.support_agent,
                  color: AppColors.primaryColor,
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'خيارات الدعم',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.headlineSmall?.color,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Support options
            _buildSupportOption(
              context,
              icon: Icons.email_outlined,
              title: 'البريد الإلكتروني',
              subtitle: 'corbitsteam@gmail.com',
              onTap: () => _sendEmail(context),
            ),

            SizedBox(height: 20.h),

            // Close button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    side: const BorderSide(color: AppColors.primaryColor),
                  ),
                ),
                child: Text(
                  'إغلاق',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(icon, color: AppColors.primaryColor, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendEmail(BuildContext context) async {
    const email = 'corbitsteam@gmail.com';
    const subject = 'طلب دعم فني - تطبيق نترو';
    const body = '''
مرحباً فريق الدعم،

أحتاج المساعدة في:
[يرجى وصف مشكلتك أو استفسارك هنا]

معلومات إضافية:
- نظام التشغيل: 
- إصدار التطبيق: 1.0.0
- رقم المستخدم: [إذا كان متاحاً]

شكراً لكم.
    ''';

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query:
          'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _showFallbackEmailDialog(context, email);
      }
    } catch (e) {
      _showFallbackEmailDialog(context, email);
    }
  }

  void _showFallbackEmailDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تعذر فتح البريد الإلكتروني'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('يمكنكم إرسال بريد إلكتروني إلى:'),
                SizedBox(height: 8.h),
                SelectableText(
                  email,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('حسناً'),
              ),
            ],
          ),
    );
  }
}
