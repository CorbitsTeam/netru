import '../entities/heatmap_entity.dart';
import '../repositories/heatmap_repository.dart';

class HeatmapUseCase {
  final HeatmapRepository repository;

  HeatmapUseCase(this.repository);

  Future<List<ReportLocationEntity>> getReportsLocations() async {
    return await repository.getReportsLocations();
  }

  Future<CrimeStatisticsEntity> getCrimeStatistics() async {
    return await repository.getCrimeStatistics();
  }

  Future<List<GovernorateStatsEntity>> getGovernorateStatistics() async {
    return await repository.getGovernorateStatistics();
  }

  Future<List<ReportTypeStatsEntity>> getReportTypeStatistics() async {
    return await repository.getReportTypeStatistics();
  }

  Future<List<ReportLocationEntity>> getReportsByGovernorate(
    String governorate,
  ) async {
    if (governorate.isEmpty) {
      throw ArgumentError('اسم المحافظة لا يمكن أن يكون فارغاً');
    }
    return await repository.getReportsByGovernorate(governorate);
  }

  Future<List<ReportLocationEntity>> getRecentReports({int limit = 50}) async {
    if (limit <= 0) {
      throw ArgumentError('الحد الأقصى يجب أن يكون أكبر من صفر');
    }
    return await repository.getRecentReports(limit: limit);
  }

  Future<Map<String, int>> getReportCountsByPriority() async {
    final reports = await getReportsLocations();
    final Map<String, int> priorityCounts = {};

    for (final report in reports) {
      priorityCounts[report.priority] =
          (priorityCounts[report.priority] ?? 0) + 1;
    }

    return priorityCounts;
  }

  Future<Map<String, int>> getReportCountsByStatus() async {
    final reports = await getReportsLocations();
    final Map<String, int> statusCounts = {};

    for (final report in reports) {
      statusCounts[report.status] = (statusCounts[report.status] ?? 0) + 1;
    }

    return statusCounts;
  }
}
