import '../../domain/repositories/heatmap_repository.dart';
import '../datasources/heatmap_remote_datasource.dart';

class HeatmapRepositoryImpl implements HeatmapRepository {
  final HeatmapRemoteDataSource remoteDataSource;

  HeatmapRepositoryImpl(this.remoteDataSource);

  // TODO: Implement repository logic
}
