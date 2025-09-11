import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/features/newsdetails/presentation/cubit/news_cubit.dart';
import 'package:netru_app/features/newsdetails/presentation/cubit/news_state.dart';
import 'package:netru_app/features/newsdetails/presentation/widgets/news_header_widget.dart';
import 'package:netru_app/features/newsdetails/presentation/widgets/news_content_widget.dart';

class NewsDetailsScreen extends StatelessWidget {
  const NewsDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<NewsCubit, NewsState>(
        builder: (context, state) {
          if (state is NewsLoading) {
            return _buildLoadingState(context);
          }

          if (state is NewsError) {
            return _buildErrorState(
                context, state.message);
          }

          if (state is NewsLoaded &&
              state.selectedNews != null) {
            final news = state.selectedNews!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  // الهيدر مع الصورة
                  NewsHeaderWidget(
                    image: news.image,
                    onBackPressed: () =>
                        Navigator.of(context)
                            .pop(),
                  ),

                  // المحتوى
                  Transform.translate(
                    offset: Offset(0, -25.h),
                    child: NewsContentWidget(
                        news: news),
                  ),
                ],
              ),
            );
          }

          return _buildNotFoundState(context);
        },
      ),
    );
  }

  Widget _buildLoadingState(
      BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'تحميل...',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            print(
                "Back button pressed from loading");
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: 20.sp,
          ),
          tooltip: 'رجوع',
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.blue,
              strokeWidth: 3.w,
            ),
            SizedBox(height: 16.h),
            Text(
              'جاري تحميل التفاصيل...',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, String message) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'خطأ',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.red[700],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            print(
                "Back button pressed from error");
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: 20.sp,
          ),
          tooltip: 'رجوع',
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 24.w),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color:
                      Colors.red.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(50.r),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 48.sp,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'عذراً، حدث خطأ!',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        print(
                            "Back button pressed");
                        Navigator.of(context)
                            .pop();
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        size: 18.sp,
                        color: Colors.white,
                      ),
                      label: Text(
                        'العودة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton
                          .styleFrom(
                        backgroundColor:
                            Colors.blue,
                        padding:
                            EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 16.h,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(12.r),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        print(
                            "Retry button pressed");
                        final newsCubit = context
                            .read<NewsCubit>();
                        newsCubit.loadNews();
                      },
                      icon: Icon(
                        Icons.refresh,
                        size: 18.sp,
                        color: Colors.blue,
                      ),
                      label: Text(
                        'إعادة المحاولة',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16.sp,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton
                          .styleFrom(
                        side: BorderSide(
                          color: Colors.blue,
                          width: 1.5,
                        ),
                        padding:
                            EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 16.h,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotFoundState(
      BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'غير موجود',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            print(
                "Back button pressed from not found");
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: 20.sp,
          ),
          tooltip: 'رجوع',
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 24.w),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.grey
                      .withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(50.r),
                ),
                child: Icon(
                  Icons.article_outlined,
                  size: 48.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'الخبر غير موجود',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                'لم يتم العثور على الخبر المطلوب.\nربما تم حذفه أو نقله.',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        print(
                            "Home button pressed");
                        Navigator.of(context)
                            .popUntil((route) =>
                                route.isFirst);
                      },
                      icon: Icon(
                        Icons.home,
                        size: 18.sp,
                        color: Colors.white,
                      ),
                      label: Text(
                        'الصفحة الرئيسية',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton
                          .styleFrom(
                        backgroundColor:
                            Colors.blue,
                        padding:
                            EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 16.h,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(12.r),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        print(
                            "Back button pressed from not found body");
                        Navigator.of(context)
                            .pop();
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        size: 18.sp,
                        color: Colors.blue,
                      ),
                      label: Text(
                        'رجوع',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16.sp,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton
                          .styleFrom(
                        side: BorderSide(
                          color: Colors.blue,
                          width: 1.5,
                        ),
                        padding:
                            EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 16.h,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
