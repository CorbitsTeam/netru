import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/constants/app_constants.dart';

class TrendingIssuesCard extends StatefulWidget {
  const TrendingIssuesCard({super.key});

  @override
  State<TrendingIssuesCard> createState() =>
      _TrendingIssuesCardState();
}

class _TrendingIssuesCardState
    extends State<TrendingIssuesCard>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // بيانات الصور والنصوص
  final List<Map<String, String>> _carouselData =
      [
    {
      'image': AppAssets.newsImages,
      'title':
          'القبض على عنصر إرهابي شديد الخطورة',
      'date': '15 رمضان 2024'
    },
    {
      'image': AppAssets.newsImage2,
      'title':
          'الإستجابة لحالات التسول في الاسواق',
      'date': '20 شوال 2024'
    },
    {
      'image': AppAssets.newsImages,
      'title':
          'الداخلية تقبض على شبكة احتيال إلكتروني',
      'date': '10 ذي الحجة 2024'
    },
  ];

  @override
  void initState() {
    super.initState();
    // إعداد animation controller للـ slide
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
    // بدء الـ animation الأولى
    _slideController.forward();
  }

  void _nextSlide() async {
    if (_currentIndex <
        _carouselData.length - 1) {
      // slide out للصورة الحالية
      await _slideController.reverse();
      setState(() {
        _currentIndex = _currentIndex + 1;
      });
      // slide in للصورة الجديدة
      _slideController.forward();
    }
  }

  void _previousSlide() async {
    if (_currentIndex > 0) {
      // slide out للصورة الحالية
      await _slideController.reverse();
      setState(() {
        _currentIndex = _currentIndex - 1;
      });
      // slide in للصورة الجديدة
      _slideController.forward();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180.h,
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
            ...List.generate(_carouselData.length,
                (index) {
              return Positioned.fill(
                child: AnimatedOpacity(
                  opacity: index == _currentIndex
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
            // طبقة شفافة سوداء للنص
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
            // السهم الأيسر
            if (_currentIndex > 0)
              Positioned(
                left: 12.w,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _previousSlide,
                    child: Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: Colors.black
                            .withValues(
                                alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ),
              ),
            // السهم الأيمن
            if (_currentIndex <
                _carouselData.length - 1)
              Positioned(
                right: 12.w,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _nextSlide,
                    child: Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: Colors.black
                            .withValues(
                                alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 18.sp,
                      ),
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
                  // التاريخ مع النقط في نفس الصف
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [
                      // التاريخ
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
                      ),

                      // النقط المتحركة
                      Row(
                        children: List.generate(
                          _carouselData.length,
                          (index) => Container(
                            margin:
                                EdgeInsets.only(
                                    left: 6.w),
                            child:
                                AnimatedContainer(
                              duration:
                                  const Duration(
                                      milliseconds:
                                          300),
                              width: index ==
                                      _currentIndex
                                  ? 16.w
                                  : 6.w,
                              height: 6.h,
                              decoration:
                                  BoxDecoration(
                                color: index ==
                                        _currentIndex
                                    ? Colors.white
                                    : Colors.white
                                        .withOpacity(
                                            0.5),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            3.r),
                              ),
                            ),
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
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
