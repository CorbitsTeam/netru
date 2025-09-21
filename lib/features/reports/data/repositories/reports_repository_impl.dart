import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import 'package:netru_app/core/utils/user_data_helper.dart';
import '../../domain/entities/reports_entity.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_remote_datasource.dart';
import '../models/reports_model.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remoteDataSource;

  ReportsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<String, List<ReportEntity>>> getAllReports() async {
    try {
      final reports = await remoteDataSource.getAllReports();
      return Right(reports);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, ReportEntity>> getReportById(String id) async {
    try {
      final report = await remoteDataSource.getReportById(id);
      return Right(report);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, ReportEntity>> createReport({
    required String firstName,
    required String lastName,
    required String nationalId,
    required String phone,
    required String reportType,
    int? reportTypeId,
    required String reportDetails,
    double? latitude,
    double? longitude,
    String? locationName,
    required DateTime reportDateTime,
    File? mediaFile,
    String? submittedBy,
  }) async {
    print('🏭 Repository: Starting createReport...');
    print('📄 Report Type: $reportType (ID: $reportTypeId)');
    print('📍 Location: $latitude, $longitude');
    print('📷 Media File Path: ${mediaFile?.path}');
    print('👤 Submitted By: $submittedBy');

    try {
      // Get current user to ensure proper data consistency
      final userHelper = UserDataHelper();
      final currentUser = userHelper.getCurrentUser();

      // Use the reporter_national_id from current user if available, otherwise use provided nationalId
      final reporterNationalId = currentUser?.identifier ?? nationalId;
      final userIdForReport = currentUser?.id ?? submittedBy;

      print('📝 Using reporter_national_id: $reporterNationalId');
      print('📝 Using user_id: $userIdForReport');

      // Create the report first
      final reportModel = ReportModel(
        id: const Uuid().v4(),
        firstName: firstName,
        lastName: lastName,
        nationalId: reporterNationalId, // Use current user's national ID
        phone: phone,
        reportType: reportType,
        reportTypeId: reportTypeId,
        reportDetails: reportDetails,
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
        reportDateTime: reportDateTime,
        status: ReportStatus.received,
        submittedBy: userIdForReport, // Ensure user_id is set
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('📝 Creating report in database...');
      final createdReport = await remoteDataSource.createReport(reportModel);
      print('✅ Report created with ID: ${createdReport.id}');

      // Upload media if provided and attach to report
      if (mediaFile != null) {
        try {
          print(
            'Starting media upload process for report: ${createdReport.id}',
          );

          final fileName =
              'report_${createdReport.id}_${DateTime.now().millisecondsSinceEpoch}';

          final mediaUrl = await remoteDataSource.uploadMedia(
            mediaFile,
            fileName,
          );

          if (mediaUrl != null && mediaUrl.isNotEmpty) {
            print('Media uploaded successfully. URL: $mediaUrl');

            // Determine media type
            final extension = mediaFile.path.split('.').last.toLowerCase();
            String mediaType;
            if ([
              'jpg',
              'jpeg',
              'png',
              'gif',
              'bmp',
              'webp',
            ].contains(extension)) {
              mediaType = 'image';
            } else if ([
              'mp4',
              'avi',
              'mov',
              'wmv',
              'flv',
            ].contains(extension)) {
              mediaType = 'video';
            } else {
              mediaType = 'document';
            }

            print('Determined media type: $mediaType');

            await remoteDataSource.attachMediaToReport(
              createdReport.id,
              mediaUrl,
              mediaType,
            );

            print('Media attached to report successfully');

            // Return updated report with media info
            return Right(
              ReportModel(
                id: createdReport.id,
                firstName: createdReport.firstName,
                lastName: createdReport.lastName,
                nationalId: createdReport.nationalId,
                phone: createdReport.phone,
                reportType: createdReport.reportType,
                reportTypeId: createdReport.reportTypeId,
                reportDetails: createdReport.reportDetails,
                latitude: createdReport.latitude,
                longitude: createdReport.longitude,
                locationName: createdReport.locationName,
                reportDateTime: createdReport.reportDateTime,
                mediaUrl: mediaUrl,
                mediaType: mediaType,
                status: createdReport.status,
                submittedBy: createdReport.submittedBy,
                createdAt: createdReport.createdAt,
                updatedAt: createdReport.updatedAt,
              ),
            );
          } else {
            print('Warning: Media upload returned empty URL');
          }
        } catch (mediaError) {
          // Log media upload error but don't fail the report creation
          // Use debugPrint with wrapWidth to avoid extremely long single-line logs
          debugPrint(
            'Warning: Failed to upload media for report ${createdReport.id}: $mediaError',
            wrapWidth: 1024,
          );

          print('Media upload failed, but report was created successfully');

          // Check if it's a critical error that should be reported to user
          if (mediaError.toString().contains('Storage access denied') ||
              mediaError.toString().contains('Bucket not found')) {
            // These are configuration issues that should be reported
            return Left(
              'Report created successfully but media upload failed: ${mediaError.toString()}',
            );
          }

          // For other errors, continue with report creation without media
        }
      }

      return Right(createdReport);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, ReportEntity>> updateReportStatus(
    String id,
    ReportStatus status,
  ) async {
    try {
      // First get the current report
      final currentReport = await remoteDataSource.getReportById(id);

      // Create updated report with new status
      final updatedReport = ReportModel(
        id: currentReport.id,
        firstName: currentReport.firstName,
        lastName: currentReport.lastName,
        nationalId: currentReport.nationalId,
        phone: currentReport.phone,
        reportType: currentReport.reportType,
        reportDetails: currentReport.reportDetails,
        latitude: currentReport.latitude,
        longitude: currentReport.longitude,
        locationName: currentReport.locationName,
        reportDateTime: currentReport.reportDateTime,
        mediaUrl: currentReport.mediaUrl,
        mediaType: currentReport.mediaType,
        status: status,
        submittedBy: currentReport.submittedBy,
        createdAt: currentReport.createdAt,
        updatedAt: DateTime.now(),
      );

      final result = await remoteDataSource.updateReport(updatedReport);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteReport(String id) async {
    try {
      await remoteDataSource.deleteReport(id);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
