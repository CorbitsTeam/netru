import '../../data/models/news_model.dart';
import '../../data/models/news_category_model.dart';

abstract class NewsdetailsRepository {
  Future<List<NewsModel>> getNews();
  Future<NewsModel?> getNewsById(String id);
  Future<List<NewsCategoryModel>> getNewsCategories();
  Future<List<NewsModel>> getNewsByCategory(int categoryId);
  Future<List<NewsModel>> getFeaturedNews();
}
