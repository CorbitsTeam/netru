import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/dashboard_stats_entity.dart';

abstract class AdminDashboardRepository {
  Future<Either<Failure, DashboardStatsEntity>> getDashboardStats();
  Future<Either<Failure, Map<String, int>>> getReportsByGovernorate();
  Future<Either<Failure, Map<String, int>>> getReportsByType();
  Future<Either<Failure, Map<String, int>>> getReportsByStatus();
  Future<Either<Failure, List<ReportTrendData>>> getReportTrends({
    required DateTime startDate,
    required DateTime endDate,
  });
}
