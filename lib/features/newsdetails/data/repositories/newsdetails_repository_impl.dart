import '../../domain/repositories/newsdetails_repository.dart';
import '../datasources/news_local_datasource.dart';
import '../models/news_model.dart';

class NewsdetailsRepositoryImpl implements NewsdetailsRepository {
  final NewsLocalDataSource localDataSource;

  NewsdetailsRepositoryImpl(this.localDataSource);

  @override
  Future<List<NewsModel>> getNews() async {
    try {
      return await localDataSource.getNewsFromJson();
    } catch (e) {
      throw Exception('Failed to get news: $e');
    }
  }

  @override
  Future<NewsModel?> getNewsById(int id) async {
    try {
      final newsList = await localDataSource.getNewsFromJson();
      return newsList.where((news) => news.id == id).firstOrNull;
    } catch (e) {
      throw Exception('Failed to get news by id: $e');
    }
  }
}
