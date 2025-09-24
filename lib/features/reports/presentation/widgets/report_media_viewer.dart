import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:share_plus/share_plus.dart';

class ReportMediaViewer extends StatelessWidget {
  final String? mediaUrl;
  final String? mediaType;

  const ReportMediaViewer({super.key, this.mediaUrl, this.mediaType});

  @override
  Widget build(BuildContext context) {
    if (mediaUrl == null || mediaUrl!.isEmpty) {
      return _buildNoMediaCard();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    _getMediaIcon(),
                    color: AppColors.primaryColor,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الوسائط المرفقة',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'نوع الملف: ${_getMediaTypeText()}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 14.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'متاح',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Media Content
            _buildMediaContent(),

            SizedBox(height: 16.h),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewFullScreen(context),
                    icon: Icon(Icons.fullscreen, size: 18.sp),
                    label: Text(
                      'عرض كامل',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareMedia(context),
                    icon: Icon(Icons.share, size: 18.sp),
                    label: Text(
                      'مشاركة',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      side: const BorderSide(
                        color: AppColors.primaryColor,
                        width: 1.5,
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

  Widget _buildMediaContent() {
    if (_isImage()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Image.network(
          mediaUrl!,
          width: double.infinity,
          height: 220.h,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: double.infinity,
              height: 220.h,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryColor,
                      ),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'جاري تحميل الصورة...',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: 220.h,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    size: 48.sp,
                    color: Colors.red[400],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'فشل في تحميل الصورة',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.red[700],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'تأكد من اتصالك بالإنترنت وحاول مرة أخرى',
                    style: TextStyle(fontSize: 12.sp, color: Colors.red[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      );
    } else {
      // Video or other media type
      return Container(
        height: 220.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[100]!, Colors.grey[50]!],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey[300]!, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50.r),
              ),
              child: Icon(
                _getMediaIcon(),
                size: 48.sp,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              _getMediaTypeText(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'انقر على "عرض كامل" لفتح الملف',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }

  Widget _buildNoMediaCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(50.r),
            ),
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 48.sp,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'لا توجد وسائط مرفقة',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'لم يتم إرفاق أي صور أو فيديوهات مع هذا البلاغ',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 16.sp, color: Colors.blue),
                SizedBox(width: 8.w),
                Text(
                  'يمكن إرفاق الوسائط عند تقديم البلاغ',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isImage() {
    print('🖼️ MediaViewer Debug - mediaType: "$mediaType"');
    if (mediaType == null) {
      print('❌ mediaType is null');
      return false;
    }

    final isImage = mediaType!.toLowerCase().startsWith('image');
    print(
      '✅ Is Image: $isImage (checking if "$mediaType" starts with "image")',
    );
    return isImage;
  }

  IconData _getMediaIcon() {
    if (mediaType == null) return Icons.attachment;
    if (_isImage()) return Icons.image;
    if (mediaType!.toLowerCase().startsWith('video/')) return Icons.videocam;
    if (mediaType!.toLowerCase().startsWith('audio/')) return Icons.audiotrack;
    if (mediaType!.toLowerCase().contains('pdf')) return Icons.picture_as_pdf;
    return Icons.description;
  }

  String _getMediaTypeText() {
    if (mediaType == null) return 'ملف غير محدد';
    if (_isImage()) return 'صورة';
    if (mediaType!.toLowerCase().startsWith('video/')) return 'فيديو';
    if (mediaType!.toLowerCase().startsWith('audio/')) return 'ملف صوتي';
    if (mediaType!.toLowerCase().contains('pdf')) return 'ملف PDF';
    return 'ملف';
  }

  void _viewFullScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => _FullScreenMediaViewer(
              mediaUrl: mediaUrl!,
              mediaType: mediaType,
            ),
      ),
    );
  }

  void _shareMedia(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (mediaUrl != null && mediaUrl!.isNotEmpty) {
        await Share.shareUri(Uri.parse(mediaUrl!));

        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12.w),
                const Text('تم مشاركة الوسائط بنجاح'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('فشل في مشاركة الوسائط: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    }
  }
}

class _FullScreenMediaViewer extends StatelessWidget {
  final String mediaUrl;
  final String? mediaType;

  const _FullScreenMediaViewer({required this.mediaUrl, this.mediaType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        foregroundColor: Colors.white,
        title: Text(
          'عرض الوسائط',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () => _shareMedia(context),
            icon: const Icon(Icons.share),
            tooltip: 'مشاركة',
          ),
          IconButton(
            onPressed: () => _showMediaInfo(context),
            icon: const Icon(Icons.info_outline),
            tooltip: 'معلومات الملف',
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          child:
              _isImage()
                  ? Image.network(
                    mediaUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              'جاري تحميل الصورة...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              size: 64.sp,
                              color: Colors.white70,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'فشل في تحميل الصورة',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'تأكد من اتصالك بالإنترنت',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                  : Center(
                    child: Container(
                      padding: EdgeInsets.all(40.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getMediaIcon(),
                            size: 64.sp,
                            color: Colors.white,
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            _getMediaTypeText(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'لا يمكن عرض هذا النوع من الملفات',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  bool _isImage() {
    print('🖼️ FullScreenViewer Debug - mediaType: "$mediaType"');
    if (mediaType == null) {
      print('❌ mediaType is null');
      return false;
    }

    final isImage = mediaType!.toLowerCase().startsWith('image');
    print(
      '✅ Is Image: $isImage (checking if "$mediaType" starts with "image")',
    );
    return isImage;
  }

  IconData _getMediaIcon() {
    if (mediaType == null) return Icons.attachment;
    if (_isImage()) return Icons.image;
    if (mediaType!.toLowerCase().startsWith('video/')) return Icons.videocam;
    if (mediaType!.toLowerCase().startsWith('audio/')) return Icons.audiotrack;
    if (mediaType!.toLowerCase().contains('pdf')) return Icons.picture_as_pdf;
    return Icons.description;
  }

  String _getMediaTypeText() {
    if (mediaType == null) return 'ملف غير محدد';
    if (_isImage()) return 'صورة';
    if (mediaType!.toLowerCase().startsWith('video/')) return 'فيديو';
    if (mediaType!.toLowerCase().startsWith('audio/')) return 'ملف صوتي';
    if (mediaType!.toLowerCase().contains('pdf')) return 'ملف PDF';
    return 'ملف';
  }

  void _shareMedia(BuildContext context) async {
    try {
      await Share.shareUri(Uri.parse(mediaUrl));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في مشاركة الوسائط: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showMediaInfo(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Text(
              'معلومات الملف',
              style: TextStyle(color: Colors.white, fontSize: 18.sp),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('النوع', _getMediaTypeText()),
                SizedBox(height: 12.h),
                _buildInfoRow(
                  'الرابط',
                  mediaUrl.length > 30
                      ? '${mediaUrl.substring(0, 30)}...'
                      : mediaUrl,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'إغلاق',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
