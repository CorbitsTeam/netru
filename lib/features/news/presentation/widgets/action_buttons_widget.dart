import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:netru_app/features/news/data/models/news_model.dart';
import 'package:share_plus/share_plus.dart';

class ActionButtonsWidget extends StatelessWidget {
  final NewsModel news;
  final VoidCallback? onShare;
  final VoidCallback? onCopy;

  const ActionButtonsWidget({
    super.key,
    required this.news,
    this.onShare,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.surface),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.touch_app_rounded,
                    color: AppColors.primary,
                    size: 16.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  'الإجراءات',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildModernButton(
                    onPressed: onShare ?? () => _shareNews(context),
                    icon: Icons.share_rounded,
                    label: 'مشاركة',
                    isPrimary: true,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _buildModernButton(
                    onPressed: onCopy ?? () => _copyToClipboard(context),
                    icon: Icons.copy_rounded,
                    label: 'نسخ',
                    isPrimary: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isPrimary,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            border:
                isPrimary
                    ? null
                    : Border.all(color: AppColors.primary, width: 1.5),
            boxShadow:
                isPrimary
                    ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15.sp,
                color: isPrimary ? Colors.white : AppColors.primary,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? Colors.white : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareNews(BuildContext context) {
    String shareText = '''
${news.title}

${news.summary}

تاريخ النشر: ${news.date}
''';

    if (news.detailsUrl != null && news.detailsUrl!.isNotEmpty) {
      shareText += '\nرابط المصدر: ${news.detailsUrl}';
    }

    Share.share(shareText);
  }

  void _copyToClipboard(BuildContext context) {
    String copyText = '''
${news.title}

${news.summary}

${news.content}

تاريخ النشر: ${news.date}
''';

    if (news.detailsUrl != null && news.detailsUrl!.isNotEmpty) {
      copyText += '\nرابط المصدر: ${news.detailsUrl}';
    }

    Clipboard.setData(ClipboardData(text: copyText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18.sp),
            SizedBox(width: 10.w),
            Text(
              'تم نسخ محتوى الخبر',
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(14.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
