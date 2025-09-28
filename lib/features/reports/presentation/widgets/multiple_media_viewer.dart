import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:share_plus/share_plus.dart';

class MultipleMediaViewer extends StatelessWidget {
  final List<Map<String, String>>
  mediaList; // [{url: 'url', type: 'image/video'}]
  final String reportId;
  final bool isCompactMode;

  const MultipleMediaViewer({
    super.key,
    required this.mediaList,
    required this.reportId,
    this.isCompactMode = false,
  });

  @override
  Widget build(BuildContext context) {
    if (mediaList.isEmpty) {
      return _buildNoMediaCard();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(2.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(),
            SizedBox(height: 16.h),
            _buildMediaGrid(context),
            if (mediaList.length > 1) ...[
              SizedBox(height: 16.h),
              _buildMediaStats(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.perm_media,
            color: AppColors.primaryColor,
            size: 20.sp,
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
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${mediaList.length} ${mediaList.length == 1 ? 'ملف' : 'ملفات'}',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        _buildShareAllButton(),
      ],
    );
  }

  Widget _buildShareAllButton() {
    return GestureDetector(
      onTap: () => _shareAllMedia(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.share, color: AppColors.primaryColor, size: 14.sp),
            SizedBox(width: 4.w),
            Text(
              'مشاركة الكل',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaGrid(BuildContext context) {
    if (mediaList.length == 1) {
      return _buildSingleMediaView(context, mediaList.first, 0);
    }

    // Grid layout for multiple media
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: mediaList.length >= 4 ? 2 : mediaList.length,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.0,
      ),
      itemCount: mediaList.length > 4 ? 4 : mediaList.length,
      itemBuilder: (context, index) {
        if (index == 3 && mediaList.length > 4) {
          return _buildMoreMediaCard(context);
        }
        return _buildGridMediaItem(context, mediaList[index], index);
      },
    );
  }

  Widget _buildSingleMediaView(
    BuildContext context,
    Map<String, String> media,
    int index,
  ) {
    final isImage = _isImage(media['type']);

    return GestureDetector(
      onTap: () => _openFullScreenViewer(context, index),
      child: Container(
        height: 200.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (isImage)
                Image.network(
                  media['url']!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildMediaLoader();
                  },
                  errorBuilder:
                      (context, error, stackTrace) => _buildMediaError(),
                )
              else
                _buildVideoThumbnail(media['url']!),

              // Media type indicator
              Positioned(
                top: 12.h,
                right: 12.w,
                child: _buildMediaTypeIndicator(media['type']),
              ),

              // Actions overlay
              Positioned(
                bottom: 12.h,
                left: 12.w,
                right: 12.w,
                child: _buildMediaActions(context, media, index),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridMediaItem(
    BuildContext context,
    Map<String, String> media,
    int index,
  ) {
    final isImage = _isImage(media['type']);

    return GestureDetector(
      onTap: () => _openFullScreenViewer(context, index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (isImage)
                Image.network(
                  media['url']!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildMediaLoader();
                  },
                  errorBuilder:
                      (context, error, stackTrace) => _buildMediaError(),
                )
              else
                _buildVideoThumbnail(media['url']!),

              // Media type indicator
              Positioned(
                top: 8.h,
                right: 8.w,
                child: _buildMediaTypeIndicator(media['type'], small: true),
              ),

              // Index indicator for multiple items
              if (mediaList.length > 1)
                Positioned(
                  top: 8.h,
                  left: 8.w,
                  child: Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreMediaCard(BuildContext context) {
    final remainingCount = mediaList.length - 3;

    return GestureDetector(
      onTap: () => _showAllMediaDialog(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 32.sp,
              color: AppColors.primaryColor,
            ),
            SizedBox(height: 8.h),
            Text(
              '+$remainingCount',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            Text(
              'المزيد',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaTypeIndicator(String? type, {bool small = false}) {
    IconData icon;
    Color color;
    String label;

    if (_isImage(type)) {
      icon = Icons.image;
      color = Colors.blue;
      label = 'صورة';
    } else if (_isVideo(type)) {
      icon = Icons.videocam;
      color = Colors.red;
      label = 'فيديو';
    } else {
      icon = Icons.attachment;
      color = Colors.grey;
      label = 'ملف';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6.w : 8.w,
        vertical: small ? 3.h : 4.h,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(small ? 8.r : 12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: small ? 12.sp : 14.sp),
          if (!small) ...[
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVideoThumbnail(String videoUrl) {
    return Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video placeholder or actual thumbnail
          Container(
            color: Colors.grey[800],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_circle_fill,
                    size: 48.sp,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'فيديو',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaActions(
    BuildContext context,
    Map<String, String> media,
    int index,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _shareMedia(media),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(Icons.share, color: Colors.white, size: 16.sp),
            ),
          ),
          GestureDetector(
            onTap: () => _openFullScreenViewer(context, index),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(Icons.fullscreen, color: Colors.white, size: 16.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaStats() {
    final imageCount =
        mediaList.where((media) => _isImage(media['type'])).length;
    final videoCount =
        mediaList.where((media) => _isVideo(media['type'])).length;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          if (imageCount > 0) ...[
            Icon(Icons.image, color: Colors.blue, size: 16.sp),
            SizedBox(width: 4.w),
            Text(
              '$imageCount ${imageCount == 1 ? 'صورة' : 'صور'}',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
            ),
          ],
          if (imageCount > 0 && videoCount > 0) ...[
            SizedBox(width: 16.w),
            Container(width: 1, height: 16.h, color: Colors.grey[300]),
            SizedBox(width: 16.w),
          ],
          if (videoCount > 0) ...[
            Icon(Icons.videocam, color: Colors.red, size: 16.sp),
            SizedBox(width: 4.w),
            Text(
              '$videoCount ${videoCount == 1 ? 'فيديو' : 'فيديوهات'}',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoMediaCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 48.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 12.h),
          Text(
            'لا توجد وسائط مرفقة',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          Text(
            'لم يتم إرفاق أي صور أو فيديوهات مع هذا البلاغ',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMediaLoader() {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
        ),
      ),
    );
  }

  Widget _buildMediaError() {
    return Container(
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 32.sp, color: Colors.grey[400]),
          SizedBox(height: 8.h),
          Text(
            'فشل في تحميل الوسائط',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  bool _isImage(String? type) {
    return type?.toLowerCase().startsWith('image') ?? false;
  }

  bool _isVideo(String? type) {
    return type?.toLowerCase().startsWith('video') ?? false;
  }

  void _openFullScreenViewer(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => _FullScreenMediaGallery(
              mediaList: mediaList,
              initialIndex: initialIndex,
            ),
      ),
    );
  }

  void _showAllMediaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      children: [
                        Text(
                          'جميع الوسائط (${mediaList.length})',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: mediaList.length,
                      itemBuilder: (dialogContext, index) {
                        return _buildGridMediaItem(
                          dialogContext,
                          mediaList[index],
                          index,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
    );
  }

  void _shareMedia(Map<String, String> media) async {
    try {
      await Share.shareUri(Uri.parse(media['url']!));
    } catch (e) {
      debugPrint('Error sharing media: $e');
    }
  }

  void _shareAllMedia() async {
    try {
      final urls = mediaList.map((media) => media['url']!).join('\n');
      await Share.share('وسائط البلاغ #$reportId:\n\n$urls');
    } catch (e) {
      debugPrint('Error sharing all media: $e');
    }
  }
}

class _FullScreenMediaGallery extends StatefulWidget {
  final List<Map<String, String>> mediaList;
  final int initialIndex;

  const _FullScreenMediaGallery({
    required this.mediaList,
    required this.initialIndex,
  });

  @override
  State<_FullScreenMediaGallery> createState() =>
      _FullScreenMediaGalleryState();
}

class _FullScreenMediaGalleryState extends State<_FullScreenMediaGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '${_currentIndex + 1} من ${widget.mediaList.length}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () => _shareCurrentMedia(),
            icon: const Icon(Icons.share, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.mediaList.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final media = widget.mediaList[index];
              final isImage =
                  media['type']?.toLowerCase().startsWith('image') ?? false;

              if (isImage) {
                return InteractiveViewer(
                  child: Center(
                    child: Image.network(
                      media['url']!,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, color: Colors.white, size: 48),
                              SizedBox(height: 16),
                              Text(
                                'فشل في تحميل الصورة',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              } else {
                // Video placeholder - would need video player package
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_circle_fill,
                        size: 80.sp,
                        color: Colors.white,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'فيديو',
                        style: TextStyle(color: Colors.white, fontSize: 18.sp),
                      ),
                      SizedBox(height: 8.h),
                      ElevatedButton(
                        onPressed: () => _openExternalPlayer(media['url']!),
                        child: const Text('تشغيل'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),

          // Page indicators
          if (widget.mediaList.length > 1)
            Positioned(
              bottom: 50.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.mediaList.length,
                  (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _currentIndex == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _shareCurrentMedia() async {
    try {
      final currentMedia = widget.mediaList[_currentIndex];
      await Share.shareUri(Uri.parse(currentMedia['url']!));
    } catch (e) {
      debugPrint('Error sharing media: $e');
    }
  }

  void _openExternalPlayer(String videoUrl) async {
    // Would implement video player or external app opening
    debugPrint('Opening video: $videoUrl');
  }
}
