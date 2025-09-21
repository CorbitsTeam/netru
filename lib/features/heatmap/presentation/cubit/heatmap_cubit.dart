import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/heatmap_usecase.dart';
import '../../domain/entities/heatmap_entity.dart';
import 'heatmap_state.dart';

class HeatmapCubit extends Cubit<HeatmapState> {
  final HeatmapUseCase _heatmapUseCase;

  List<ReportLocationEntity> _allReports = [];
  CrimeStatisticsEntity? _statistics;
  List<GovernorateStatsEntity> _governorateStats = [];

  HeatmapCubit(this._heatmapUseCase) : super(HeatmapInitial());

  List<ReportLocationEntity> get allReports => _allReports;
  CrimeStatisticsEntity? get statistics => _statistics;
  List<GovernorateStatsEntity> get governorateStats => _governorateStats;

  Future<void> loadHeatmapData() async {
    emit(HeatmapLoading());
    try {
      // جلب البيانات بشكل متوازي
      final results = await Future.wait([
        _heatmapUseCase.getReportsLocations(),
        _heatmapUseCase.getCrimeStatistics(),
        _heatmapUseCase.getGovernorateStatistics(),
      ]);

      _allReports = results[0] as List<ReportLocationEntity>;
      _statistics = results[1] as CrimeStatisticsEntity;
      _governorateStats = results[2] as List<GovernorateStatsEntity>;

      emit(
        HeatmapLoaded(
          reports: _allReports,
          statistics: _statistics!,
          governorateStats: _governorateStats,
        ),
      );
    } catch (e) {
      emit(
        HeatmapFailure('فشل في تحميل بيانات الخريطة الحرارية: ${e.toString()}'),
      );
    }
  }

  Future<void> loadStatistics() async {
    try {
      if (_statistics == null) {
        emit(HeatmapLoading());
        _statistics = await _heatmapUseCase.getCrimeStatistics();
      }
      emit(HeatmapStatisticsLoaded(_statistics!));
    } catch (e) {
      emit(HeatmapFailure('فشل في تحميل الإحصائيات: ${e.toString()}'));
    }
  }

  Future<void> loadReports() async {
    try {
      if (_allReports.isEmpty) {
        emit(HeatmapLoading());
        _allReports = await _heatmapUseCase.getReportsLocations();
      }
      emit(HeatmapReportsLoaded(_allReports));
    } catch (e) {
      emit(HeatmapFailure('فشل في تحميل التقارير: ${e.toString()}'));
    }
  }

  Future<void> filterByGovernorate(String governorate) async {
    try {
      emit(HeatmapLoading());
      final filteredReports = await _heatmapUseCase.getReportsByGovernorate(
        governorate,
      );
      emit(
        HeatmapGovernorateFilterApplied(
          filteredReports: filteredReports,
          selectedGovernorate: governorate,
        ),
      );
    } catch (e) {
      emit(HeatmapFailure('فشل في تطبيق فلتر المحافظة: ${e.toString()}'));
    }
  }

  Future<void> loadRecentReports({int limit = 50}) async {
    try {
      emit(HeatmapLoading());
      final recentReports = await _heatmapUseCase.getRecentReports(
        limit: limit,
      );
      emit(HeatmapReportsLoaded(recentReports));
    } catch (e) {
      emit(HeatmapFailure('فشل في تحميل التقارير الحديثة: ${e.toString()}'));
    }
  }

  void clearFilter() {
    if (_allReports.isNotEmpty && _statistics != null) {
      emit(
        HeatmapLoaded(
          reports: _allReports,
          statistics: _statistics!,
          governorateStats: _governorateStats,
        ),
      );
    } else {
      loadHeatmapData();
    }
  }

  Future<void> refreshData() async {
    // مسح البيانات المخزنة مؤقتاً وإعادة تحميلها
    _allReports.clear();
    _statistics = null;
    _governorateStats.clear();
    await loadHeatmapData();
  }

  // دالة للحصول على التقارير حسب مستوى الأولوية
  List<ReportLocationEntity> getReportsByPriority(String priority) {
    return _allReports.where((report) => report.priority == priority).toList();
  }

  // دالة للحصول على التقارير حسب الحالة
  List<ReportLocationEntity> getReportsByStatus(String status) {
    return _allReports.where((report) => report.status == status).toList();
  }

  // دالة للحصول على التقارير حسب نوع الجريمة
  List<ReportLocationEntity> getReportsByType(String type) {
    return _allReports.where((report) => report.reportType == type).toList();
  }

  // دالة للحصول على إحصائيات سريعة
  Map<String, int> getQuickStats() {
    return {
      'total': _allReports.length,
      'pending': getReportsByStatus('pending').length,
      'resolved': getReportsByStatus('resolved').length,
      'high_priority': getReportsByPriority('high').length,
    };
  }
}
