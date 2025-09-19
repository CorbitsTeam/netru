import '../../domain/repositories/newsdetails_repository.dart';
import '../datasources/newsdetails_remote_datasource.dart';
import '../models/news_model.dart';
import '../models/news_category_model.dart';

class NewsdetailsRepositoryImpl implements NewsdetailsRepository {
  final NewsdetailsRemoteDataSource remoteDataSource;

  NewsdetailsRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<NewsModel>> getNews() async {
    try {
      return await remoteDataSource.getNews();
    } catch (e) {
      throw Exception('Failed to get news: $e');
    }
  }

  @override
  Future<NewsModel?> getNewsById(String id) async {
    try {
      final news = await remoteDataSource.getNewsById(id);
      if (news != null) {
        // Increment view count when fetching individual news
        await remoteDataSource.incrementNewsViewCount(id);
        return news;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get news by id: $e');
    }
  }

  @override
  Future<List<NewsCategoryModel>> getNewsCategories() async {
    try {
      return await remoteDataSource.getNewsCategories();
    } catch (e) {
      throw Exception('Failed to get news categories: $e');
    }
  }

  @override
  Future<List<NewsModel>> getNewsByCategory(int categoryId) async {
    try {
      return await remoteDataSource.getNewsByCategory(categoryId);
    } catch (e) {
      throw Exception('Failed to get news by category: $e');
    }
  }

  @override
  Future<List<NewsModel>> getFeaturedNews() async {
    try {
      return await remoteDataSource.getFeaturedNews();
    } catch (e) {
      throw Exception('Failed to get featured news: $e');
    }
  }
}
