import '../../data/models/news_model.dart';

abstract class NewsdetailsRepository {
  Future<List<NewsModel>> getNews();
  Future<NewsModel?> getNewsById(int id);
}
