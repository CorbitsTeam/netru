import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netru_app/features/news/domain/usecases/newsdetails_usecase.dart';
import 'package:netru_app/features/news/data/models/news_model.dart';
import 'package:netru_app/features/news/data/models/news_category_model.dart';
import 'package:netru_app/features/news/presentation/cubit/news_state.dart';

class NewsCubit extends Cubit<NewsState> {
  final NewsdetailsUseCase newsUseCase;

  NewsCubit(this.newsUseCase) : super(NewsInitial());

  Future<void> loadNews() async {
    emit(NewsLoading());
    try {
      final newsList = await newsUseCase.getNews();
      emit(NewsLoaded(newsList: newsList));
    } catch (e) {
      emit(NewsError(message: 'حدث خطأ في تحميل الأخبار: ${e.toString()}'));
    }
  }

  Future<void> selectNews(String newsId) async {
    final currentState = state;
    if (currentState is NewsLoaded) {
      try {
        final selectedNews = await newsUseCase.getNewsById(newsId);
        if (selectedNews != null) {
          emit(currentState.copyWith(selectedNews: selectedNews));
        } else {
          emit(const NewsError(message: 'لم يتم العثور على الخبر المطلوب'));
        }
      } catch (e) {
        emit(
          NewsError(message: 'حدث خطأ في تحميل تفاصيل الخبر: ${e.toString()}'),
        );
      }
    }
  }

  // البحث في الأخبار
  void searchNews(String query) {
    final currentState = state;
    if (currentState is NewsLoaded) {
      if (query.isEmpty) {
        // إعادة تحميل جميع الأخبار
        loadNews();
      } else {
        final filteredNews =
            currentState.newsList
                .where(
                  (news) =>
                      news.title.contains(query) ||
                      news.content.contains(query) ||
                      news.summary.contains(query),
                )
                .toList();
        emit(
          NewsLoaded(
            newsList: filteredNews,
            selectedNews: currentState.selectedNews,
          ),
        );
      }
    }
  }

  // تصفية الأخبار بالتصنيف
  void filterByCategory(String category) {
    final currentState = state;
    if (currentState is NewsLoaded) {
      if (category.isEmpty) {
        loadNews();
      } else {
        final filteredNews =
            currentState.newsList
                .where((news) => news.category == category)
                .toList();
        emit(
          NewsLoaded(
            newsList: filteredNews,
            selectedNews: currentState.selectedNews,
          ),
        );
      }
    }
  }

  // الحصول على الأخبار للـ Carousel
  List<Map<String, dynamic>> getCarouselData() {
    final currentState = state;
    if (currentState is NewsLoaded) {
      return currentState.newsList
          .map(
            (news) => {
              'id': news.id,
              'image': news.image ?? '',
              'title': news.title,
              'date': news.date,
            },
          )
          .toList();
    }
    return [];
  }

  // الحصول على خبر معين بالـ ID
  NewsModel? getNewsById(String id) {
    final currentState = state;
    if (currentState is NewsLoaded) {
      try {
        return currentState.newsList.firstWhere((news) => news.id == id);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // الحصول على الأخبار بتصنيف معين
  List<NewsModel> getNewsByCategory(String category) {
    final currentState = state;
    if (currentState is NewsLoaded) {
      return currentState.newsList
          .where((news) => news.category == category)
          .toList();
    }
    return [];
  }

  // الحصول على أحدث الأخبار
  List<NewsModel> getLatestNews({int limit = 3}) {
    final currentState = state;
    if (currentState is NewsLoaded) {
      final sortedNews = List<NewsModel>.from(currentState.newsList);
      // يمكن إضافة منطق ترتيب بناء على التاريخ هنا
      return sortedNews.take(limit).toList();
    }
    return [];
  }

  // الحصول على الأخبار المميزة للـ Carousel
  Future<void> loadFeaturedNews() async {
    emit(NewsLoading());
    try {
      final featuredNews = await newsUseCase.getFeaturedNews();
      emit(NewsLoaded(newsList: featuredNews));
    } catch (e) {
      emit(
        NewsError(message: 'حدث خطأ في تحميل الأخبار المميزة: ${e.toString()}'),
      );
    }
  }

  // الحصول على أخبار بتصنيف معين
  Future<void> loadNewsByCategory(int categoryId) async {
    emit(NewsLoading());
    try {
      final categoryNews = await newsUseCase.getNewsByCategory(categoryId);
      emit(NewsLoaded(newsList: categoryNews));
    } catch (e) {
      emit(
        NewsError(message: 'حدث خطأ في تحميل أخبار التصنيف: ${e.toString()}'),
      );
    }
  }

  // الحصول على تصنيفات الأخبار
  Future<List<NewsCategoryModel>> getNewsCategories() async {
    try {
      final categories = await newsUseCase.getNewsCategories();
      return categories;
    } catch (e) {
      print('❌ Error getting categories: $e');
      return [];
    }
  }
}
