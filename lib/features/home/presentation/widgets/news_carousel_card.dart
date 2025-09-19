import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/features/newsdetails/presentation/cubit/news_cubit.dart';
import 'package:netru_app/features/newsdetails/presentation/cubit/news_state.dart';
import 'package:netru_app/features/newsdetails/presentation/pages/newsdetails_page.dart';
import 'package:netru_app/features/newsdetails/data/models/news_model.dart';

class NewsCarouselCard extends StatefulWidget {
  const NewsCarouselCard({super.key});

  @override
  State<NewsCarouselCard> createState() => _NewsCarouselCardState();
}

class _NewsCarouselCardState extends State<NewsCarouselCard>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _slideController;
  late AnimationController _dotController;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();

    // إعداد animation controller للـ slide
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // إعداد animation controller للنقط
    _dotController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // بدء الـ animation
    _slideController.forward();
    _dotController.forward();

    // تحميل الأخبار المميزة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsCubit>().loadFeaturedNews();
    });
  }

  void _startAutoSlide(int length) {
    if (length <= 1) return;

    // إلغاء أي مؤقت سابق
    _autoSlideTimer?.cancel();

    // إنشاء مؤقت جديد
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _changeSlide(length);
      } else {
        timer.cancel();
      }
    });
  }

  void _changeSlide(int length) async {
    // slide out للصورة الحالية
    await _slideController.reverse();

    setState(() {
      _currentIndex = (_currentIndex + 1) % length;
    });

    // slide in للصورة الجديدة
    _slideController.forward();

    // تحريك النقط
    _dotController.reset();
    _dotController.forward();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _slideController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewsCubit, NewsState>(
      builder: (context, state) {
        if (state is NewsLoading) {
          return _buildLoadingCarousel();
        }

        if (state is NewsError) {
          return _buildErrorCarousel();
        }

        if (state is NewsLoaded) {
          if (state.newsList.isEmpty) {
            return _buildEmptyCarousel();
          }

          final newsToShow = state.newsList.take(3).toList();

          // بدء الانتقال التلقائي إذا لم يكن قد بدأ بعد
          if (newsToShow.length > 1 && _autoSlideTimer == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _startAutoSlide(newsToShow.length);
            });
          }

          return _buildNewsCarousel(newsToShow);
        }

        return _buildEmptyCarousel();
      },
    );
  }

  Widget _buildLoadingCarousel() {
    return Container(
      width: double.infinity,
      height: 180.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.grey[200],
      ),
      child: Center(
        child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 2.w),
      ),
    );
  }

  Widget _buildErrorCarousel() {
    return Container(
      width: double.infinity,
      height: 180.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.red.withOpacity(0.1),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 32.sp),
            SizedBox(height: 8.h),
            Text(
              'خطأ في تحميل الأخبار',
              style: TextStyle(fontSize: 14.sp, color: Colors.red[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCarousel() {
    return Container(
      width: double.infinity,
      height: 180.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.grey[200],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, color: Colors.grey[600], size: 32.sp),
            SizedBox(height: 8.h),
            Text(
              'لا توجد أخبار',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCarousel(List<NewsModel> newsList) {
    return InkWell(
      onTap: () => _navigateToNewsDetails(newsList[_currentIndex]),
      child: Container(
        width: double.infinity,
        height: 190.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Stack(
            children: [
              // الصورة الخلفية مع الـ slide animation
              ...List.generate(newsList.length, (index) {
                return Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: index == _currentIndex ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: CachedNetworkImage(
                      imageUrl: newsList[index].imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }),

              // طبقة شفافة سوداء للنص
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),

              // المحتوى النصي والنقط
              Positioned(
                bottom: 16.h,
                left: 16.w,
                right: 16.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // التاريخ مع النقط في نفس الصف
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // التاريخ
                        Text(
                          DateFormat.yMMMd('ar').format(
                            DateTime.parse(
                              newsList[_currentIndex].date,
                            ).toLocal(),
                          ),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          textDirection: TextDirection.rtl,
                        ),

                        // النقط المتحركة
                        Row(
                          children: List.generate(
                            newsList.length,
                            (index) => AnimatedBuilder(
                              animation: _dotController,
                              builder: (context, child) {
                                return Container(
                                  margin: EdgeInsets.only(left: 6.w),
                                  child: AnimatedContainer(
                                    duration: Duration(
                                      milliseconds:
                                          index == _currentIndex ? 300 : 150,
                                    ),
                                    width: index == _currentIndex ? 16.w : 6.w,
                                    height: 6.h,
                                    decoration: BoxDecoration(
                                      color:
                                          index == _currentIndex
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(3.r),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8.h),

                    // العنوان
                    Text(
                      newsList[_currentIndex].title!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
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

  Widget _buildNewsImage(NewsModel news) {
    if (news.image != null && news.image!.isNotEmpty) {
      return Image.network(
        news.image!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackImage();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.w,
            ),
          );
        },
      );
    } else {
      return _buildFallbackImage();
    }
  }

  Widget _buildFallbackImage() {
    return Container(
      color: Colors.grey[400],
      child: Center(
        child: Icon(Icons.article_outlined, size: 48.sp, color: Colors.white),
      ),
    );
  }

  void _navigateToNewsDetails(NewsModel news) {
    // الانتقال إلى صفحة التفاصيل
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => NewsDetailsScreen(news: news)),
    );
  }
}
