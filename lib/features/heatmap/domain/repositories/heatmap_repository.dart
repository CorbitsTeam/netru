import '../entities/heatmap_entity.dart';

abstract class HeatmapRepository {
  Future<List<ReportLocationEntity>> getReportsLocations();
  Future<CrimeStatisticsEntity> getCrimeStatistics();
  Future<List<GovernorateStatsEntity>> getGovernorateStatistics();
  Future<List<ReportTypeStatsEntity>> getReportTypeStatistics();
  Future<List<ReportLocationEntity>> getReportsByGovernorate(
    String governorate,
  );
  Future<List<ReportLocationEntity>> getRecentReports({int limit = 50});
}
