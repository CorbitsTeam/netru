import '../../domain/entities/heatmap_entity.dart';
import '../../domain/repositories/heatmap_repository.dart';
import '../datasources/heatmap_remote_datasource.dart';

class HeatmapRepositoryImpl implements HeatmapRepository {
  final HeatmapRemoteDataSource remoteDataSource;

  HeatmapRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ReportLocationEntity>> getReportsLocations() async {
    try {
      final result = await remoteDataSource.getReportsLocations();
      return result;
    } catch (e) {
      throw Exception('فشل في جلب مواقع التقارير من الخادم: $e');
    }
  }

  @override
  Future<CrimeStatisticsEntity> getCrimeStatistics() async {
    try {
      final result = await remoteDataSource.getCrimeStatistics();
      return result;
    } catch (e) {
      throw Exception('فشل في جلب الإحصائيات من الخادم: $e');
    }
  }

  @override
  Future<List<GovernorateStatsEntity>> getGovernorateStatistics() async {
    try {
      final result = await remoteDataSource.getGovernorateStatistics();
      return result;
    } catch (e) {
      throw Exception('فشل في جلب إحصائيات المحافظات من الخادم: $e');
    }
  }

  @override
  Future<List<ReportTypeStatsEntity>> getReportTypeStatistics() async {
    try {
      final result = await remoteDataSource.getReportTypeStatistics();
      return result;
    } catch (e) {
      throw Exception('فشل في جلب إحصائيات أنواع التقارير من الخادم: $e');
    }
  }

  @override
  Future<List<ReportLocationEntity>> getReportsByGovernorate(
    String governorate,
  ) async {
    try {
      final result = await remoteDataSource.getReportsByGovernorate(
        governorate,
      );
      return result;
    } catch (e) {
      throw Exception('فشل في جلب تقارير المحافظة من الخادم: $e');
    }
  }

  @override
  Future<List<ReportLocationEntity>> getRecentReports({int limit = 50}) async {
    try {
      final result = await remoteDataSource.getRecentReports(limit: limit);
      return result;
    } catch (e) {
      throw Exception('فشل في جلب التقارير الحديثة من الخادم: $e');
    }
  }
}
