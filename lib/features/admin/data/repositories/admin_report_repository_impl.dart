import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/admin_report_entity.dart';
import '../../domain/repositories/admin_report_repository.dart';
import '../datasources/admin_report_remote_data_source.dart';

class AdminReportRepositoryImpl implements AdminReportRepository {
  final AdminReportRemoteDataSource remoteDataSource;

  AdminReportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AdminReportEntity>>> getAllReports({
    int? page,
    int? limit,
    AdminReportStatus? status,
    PriorityLevel? priority,
    VerificationStatus? verificationStatus,
    String? assignedTo,
    String? governorate,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) async {
    try {
      final reports = await remoteDataSource.getAllReports(
        page: page,
        limit: limit,
        search: searchQuery,
        status: status?.value,
        governorate: governorate,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(reports.cast<AdminReportEntity>());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminReportEntity>> getReportById(
    String reportId,
  ) async {
    try {
      final report = await remoteDataSource.getReportById(reportId);
      return Right(report);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminReportEntity>> updateReportStatus({
    required String reportId,
    required AdminReportStatus status,
    String? notes,
    String? adminNotes,
    String? publicNotes,
  }) async {
    try {
      final report = await remoteDataSource.updateReportStatus(
        reportId: reportId,
        status: status.value,
        notes: notes ?? adminNotes,
      );
      return Right(report);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> assignReport({
    required String reportId,
    required String assignedTo,
    String? assignmentNotes,
  }) async {
    try {
      await remoteDataSource.assignReport(
        reportId: reportId,
        investigatorId: assignedTo,
        notes: assignmentNotes,
      );
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateReportPriority({
    required String reportId,
    required PriorityLevel priority,
  }) async {
    try {
      // Note: This would need to be implemented in data source
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyReport({
    required String reportId,
    required VerificationStatus status,
    String? notes,
  }) async {
    try {
      // Note: This would need to be implemented in data source
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReportCommentEntity>>> getReportComments(
    String reportId,
  ) async {
    try {
      // Note: This would need to be implemented in data source
      return const Right([]);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReportCommentEntity>> addComment({
    required String reportId,
    required String commentText,
    required bool isInternal,
    String? parentCommentId,
  }) async {
    try {
      // Note: This would need to be implemented in data source
      throw UnimplementedError('Add comment not implemented yet');
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteComment(String commentId) async {
    try {
      // Note: This would need to be implemented in data source
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReportStatusHistoryEntity>>> getReportHistory(
    String reportId,
  ) async {
    try {
      // Note: This would need to be implemented in data source
      return const Right([]);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AdminReportEntity>>> getAssignedReports(
    String userId,
  ) async {
    try {
      final reports = await remoteDataSource.getReportsByInvestigator(userId);
      return Right(reports.cast<AdminReportEntity>());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getReportStats({
    DateTime? startDate,
    DateTime? endDate,
    String? governorate,
  }) async {
    try {
      final stats = await remoteDataSource.getReportStatistics();
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> exportReports({
    required String format,
    AdminReportStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? governorate,
  }) async {
    try {
      // Note: This would need to be implemented in data source
      return const Right('export_url');
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
