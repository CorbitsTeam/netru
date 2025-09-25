import '../../domain/entities/heatmap_entity.dart';

abstract class HeatmapState {}

class HeatmapInitial extends HeatmapState {}

class HeatmapLoading extends HeatmapState {}

class HeatmapLoaded extends HeatmapState {
  final List<ReportLocationEntity> reports;
  final CrimeStatisticsEntity statistics;
  final List<GovernorateStatsEntity> governorateStats;

  HeatmapLoaded({
    required this.reports,
    required this.statistics,
    required this.governorateStats,
  });
}

class HeatmapStatisticsLoaded extends HeatmapState {
  final CrimeStatisticsEntity statistics;

  HeatmapStatisticsLoaded(this.statistics);
}

class HeatmapReportsLoaded extends HeatmapState {
  final List<ReportLocationEntity> reports;

  HeatmapReportsLoaded(this.reports);
}

class HeatmapGovernorateFilterApplied extends HeatmapState {
  final List<ReportLocationEntity> filteredReports;
  final String selectedGovernorate;

  HeatmapGovernorateFilterApplied({
    required this.filteredReports,
    required this.selectedGovernorate,
  });
}

class HeatmapCrimeTypeFilterApplied extends HeatmapState {
  final List<ReportLocationEntity> filteredReports;
  final String selectedCrimeType;

  HeatmapCrimeTypeFilterApplied({
    required this.filteredReports,
    required this.selectedCrimeType,
  });
}

class HeatmapCombinedFilterApplied extends HeatmapState {
  final List<ReportLocationEntity> filteredReports;
  final String? selectedGovernorate;
  final String? selectedCrimeType;

  HeatmapCombinedFilterApplied({
    required this.filteredReports,
    this.selectedGovernorate,
    this.selectedCrimeType,
  });
}

class HeatmapFailure extends HeatmapState {
  final String error;

  HeatmapFailure(this.error);
}
