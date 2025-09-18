import 'dart:io';
import 'package:dartz/dartz.dart';
import '../entities/reports_entity.dart';

abstract class ReportsRepository {
  Future<Either<String, List<ReportEntity>>> getAllReports();
  Future<Either<String, ReportEntity>> getReportById(String id);
  Future<Either<String, ReportEntity>> createReport({
    required String firstName,
    required String lastName,
    required String nationalId,
    required String phone,
    required String reportType,
    required String reportDetails,
    double? latitude,
    double? longitude,
    String? locationName,
    required DateTime reportDateTime,
    File? mediaFile,
    String? submittedBy,
  });
  Future<Either<String, ReportEntity>> updateReportStatus(
    String id,
    ReportStatus status,
  );
  Future<Either<String, void>> deleteReport(String id);
}
