import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/di/injection_container.dart';
import 'package:netru_app/features/news/presentation/cubit/news_cubit.dart';
import 'package:netru_app/features/news/presentation/cubit/news_state.dart';
import 'package:netru_app/features/news/data/models/news_model.dart';
import 'package:netru_app/features/news/presentation/pages/newsdetails_page.dart';
import 'package:netru_app/features/news/presentation/widgets/news_card_widget.dart';
import 'package:netru_app/features/news/presentation/widgets/search_bar_widget.dart';
import 'package:netru_app/features/news/presentation/widgets/state_widgets.dart';
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
    _searchController.addListener(_onSearchChanged);
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
              fontSize: 16.sp,
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
              padding: EdgeInsets.all(12.w),
              decoration: const BoxDecoration(color: AppColors.primary),
              child: SearchBarWidget(
                controller: _searchController,
                onChanged:
                    (query) => setState(() {
                      _searchQuery = query;
                      _filterNews();
                    }),
              ),
            ),

            // قائمة الأخبار
            Expanded(
              child: BlocBuilder<NewsCubit, NewsState>(
                builder: (context, state) {
                  if (state is NewsLoading && _allNews.isEmpty) {
                    return const LoadingStateWidget();
                  }

                  if (state is NewsError && _allNews.isEmpty) {
                    return ErrorStateWidget(
                      message: state.message,
                      onRetry: () => context.read<NewsCubit>().loadNews(),
                    );
                  }

                  if (state is NewsLoaded) {
                    _allNews = state.newsList;
                    _filterNews();
                  }

                  if (_filteredNews.isEmpty && _searchQuery.isNotEmpty) {
                    return NoResultsStateWidget(query: _searchQuery);
                  }

                  if (_filteredNews.isEmpty) {
                    return const EmptyStateWidget();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<NewsCubit>().loadNews();
                    },
                    color: AppColors.primary,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
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
                        return NewsCardWidget(
                          news: _filteredNews[index],
                          onTap:
                              () =>
                                  _navigateToNewsDetails(_filteredNews[index]),
                        );
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

  void _navigateToNewsDetails(NewsModel news) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => NewsDetailsScreen(news: news)),
    );
  }
}
