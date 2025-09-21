import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dashboard_stats_entity.dart';
import '../repositories/admin_dashboard_repository.dart';

class GetDashboardStats implements UseCase<DashboardStatsEntity, NoParams> {
  final AdminDashboardRepository repository;

  GetDashboardStats(this.repository);

  @override
  Future<Either<Failure, DashboardStatsEntity>> call(NoParams params) async {
    return await repository.getDashboardStats();
  }
}

class GetReportTrends
    implements UseCase<List<ReportTrendData>, GetReportTrendsParams> {
  final AdminDashboardRepository repository;

  GetReportTrends(this.repository);

  @override
  Future<Either<Failure, List<ReportTrendData>>> call(
    GetReportTrendsParams params,
  ) async {
    return await repository.getReportTrends(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetReportsByGovernorate implements UseCase<Map<String, int>, NoParams> {
  final AdminDashboardRepository repository;

  GetReportsByGovernorate(this.repository);

  @override
  Future<Either<Failure, Map<String, int>>> call(NoParams params) async {
    return await repository.getReportsByGovernorate();
  }
}

class GetReportsByType implements UseCase<Map<String, int>, NoParams> {
  final AdminDashboardRepository repository;

  GetReportsByType(this.repository);

  @override
  Future<Either<Failure, Map<String, int>>> call(NoParams params) async {
    return await repository.getReportsByType();
  }
}

class GetReportsByStatus implements UseCase<Map<String, int>, NoParams> {
  final AdminDashboardRepository repository;

  GetReportsByStatus(this.repository);

  @override
  Future<Either<Failure, Map<String, int>>> call(NoParams params) async {
    return await repository.getReportsByStatus();
  }
}

class GetReportTrendsParams extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const GetReportTrendsParams({required this.startDate, required this.endDate});

  @override
  List<Object> get props => [startDate, endDate];
}
