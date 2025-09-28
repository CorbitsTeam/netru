import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'multiple_media_viewer.dart';

/// Compact expandable media section for report details
class CompactMediaSection extends StatefulWidget {
  final List<Map<String, String>> mediaList;
  final String reportId;

  const CompactMediaSection({
    super.key,
    required this.mediaList,
    required this.reportId,
  });

  @override
  State<CompactMediaSection> createState() => _CompactMediaSectionState();
}

class _CompactMediaSectionState extends State<CompactMediaSection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mediaList.isEmpty) {
      return _buildNoMediaCard();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            spreadRadius: 1.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _expandAnimation.value,
                  child: child,
                ),
              );
            },
            child: _buildExpandedContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final mediaCount = widget.mediaList.length;
    final imageCount =
        widget.mediaList.where((media) => _isImage(media['type'])).length;
    final videoCount = mediaCount - imageCount;

    return InkWell(
      onTap: _toggleExpansion,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            // Media icon and preview
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.collections,
                    size: 24.sp,
                    color: AppColors.primaryColor,
                  ),
                  if (mediaCount > 1)
                    Positioned(
                      top: 4.h,
                      right: 4.w,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '$mediaCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            // Media info
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
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      if (imageCount > 0) ...[
                        Icon(Icons.image, size: 16.sp, color: Colors.blue[600]),
                        SizedBox(width: 4.w),
                        Text(
                          '$imageCount ${imageCount == 1 ? 'صورة' : 'صور'}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.blue[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (videoCount > 0) ...[
                        if (imageCount > 0) ...[
                          SizedBox(width: 12.w),
                          Text(
                            '•',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                        ],
                        Icon(
                          Icons.videocam,
                          size: 16.sp,
                          color: Colors.red[600],
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '$videoCount ${videoCount == 1 ? 'فيديو' : 'فيديوهات'}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.red[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Expand/Collapse button
            AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 20.sp,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Column(
        children: [
          // Divider
          Container(
            height: 1.h,
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey[300]!,
                  Colors.grey[100]!,
                  Colors.grey[300]!,
                ],
              ),
            ),
          ),
          // Full media viewer
          MultipleMediaViewer(
            mediaList: widget.mediaList,
            reportId: widget.reportId,
            isCompactMode: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNoMediaCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 24.sp,
            color: Colors.grey[400],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لا توجد وسائط مرفقة',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'لم يتم إرفاق أي صور أو فيديوهات مع هذا البلاغ',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isImage(String? type) {
    if (type == null) return false;
    return type.toLowerCase().contains('image') ||
        [
          'jpg',
          'jpeg',
          'png',
          'gif',
          'bmp',
          'webp',
        ].contains(type.toLowerCase());
  }
}
