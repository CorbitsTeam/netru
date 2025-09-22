import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
import '../../domain/repositories/admin_dashboard_repository.dart';
import '../datasources/admin_dashboard_remote_data_source.dart';

class AdminDashboardRepositoryImpl implements AdminDashboardRepository {
  final AdminDashboardRemoteDataSource remoteDataSource;

  AdminDashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DashboardStatsEntity>> getDashboardStats() async {
    try {
      final result = await remoteDataSource.getDashboardStats();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getReportsByGovernorate() async {
    try {
      final result = await remoteDataSource.getReportsByGovernorate();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getReportsByType() async {
    try {
      final result = await remoteDataSource.getReportsByType();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getReportsByStatus() async {
    try {
      final result = await remoteDataSource.getReportsByStatus();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReportTrendData>>> getReportTrends({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final result = await remoteDataSource.getReportTrends(
        startDate: startDate,
        endDate: endDate,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
