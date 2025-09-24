import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:netru_app/features/news/data/models/news_model.dart';
import 'package:netru_app/features/news/presentation/widgets/action_buttons_widget.dart';
import 'package:netru_app/features/news/presentation/widgets/modern_app_bar_widget.dart';
import 'package:netru_app/features/news/presentation/widgets/news_content_widget.dart';
import 'package:netru_app/features/news/presentation/widgets/news_header_widget.dart';
import 'package:netru_app/features/news/presentation/widgets/news_image_widget.dart';
import 'package:netru_app/features/news/presentation/widgets/news_metadata_widget.dart';

class NewsDetailsScreen extends StatelessWidget {
  final NewsModel news;

  const NewsDetailsScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return NewsDetailsView(news: news);
  }
}

class NewsDetailsView extends StatefulWidget {
  final NewsModel news;

  const NewsDetailsView({super.key, required this.news});

  @override
  State<NewsDetailsView> createState() => _NewsDetailsViewState();
}

class _NewsDetailsViewState extends State<NewsDetailsView>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fabAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Curves.easeIn,
      ),
    );

    _contentAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _fabAnimationController.forward();
      }
    });
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
    final isScrolled = _scrollController.offset > 100;
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
          const ModernAppBarWidget(title: 'تفاصيل الخبر'),
          SliverToBoxAdapter(child: _buildContent(news)),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الصورة
              NewsImageWidget(imageUrl: news.image),

              // محتوى الخبر بترتيب محسن
              NewsHeaderWidget(
                category: news.category,
                date: news.date,
                title: news.title,
              ),
              NewsContentWidget(content: news.content),

              if (news.detailsUrl != null && news.detailsUrl!.isNotEmpty) ...[
                SizedBox(height: 16.h),
                NewsMetadataWidget(detailsUrl: news.detailsUrl),
              ],

              SizedBox(height: 16.h),
              ActionButtonsWidget(news: news),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
