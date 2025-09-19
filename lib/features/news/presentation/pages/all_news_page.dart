import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:netru_app/core/di/injection_container.dart';
import 'package:netru_app/features/news/presentation/cubit/news_cubit.dart';
import 'package:netru_app/features/news/presentation/cubit/news_state.dart';
import 'package:netru_app/features/news/data/models/news_model.dart';
import 'package:netru_app/features/news/presentation/pages/newsdetails_page.dart';

import '../../../../core/theme/app_colors.dart';

class AllNewsPage extends StatefulWidget {
  const AllNewsPage({super.key});

  @override
  State<AllNewsPage> createState() => _AllNewsPageState();
}

class _AllNewsPageState extends State<AllNewsPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<NewsModel> _filteredNews = [];
  List<NewsModel> _allNews = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // شغل مستمعات البحث والتمرير فقط هنا. تحميل الأخبار يُنفَّذ عند إنشاء الـ NewsCubit

    // إضافة مستمع للبحث
    _searchController.addListener(_onSearchChanged);

    // إضافة مستمع للتمرير للتحديث
    _scrollController.addListener(_onScroll);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterNews();
    });
  }

  void _filterNews() {
    if (_searchQuery.isEmpty) {
      _filteredNews = List.from(_allNews);
    } else {
      _filteredNews =
          _allNews.where((news) {
            final title = news.title.toLowerCase();
            final titleAr = news.titleAr?.toLowerCase() ?? '';
            final content = news.content.toLowerCase();
            final contentAr = news.contentAr?.toLowerCase() ?? '';
            final query = _searchQuery.toLowerCase();

            return title.contains(query) ||
                titleAr.contains(query) ||
                content.contains(query) ||
                contentAr.contains(query);
          }).toList();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // تحميل المزيد من الأخبار عند الوصول لنهاية القائمة
      context.read<NewsCubit>().loadNews();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = sl<NewsCubit>();
        // Load initial news page when cubit is created
        try {
          cubit.loadNews();
        } catch (_) {}
        return cubit;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            'جميع الأخبار',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // شريط البحث
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25.r),
                  bottomRight: Radius.circular(25.r),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ابحث في الأخبار...',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14.sp,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.primary,
                      size: 24.sp,
                    ),
                    suffixIcon:
                        _searchQuery.isNotEmpty
                            ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.grey[500],
                                size: 20.sp,
                              ),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 15.h,
                    ),
                  ),
                ),
              ),
            ),

            // قائمة الأخبار
            Expanded(
              child: BlocBuilder<NewsCubit, NewsState>(
                builder: (context, state) {
                  if (state is NewsLoading && _allNews.isEmpty) {
                    return _buildLoadingState();
                  }

                  if (state is NewsError && _allNews.isEmpty) {
                    return _buildErrorState(state.message);
                  }

                  if (state is NewsLoaded) {
                    _allNews = state.newsList;
                    _filterNews();
                  }

                  if (_filteredNews.isEmpty && _searchQuery.isNotEmpty) {
                    return _buildNoResultsState();
                  }

                  if (_filteredNews.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<NewsCubit>().loadNews();
                    },
                    color: AppColors.primary,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      itemCount: _filteredNews.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _filteredNews.length) {
                          // إظهار مؤشر التحميل في النهاية
                          return state is NewsLoading
                              ? Container(
                                padding: EdgeInsets.all(20.h),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                    strokeWidth: 2.w,
                                  ),
                                ),
                              )
                              : const SizedBox();
                        }
                        return _buildNewsCard(_filteredNews[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3.w),
          SizedBox(height: 16.h),
          Text(
            'جاري تحميل الأخبار...',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 64.sp),
            SizedBox(height: 16.h),
            Text(
              'خطأ في تحميل الأخبار',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () {
                context.read<NewsCubit>().loadNews();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text('إعادة المحاولة', style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, color: Colors.grey[400], size: 64.sp),
            SizedBox(height: 16.h),
            Text(
              'لا توجد نتائج',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'لم نجد أي أخبار تطابق بحثك عن "$_searchQuery"',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, color: Colors.grey[400], size: 64.sp),
            SizedBox(height: 16.h),
            Text(
              'لا توجد أخبار',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'لم يتم نشر أي أخبار بعد',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard(NewsModel news) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToNewsDetails(news),
        borderRadius: BorderRadius.circular(15.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة الخبر
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.r),
                topRight: Radius.circular(15.r),
              ),
              child: Container(
                width: double.infinity,
                height: 200.h,
                child:
                    news.image != null && news.image!.isNotEmpty
                        ? Image.network(
                          news.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2.w,
                              ),
                            );
                          },
                        )
                        : _buildPlaceholderImage(),
              ),
            ),

            // محتوى الخبر
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // التاريخ والمؤلف
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.grey[500],
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        _formatDate(news.publishedAt),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (news.sourceName != null) ...[
                        SizedBox(width: 16.w),
                        Icon(
                          Icons.person,
                          color: Colors.grey[500],
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            news.sourceName!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // العنوان
                  Text(
                    news.titleAr ?? news.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),

                  // المحتوى
                  Text(
                    news.contentAr ?? news.content,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12.h),

                  // شريط القراءة المزيد
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          'اقرأ المزيد',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.visibility,
                            color: Colors.grey[500],
                            size: 16.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${news.viewCount} مشاهدة',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          Icons.article_outlined,
          color: Colors.grey[600],
          size: 48.sp,
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'تاريخ غير محدد';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return DateFormat('dd/MM/yyyy').format(date);
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  void _navigateToNewsDetails(NewsModel news) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => NewsDetailsScreen(news: news)),
    );
  }
}
