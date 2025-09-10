import '../../domain/repositories/newsdetails_repository.dart';
import '../datasources/newsdetails_remote_datasource.dart';

class NewsdetailsRepositoryImpl implements NewsdetailsRepository {
  final NewsdetailsRemoteDataSource remoteDataSource;

  NewsdetailsRepositoryImpl(this.remoteDataSource);

  // TODO: Implement repository logic
}
