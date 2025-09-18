import 'dart:io';
import 'package:dartz/dartz.dart';
import '../entities/reports_entity.dart';
import '../repositories/reports_repository.dart';

class GetAllReportsUseCase {
  final ReportsRepository repository;

  GetAllReportsUseCase(this.repository);

  Future<Either<String, List<ReportEntity>>> call() async {
    return await repository.getAllReports();
  }
}

class GetReportByIdUseCase {
  final ReportsRepository repository;

  GetReportByIdUseCase(this.repository);

  Future<Either<String, ReportEntity>> call(String id) async {
    return await repository.getReportById(id);
  }
}

class CreateReportUseCase {
  final ReportsRepository repository;

  CreateReportUseCase(this.repository);

  Future<Either<String, ReportEntity>> call(CreateReportParams params) async {
    return await repository.createReport(
      firstName: params.firstName,
      lastName: params.lastName,
      nationalId: params.nationalId,
      phone: params.phone,
      reportType: params.reportType,
      reportTypeId: params.reportTypeId,
      reportDetails: params.reportDetails,
      latitude: params.latitude,
      longitude: params.longitude,
      locationName: params.locationName,
      reportDateTime: params.reportDateTime,
      mediaFile: params.mediaFile,
      submittedBy: params.submittedBy,
    );
  }
}

class UpdateReportStatusUseCase {
  final ReportsRepository repository;

  UpdateReportStatusUseCase(this.repository);

  Future<Either<String, ReportEntity>> call(
    String id,
    ReportStatus status,
  ) async {
    return await repository.updateReportStatus(id, status);
  }
}

class DeleteReportUseCase {
  final ReportsRepository repository;

  DeleteReportUseCase(this.repository);

  Future<Either<String, void>> call(String id) async {
    return await repository.deleteReport(id);
  }
}

class CreateReportParams {
  final String firstName;
  final String lastName;
  final String nationalId;
  final String phone;
  final String reportType;
  final int? reportTypeId;
  final String reportDetails;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final DateTime reportDateTime;
  final File? mediaFile;
  final String? submittedBy;

  CreateReportParams({
    required this.firstName,
    required this.lastName,
    required this.nationalId,
    required this.phone,
    required this.reportType,
    this.reportTypeId,
    required this.reportDetails,
    this.latitude,
    this.longitude,
    this.locationName,
    required this.reportDateTime,
    this.mediaFile,
    this.submittedBy,
  });
}
