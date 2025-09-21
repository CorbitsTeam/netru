import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/admin_report_entity.dart';

abstract class AdminReportRepository {
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
  });

  Future<Either<Failure, AdminReportEntity>> getReportById(String reportId);

  Future<Either<Failure, AdminReportEntity>> updateReportStatus({
    required String reportId,
    required AdminReportStatus status,
    String? notes,
    String? adminNotes,
    String? publicNotes,
  });

  Future<Either<Failure, bool>> assignReport({
    required String reportId,
    required String assignedTo,
    String? assignmentNotes,
  });

  Future<Either<Failure, bool>> updateReportPriority({
    required String reportId,
    required PriorityLevel priority,
  });

  Future<Either<Failure, bool>> verifyReport({
    required String reportId,
    required VerificationStatus status,
    String? notes,
  });

  Future<Either<Failure, List<ReportCommentEntity>>> getReportComments(
    String reportId,
  );

  Future<Either<Failure, ReportCommentEntity>> addComment({
    required String reportId,
    required String commentText,
    required bool isInternal,
    String? parentCommentId,
  });

  Future<Either<Failure, bool>> deleteComment(String commentId);

  Future<Either<Failure, List<ReportStatusHistoryEntity>>> getReportHistory(
    String reportId,
  );

  Future<Either<Failure, List<AdminReportEntity>>> getAssignedReports(
    String userId,
  );

  Future<Either<Failure, Map<String, dynamic>>> getReportStats({
    DateTime? startDate,
    DateTime? endDate,
    String? governorate,
  });

  Future<Either<Failure, String>> exportReports({
    required String format, // csv, pdf, excel
    AdminReportStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? governorate,
  });
}
