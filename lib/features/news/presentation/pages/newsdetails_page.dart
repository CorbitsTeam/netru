import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/constants/app_assets.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:netru_app/features/news/data/models/news_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailsScreen extends StatelessWidget {
  final NewsModel news;

  const NewsDetailsScreen({
    super.key,
    required this.news,
  });

  @override
  Widget build(BuildContext context) {
    return NewsDetailsView(news: news);
  }
}

class NewsDetailsView extends StatefulWidget {
  final NewsModel news;

  const NewsDetailsView({
    super.key,
    required this.news,
  });

  @override
  State<NewsDetailsView> createState() =>
      _NewsDetailsViewState();
}

class _NewsDetailsViewState
    extends State<NewsDetailsView>
    with TickerProviderStateMixin {
  final ScrollController _scrollController =
      ScrollController();
  late AnimationController
  _fabAnimationController;
  late AnimationController
  _contentAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isScrolled = false;
  final bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _contentAnimationController =
        AnimationController(
          duration: const Duration(
            milliseconds: 800,
          ),
          vsync: this,
        );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Curves.easeIn,
      ),
    );

    _contentAnimationController.forward();
    Future.delayed(
      const Duration(milliseconds: 500),
      () {
        if (mounted) {
          _fabAnimationController.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fabAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isScrolled =
        _scrollController.offset > 100;
    if (isScrolled != _isScrolled) {
      setState(() => _isScrolled = isScrolled);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildNewsDetailsScreen(widget.news);
  }

  Widget _buildNewsDetailsScreen(NewsModel news) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildModernAppBar(),
          SliverToBoxAdapter(
            child: _buildContent(news),
          ),
        ],
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 55.h,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.primary,
          size: 22.sp,
        ),
        onPressed:
            () => Navigator.of(context).pop(),
      ),
      title: Text(
        'تفاصيل الخبر',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildContent(NewsModel news) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          color: AppColors.background,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // الصورة
              _buildNewsImage(news),

              // محتوى الخبر بترتيب محسن
              _buildNewsHeader(news),
              _buildNewsContent(news),

              if (news.detailsUrl != null &&
                  news
                      .detailsUrl!
                      .isNotEmpty) ...[
                SizedBox(height: 16.h),
                _buildNewsMetadata(news),
              ],

              SizedBox(height: 16.h),
              _buildActionButtons(news),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsHeader(NewsModel news) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // Category and Date Section
            _buildCategoryAndDate(news),
            SizedBox(height: 8.h),
            // Title Section
            _buildTitle(news),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryAndDate(NewsModel news) {
    return Row(
      children: [
        if (news.category.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 6.h,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(
                    0.8,
                  ),
                  AppColors.primary,
                ],
              ),
              borderRadius: BorderRadius.circular(
                4.r,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(
                    0.3,
                  ),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              news.category,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule_rounded,
                color: AppColors.textSecondary,
                size: 14.sp,
              ),
              SizedBox(width: 5.w),
              Text(
                news.date,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(NewsModel news) {
    return Text(
      news.title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildNewsImage(NewsModel news) {
    if (news.image == null ||
        news.image!.isEmpty) {
      return _buildPlaceholderImage();
    }

    return Container(
      width: double.infinity,
      height: 240.h,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(
              0.2,
            ),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.network(
              news.image!,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              isAntiAlias: true,
              loadingBuilder: (
                context,
                child,
                loadingProgress,
              ) {
                if (loadingProgress == null) {
                  return child;
                }
                return _buildImageLoadingState(
                  loadingProgress,
                );
              },
              errorBuilder:
                  (context, error, stackTrace) =>
                      _buildPlaceholderImage(),
            ),
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24.r),
                bottomRight: Radius.circular(
                  24.r,
                ),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 240.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.surfaceVariant,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(
              0.15,
            ),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter:
                  _BackgroundPatternPainter(),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.surface
                        .withOpacity(0.9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary
                          .withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow
                            .withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(
                          0,
                          4,
                        ),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.article_outlined,
                    size: 32.sp,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface
                        .withOpacity(0.9),
                    borderRadius:
                        BorderRadius.circular(
                          16.r,
                        ),
                  ),
                  child: Text(
                    'خبر وزارة الداخلية',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageLoadingState(
    ImageChunkEvent loadingProgress,
  ) {
    return Container(
      width: double.infinity,
      height: 240.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
        color: AppColors.surfaceVariant,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            CircularProgressIndicator.adaptive(
              backgroundColor: AppColors.primary
                  .withOpacity(0.2),
              valueColor:
                  const AlwaysStoppedAnimation(
                    AppColors.primary,
                  ),
              strokeWidth: 2.5,
              value:
                  loadingProgress
                              .expectedTotalBytes !=
                          null
                      ? loadingProgress
                              .cumulativeBytesLoaded /
                          loadingProgress
                              .expectedTotalBytes!
                      : null,
            ),
            SizedBox(height: 12.h),
            Text(
              'تحميل الصورة...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsContent(NewsModel news) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              news.content,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textPrimary,
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsMetadata(NewsModel news) {
    if (news.detailsUrl == null ||
        news.detailsUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary
                        .withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(
                          8.r,
                        ),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                    size: 16.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  'معلومات إضافية',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _buildSourceCard(news),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceCard(NewsModel news) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _launchUrl(news.detailsUrl!),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(
                  0.03,
                ),
                AppColors.primary.withOpacity(
                  0.01,
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(
              12.r,
            ),
            border: Border.all(
              color: AppColors.primary
                  .withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppColors.primary
                      .withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(6.r),
                ),
                child: Icon(
                  Icons.open_in_new_rounded,
                  color: AppColors.primary,
                  size: 14.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'مصدر الخبر',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight:
                                FontWeight.w600,
                            color:
                                AppColors
                                    .textPrimary,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.touch_app_rounded,
                          size: 12.sp,
                          color:
                              AppColors.primary,
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      news.detailsUrl!,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.primary,
                        fontWeight:
                            FontWeight.w500,
                        decoration:
                            TextDecoration
                                .underline,
                      ),
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(NewsModel news) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary
                        .withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(
                          8.r,
                        ),
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
                    onPressed:
                        () => _shareNews(news),
                    icon: Icons.share_rounded,
                    label: 'مشاركة',
                    isPrimary: true,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _buildModernButton(
                    onPressed:
                        () => _copyToClipboard(
                          news,
                        ),
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
          padding: EdgeInsets.symmetric(
            vertical: 12.h,
          ),
          decoration: BoxDecoration(
            color:
                isPrimary
                    ? AppColors.primary
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(
              12.r,
            ),
            border:
                isPrimary
                    ? null
                    : Border.all(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
            boxShadow:
                isPrimary
                    ? [
                      BoxShadow(
                        color: AppColors.primary
                            .withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(
                          0,
                          3,
                        ),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15.sp,
                color:
                    isPrimary
                        ? Colors.white
                        : AppColors.primary,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color:
                      isPrimary
                          ? Colors.white
                          : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareNews(NewsModel news) {
    String shareText = '''
${news.title}

${news.summary}

تاريخ النشر: ${news.date}
''';

    if (news.detailsUrl != null &&
        news.detailsUrl!.isNotEmpty) {
      shareText +=
          '\nرابط المصدر: ${news.detailsUrl}';
    }

    Share.share(shareText);
  }

  void _copyToClipboard(NewsModel news) {
    String copyText = '''
${news.title}

${news.summary}

${news.content}

تاريخ النشر: ${news.date}
''';

    if (news.detailsUrl != null &&
        news.detailsUrl!.isNotEmpty) {
      copyText +=
          '\nرابط المصدر: ${news.detailsUrl}';
    }

    Clipboard.setData(
      ClipboardData(text: copyText),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 18.sp,
            ),
            SizedBox(width: 10.w),
            Text(
              'تم نسخ محتوى الخبر',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(14.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            12.r,
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      // إضافة http:// إذا لم يكن موجود
      String formattedUrl = url;
      if (!url.startsWith('http://') &&
          !url.startsWith('https://')) {
        formattedUrl = 'https://$url';
      }

      final Uri uri = Uri.parse(formattedUrl);

      // استخدام launchUrl مع إعدادات محسنة لتجنب التحذيرات
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        _showErrorSnackBar('لا يمكن فتح الرابط');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(
          'حدث خطأ في فتح الرابط',
        );
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 18.sp,
            ),
            SizedBox(width: 10.w),
            Text(
              message,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(14.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            12.r,
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _BackgroundPatternPainter
    extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.primary.withOpacity(
            0.05,
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;

    const spacing = 35.0;

    // Draw diagonal lines
    for (
      double i = -size.height;
      i < size.width + size.height;
      i += spacing
    ) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }

    // Draw dots
    final dotPaint =
        Paint()
          ..color = AppColors.primary.withOpacity(
            0.08,
          )
          ..style = PaintingStyle.fill;

    for (
      double x = 0;
      x < size.width;
      x += spacing * 2
    ) {
      for (
        double y = 0;
        y < size.height;
        y += spacing * 2
      ) {
        canvas.drawCircle(
          Offset(x, y),
          1.5,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) => false;
}
