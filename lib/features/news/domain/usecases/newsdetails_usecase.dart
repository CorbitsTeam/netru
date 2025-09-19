import '../repositories/newsdetails_repository.dart';
import '../../data/models/news_model.dart';
import '../../data/models/news_category_model.dart';

class NewsdetailsUseCase {
  final NewsdetailsRepository repository;

  NewsdetailsUseCase(this.repository);

  Future<List<NewsModel>> getNews() async {
    return await repository.getNews();
  }

  Future<NewsModel?> getNewsById(String id) async {
    return await repository.getNewsById(id);
  }

  Future<List<NewsCategoryModel>> getNewsCategories() async {
    return await repository.getNewsCategories();
  }

  Future<List<NewsModel>> getNewsByCategory(int categoryId) async {
    return await repository.getNewsByCategory(categoryId);
  }

  Future<List<NewsModel>> getFeaturedNews() async {
    return await repository.getFeaturedNews();
  }
}
