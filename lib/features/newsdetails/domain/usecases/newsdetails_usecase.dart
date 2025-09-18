import '../repositories/newsdetails_repository.dart';
import '../../data/models/news_model.dart';

class NewsdetailsUseCase {
  final NewsdetailsRepository repository;

  NewsdetailsUseCase(this.repository);

  Future<List<NewsModel>> getNews() async {
    return await repository.getNews();
  }

  Future<NewsModel?> getNewsById(int id) async {
    return await repository.getNewsById(id);
  }
}
