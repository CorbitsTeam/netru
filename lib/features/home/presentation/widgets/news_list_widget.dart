import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/features/newsdetails/presentation/cubit/news_cubit.dart';
import 'package:netru_app/features/newsdetails/presentation/cubit/news_state.dart';
import 'package:netru_app/features/newsdetails/presentation/pages/newsdetails_page.dart';
import 'package:netru_app/features/newsdetails/data/models/news_model.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/routes.dart';

class NewsListWidget extends StatefulWidget {
  final int maxItems;
  final bool showHeader;
  final String headerTitle;

  const NewsListWidget({
    super.key,
    this.maxItems = 5,
    this.showHeader = true,
    this.headerTitle = 'أحدث الأخبار',
  });

  @override
  State<NewsListWidget> createState() => _NewsListWidgetState();
}

class _NewsListWidgetState extends State<NewsListWidget> {
  @override
  void initState() {
    super.initState();
    // تحميل الأخبار عند إنشاء الويدجت
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsCubit>().loadNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewsCubit, NewsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showHeader) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.headerTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  if (state is NewsLoaded &&
                      state.newsList.length > widget.maxItems)
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.allNewsPage);
                      },
                      child: Text(
                        'عرض الكل',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 10.h),
            ],
            _buildNewsContent(state),
          ],
        );
      },
    );
  }

  Widget _buildNewsContent(NewsState state) {
    if (state is NewsLoading) {
      return _buildLoadingState();
    }

    if (state is NewsError) {
      return _buildErrorState(state.message);
    }

    if (state is NewsLoaded) {
      if (state.newsList.isEmpty) {
        return _buildEmptyState();
      }

      final newsToShow = state.newsList.take(widget.maxItems).toList();
      return _buildNewsList(newsToShow);
    }

    return _buildEmptyState();
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200.h,
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
          strokeWidth: 2.w,
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      height: 200.h, // Increased height to accommodate longer error messages
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: SingleChildScrollView(
            // Added scrollable container
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Don't expand to full height
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 32.sp),
                SizedBox(height: 8.h),
                Text(
                  'خطأ في تحميل الأخبار',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[700],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  message.length > 150
                      ? '${message.substring(0, 150)}...'
                      : message, // Truncate long messages
                  style: TextStyle(fontSize: 12.sp, color: Colors.red[600]),
                  textAlign: TextAlign.center,
                  maxLines: 3, // Limit to 3 lines
                  overflow: TextOverflow.ellipsis, // Handle overflow gracefully
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 150.h,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, color: Colors.grey[600], size: 32.sp),
            SizedBox(height: 8.h),
            Text(
              'لا توجد أخبار',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsList(List<NewsModel> newsList) {
    return Column(
      children: newsList.map((news) => _buildNewsCard(news)).toList(),
    );
  }

  Widget _buildNewsCard(NewsModel news) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToNewsDetails(news),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة الخبر أو placeholder
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: Colors.grey[200],
                ),
                child:
                    news.image != null && news.image!.isNotEmpty
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.network(
                            news.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage();
                            },
                          ),
                        )
                        : _buildPlaceholderImage(),
              ),
              SizedBox(width: 12.w),
              // محتوى الخبر
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // التاريخ
                    Text(
                      news.date,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    // العنوان
                    Text(
                      news.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    // الملخص
                    Text(
                      news.summary,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[700],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(Icons.article_outlined, color: Colors.grey[600], size: 24.sp),
    );
  }

  void _navigateToNewsDetails(NewsModel news) {
    // الانتقال إلى صفحة التفاصيل
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => NewsDetailsScreen(news: news)),
    );
  }
}
