import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/features/newsdetails/presentation/cubit/news_cubit.dart';
import 'package:netru_app/features/newsdetails/presentation/cubit/news_state.dart';
import 'package:netru_app/features/newsdetails/presentation/pages/newsdetails_page.dart';

class CarouselCard extends StatefulWidget {
  const CarouselCard({super.key});

  @override
  State<CarouselCard> createState() =>
      _CarouselCardState();
}

class _CarouselCardState
    extends State<CarouselCard>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _slideController;
  late AnimationController _dotController;
  late Animation<Offset> _slideAnimation;
  List<Map<String, String>> _carouselData = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadNewsData();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _dotController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    _slideController.forward();
    _dotController.forward();
  }

  void _loadNewsData() {
    // تحميل الأخبار إذا لم تكن محملة بالفعل
    final newsCubit = context.read<NewsCubit>();
    if (newsCubit.state is! NewsLoaded) {
      newsCubit.loadNews();
    }
  }

  void _startAutoSlide() {
    Future.delayed(const Duration(seconds: 3),
        () {
      if (mounted && _carouselData.isNotEmpty) {
        _changeSlide();
        _startAutoSlide();
      }
    });
  }

  void _changeSlide() async {
    if (_carouselData.isEmpty) return;

    await _slideController.reverse();
    setState(() {
      _currentIndex = (_currentIndex + 1) %
          _carouselData.length;
    });
    _slideController.forward();
    _dotController.reset();
    _dotController.forward();
  }

  void _handleTap(String newsId) {
    final newsCubit = context.read<NewsCubit>();
    newsCubit.selectNews(newsId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: newsCubit,
          child: const NewsDetailsScreen(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NewsCubit, NewsState>(
      listener: (context, state) {
        if (state is NewsLoaded) {
          setState(() {
            _carouselData = context
                .read<NewsCubit>()
                .getCarouselData();
          });
          if (_carouselData.isNotEmpty) {
            _startAutoSlide();
          }
        }
      },
      builder: (context, state) {
        if (state is NewsLoading) {
          return _buildLoadingState();
        }

        if (state is NewsError) {
          return _buildErrorState(state.message);
        }

        if (_carouselData.isEmpty) {
          return _buildEmptyState();
        }

        return _buildCarousel();
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      height: 180.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.grey.withValues(alpha: 0.2),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
          strokeWidth: 2.w,
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      width: double.infinity,
      height: 180.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.red.withValues(alpha: 0.1),
        border: Border.all(
            color: Colors.red
                .withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 32.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(
                color: Colors.red,
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      height: 180.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.grey.withValues(alpha: 0.1),
      ),
      child: Center(
        child: Text(
          'لا توجد أخبار متاحة',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    return GestureDetector(
      onTap: () => _handleTap(
          _carouselData[_currentIndex]['id']!),
      child: Container(
        width: double.infinity,
        height: 180.h,
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(12.r),
          child: Stack(
            children: [
              // الصور المتحركة
              ...List.generate(
                  _carouselData.length, (index) {
                return Positioned.fill(
                  child: AnimatedOpacity(
                    opacity:
                        index == _currentIndex
                            ? 1.0
                            : 0.0,
                    duration: const Duration(
                        milliseconds: 300),
                    child: Image.asset(
                      _carouselData[index]
                          ['image']!,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }),

              // طبقة شفافة للنص
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black
                            .withOpacity(0.7),
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
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // التاريخ والنقط
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        Text(
                          _carouselData[
                                  _currentIndex]
                              ['date']!,
                          style: TextStyle(
                            color: Colors.white
                                .withOpacity(0.8),
                            fontSize: 12.sp,
                            fontWeight:
                                FontWeight.w500,
                          ),
                          textDirection:
                              TextDirection.rtl,
                        ),
                        Row(
                          children: List.generate(
                            _carouselData.length,
                            (index) =>
                                AnimatedBuilder(
                              animation:
                                  _dotController,
                              builder: (context,
                                  child) {
                                return Container(
                                  margin: EdgeInsets
                                      .only(
                                          left: 6
                                              .w),
                                  child:
                                      AnimatedContainer(
                                    duration:
                                        Duration(
                                      milliseconds:
                                          index ==
                                                  _currentIndex
                                              ? 300
                                              : 150,
                                    ),
                                    width: index ==
                                            _currentIndex
                                        ? 16.w
                                        : 6.w,
                                    height: 6.h,
                                    decoration:
                                        BoxDecoration(
                                      color: index ==
                                              _currentIndex
                                          ? Colors
                                              .white
                                          : Colors
                                              .white
                                              .withOpacity(0.5),
                                      borderRadius:
                                          BorderRadius.circular(
                                              3.r),
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
                      _carouselData[_currentIndex]
                          ['title']!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight:
                            FontWeight.bold,
                        height: 1.2,
                      ),
                      textDirection:
                          TextDirection.rtl,
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
}
