import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/admin_report_entity.dart';
import '../repositories/admin_report_repository.dart';

class GetAllReports
    implements UseCase<List<AdminReportEntity>, GetReportsParams> {
  final AdminReportRepository repository;

  GetAllReports(this.repository);

  @override
  Future<Either<Failure, List<AdminReportEntity>>> call(
    GetReportsParams params,
  ) async {
    return await repository.getAllReports(
      page: params.page,
      limit: params.limit,
      status: params.status,
      priority: params.priority,
      verificationStatus: params.verificationStatus,
      assignedTo: params.assignedTo,
      governorate: params.governorate,
      startDate: params.startDate,
      endDate: params.endDate,
      searchQuery: params.searchQuery,
    );
  }
}

class GetReportById implements UseCase<AdminReportEntity, GetReportByIdParams> {
  final AdminReportRepository repository;

  GetReportById(this.repository);

  @override
  Future<Either<Failure, AdminReportEntity>> call(
    GetReportByIdParams params,
  ) async {
    return await repository.getReportById(params.reportId);
  }
}

class UpdateReportStatus
    implements UseCase<AdminReportEntity, UpdateReportStatusParams> {
  final AdminReportRepository repository;

  UpdateReportStatus(this.repository);

  @override
  Future<Either<Failure, AdminReportEntity>> call(
    UpdateReportStatusParams params,
  ) async {
    return await repository.updateReportStatus(
      reportId: params.reportId,
      status: params.status,
      notes: params.notes,
      adminNotes: params.adminNotes,
      publicNotes: params.publicNotes,
    );
  }
}

class AssignReport implements UseCase<bool, AssignReportParams> {
  final AdminReportRepository repository;

  AssignReport(this.repository);

  @override
  Future<Either<Failure, bool>> call(AssignReportParams params) async {
    return await repository.assignReport(
      reportId: params.reportId,
      assignedTo: params.assignedTo,
      assignmentNotes: params.assignmentNotes,
    );
  }
}

class AddReportComment
    implements UseCase<ReportCommentEntity, AddCommentParams> {
  final AdminReportRepository repository;

  AddReportComment(this.repository);

  @override
  Future<Either<Failure, ReportCommentEntity>> call(
    AddCommentParams params,
  ) async {
    return await repository.addComment(
      reportId: params.reportId,
      commentText: params.commentText,
      isInternal: params.isInternal,
      parentCommentId: params.parentCommentId,
    );
  }
}

class VerifyReport implements UseCase<bool, VerifyReportParams> {
  final AdminReportRepository repository;

  VerifyReport(this.repository);

  @override
  Future<Either<Failure, bool>> call(VerifyReportParams params) async {
    return await repository.verifyReport(
      reportId: params.reportId,
      status: params.status,
      notes: params.notes,
    );
  }
}

class ExportReports implements UseCase<String, ExportReportsParams> {
  final AdminReportRepository repository;

  ExportReports(this.repository);

  @override
  Future<Either<Failure, String>> call(ExportReportsParams params) async {
    return await repository.exportReports(
      format: params.format,
      status: params.status,
      startDate: params.startDate,
      endDate: params.endDate,
      governorate: params.governorate,
    );
  }
}

// Parameters classes
class GetReportsParams extends Equatable {
  final int? page;
  final int? limit;
  final AdminReportStatus? status;
  final PriorityLevel? priority;
  final VerificationStatus? verificationStatus;
  final String? assignedTo;
  final String? governorate;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;

  const GetReportsParams({
    this.page,
    this.limit,
    this.status,
    this.priority,
    this.verificationStatus,
    this.assignedTo,
    this.governorate,
    this.startDate,
    this.endDate,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [
    page,
    limit,
    status,
    priority,
    verificationStatus,
    assignedTo,
    governorate,
    startDate,
    endDate,
    searchQuery,
  ];
}

class GetReportByIdParams extends Equatable {
  final String reportId;

  const GetReportByIdParams({required this.reportId});

  @override
  List<Object> get props => [reportId];
}

class UpdateReportStatusParams extends Equatable {
  final String reportId;
  final AdminReportStatus status;
  final String? notes;
  final String? adminNotes;
  final String? publicNotes;

  const UpdateReportStatusParams({
    required this.reportId,
    required this.status,
    this.notes,
    this.adminNotes,
    this.publicNotes,
  });

  @override
  List<Object?> get props => [reportId, status, notes, adminNotes, publicNotes];
}

class AssignReportParams extends Equatable {
  final String reportId;
  final String assignedTo;
  final String? assignmentNotes;

  const AssignReportParams({
    required this.reportId,
    required this.assignedTo,
    this.assignmentNotes,
  });

  @override
  List<Object?> get props => [reportId, assignedTo, assignmentNotes];
}

class AddCommentParams extends Equatable {
  final String reportId;
  final String commentText;
  final bool isInternal;
  final String? parentCommentId;

  const AddCommentParams({
    required this.reportId,
    required this.commentText,
    required this.isInternal,
    this.parentCommentId,
  });

  @override
  List<Object?> get props => [
    reportId,
    commentText,
    isInternal,
    parentCommentId,
  ];
}

class VerifyReportParams extends Equatable {
  final String reportId;
  final VerificationStatus status;
  final String? notes;

  const VerifyReportParams({
    required this.reportId,
    required this.status,
    this.notes,
  });

  @override
  List<Object?> get props => [reportId, status, notes];
}

class ExportReportsParams extends Equatable {
  final String format;
  final AdminReportStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? governorate;

  const ExportReportsParams({
    required this.format,
    this.status,
    this.startDate,
    this.endDate,
    this.governorate,
  });

  @override
  List<Object?> get props => [format, status, startDate, endDate, governorate];
}
