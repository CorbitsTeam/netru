import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:netru_app/core/utils/user_data_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reports_model.dart';

abstract class ReportsRemoteDataSource {
  Future<List<ReportModel>> getAllReports();
  Future<ReportModel> getReportById(String id);
  Future<ReportModel> createReport(ReportModel report);
  Future<ReportModel> updateReport(ReportModel report);
  Future<void> deleteReport(String id);
  Future<String?> uploadMedia(File file, String fileName);
  Future<List<String>> uploadMultipleMedia(
    List<File> files,
    String baseFileName,
  );
  Future<void> attachMediaToReport(
    String reportId,
    String mediaUrl,
    String mediaType,
  );
  Future<void> attachMultipleMediaToReport(
    String reportId,
    List<Map<String, String>> mediaList,
  );
}

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final SupabaseClient supabaseClient;

  ReportsRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<ReportModel>> getAllReports() async {
    try {
      // Get current user data
      final userHelper = UserDataHelper();
      final currentUser = userHelper.getCurrentUser();

      if (currentUser == null) {
        throw Exception('لا يوجد مستخدم مسجل دخول');
      }

      // Strategy 1: Try multiple search approaches comprehensively
      List<ReportModel> foundReports = [];

      // Primary search: Use user_id
      try {
        final userIdResponse = await supabaseClient
            .from('reports')
            .select('''
              *,
              report_types(name, name_ar, priority_level),
              users!reports_user_id_fkey(full_name, email),
              report_media(id, media_type, file_url, file_name)
            ''')
            .eq('user_id', currentUser.id.toString())
            .order('submitted_at', ascending: false);

        if (userIdResponse.isNotEmpty) {
          try {
            foundReports.addAll(
              userIdResponse.map((json) => ReportModel.fromJson(json)).toList(),
            );
          } catch (jsonError) {
            debugPrint('Error parsing JSON: $jsonError', wrapWidth: 1024);
          }
        }
      } catch (e) {}

      // Strategy 2: Search by reporter_national_id if we have identifier
      final userIdentifier = currentUser.identifier;
      if (userIdentifier != null && userIdentifier.isNotEmpty) {
        try {
          final nationalIdResponse = await supabaseClient
              .from('reports')
              .select('''
                *,
                report_types(name, name_ar, priority_level),
                users!reports_user_id_fkey(full_name, email),
                report_media(id, media_type, file_url, file_name)
              ''')
              .eq('reporter_national_id', userIdentifier)
              .order('submitted_at', ascending: false);

          if (nationalIdResponse.isNotEmpty) {
            // Avoid duplicates by checking IDs
            try {
              for (final json in nationalIdResponse) {
                final report = ReportModel.fromJson(json);
                if (!foundReports.any((r) => r.id == report.id)) {
                  foundReports.add(report);
                }
              }
            } catch (jsonError) {}
          }
        } catch (e) {}
      }

      // Strategy 3: Alternative search by national_id if available
      if (currentUser.nationalId != null &&
          currentUser.nationalId!.isNotEmpty) {
        try {
          final altNationalIdResponse = await supabaseClient
              .from('reports')
              .select('''
                *,
                report_types(name, name_ar, priority_level),
                users!reports_user_id_fkey(full_name, email),
                report_media(id, media_type, file_url, file_name)
              ''')
              .eq('reporter_national_id', currentUser.nationalId!)
              .order('submitted_at', ascending: false);

          if (altNationalIdResponse.isNotEmpty) {
            // Avoid duplicates by checking IDs
            for (final json in altNationalIdResponse) {
              final report = ReportModel.fromJson(json);
              if (!foundReports.any((r) => r.id == report.id)) {
                foundReports.add(report);
              }
            }
          }
        } catch (e) {}
      }

      // Strategy 4: Emergency fallback - get all reports and filter locally
      if (foundReports.isEmpty) {
        try {
          // First try with simple query (no joins) to avoid foreign key issues
          final simpleResponse = await supabaseClient
              .from('reports')
              .select('*')
              .eq('user_id', currentUser.id.toString())
              .order('submitted_at', ascending: false);

          if (simpleResponse.isNotEmpty) {
            try {
              for (final json in simpleResponse) {
                final report = ReportModel.fromJson(json);
                foundReports.add(report);
              }
            } catch (jsonError) {}
          } else {
            // If still no results, try the comprehensive fallback
            final allReportsResponse = await supabaseClient
                .from('reports')
                .select('''
                  *,
                  report_types(name, name_ar, priority_level),
                  users!reports_user_id_fkey(full_name, email),
                  report_media(id, media_type, file_url, file_name)
                ''')
                .order('submitted_at', ascending: false)
                .limit(1000); // Reasonable limit

            // Filter locally by any matching criteria
            for (final json in allReportsResponse) {
              final reportData = json;
              final reportUserId = reportData['user_id']?.toString();
              final reporterNationalId =
                  reportData['reporter_national_id']?.toString();

              if ((reportUserId == currentUser.id) ||
                  (userIdentifier != null &&
                      reporterNationalId == userIdentifier) ||
                  (currentUser.nationalId != null &&
                      reporterNationalId == currentUser.nationalId)) {
                final report = ReportModel.fromJson(json);
                if (!foundReports.any((r) => r.id == report.id)) {
                  foundReports.add(report);
                }
              }
            }
          }
        } catch (e) {}
      }

      // Sort by update date (most recent first)
      foundReports.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      if (foundReports.isNotEmpty) {}

      return foundReports;
    } catch (e) {
      throw Exception('خطأ في جلب البلاغات: $e');
    }
  }

  @override
  Future<ReportModel> getReportById(String id) async {
    try {
      final response =
          await supabaseClient
              .from('reports')
              .select('''
            *,
            report_media(*)
          ''')
              .eq('id', id)
              .single();

      // Extract first media file if available
      final mediaList = response['report_media'] as List?;

      if (mediaList != null && mediaList.isNotEmpty) {
        final firstMedia = mediaList.first;
        response['media_url'] = firstMedia['file_url'];
        response['media_type'] = firstMedia['media_type'];
      } else {}

      return ReportModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch report: $e');
    }
  }

  @override
  Future<ReportModel> createReport(ReportModel report) async {
    try {
      final response =
          await supabaseClient
              .from('reports')
              .insert(report.toInsertJson())
              .select()
              .single();

      return ReportModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create report: $e');
    }
  }

  @override
  Future<ReportModel> updateReport(ReportModel report) async {
    try {
      final response =
          await supabaseClient
              .from('reports')
              .update({
                'report_status': ReportModel.mapEnumToDatabaseStatus(
                  report.status,
                ),
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', report.id)
              .select()
              .single();

      return ReportModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update report: $e');
    }
  }

  @override
  Future<void> deleteReport(String id) async {
    try {
      await supabaseClient.from('reports').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }

  @override
  Future<String?> uploadMedia(File file, String fileName) async {
    try {
      // Check if file exists before attempting to read
      if (!await file.exists()) {
        throw Exception('File does not exist at path: ${file.path}');
      }

      // Check if file is readable and not empty
      final fileStats = await file.stat();

      if (fileStats.size == 0) {
        throw Exception('File is empty: ${file.path}');
      }

      // Read file bytes
      final bytes = await file.readAsBytes();

      // Generate proper file name with extension
      final extension = file.path.split('.').last.toLowerCase();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fullFileName = '${fileName}_$timestamp.$extension';

      // Upload to Supabase Storage
      await supabaseClient.storage
          .from('reports-media')
          .uploadBinary(fullFileName, bytes);

      // Get public URL
      final url = supabaseClient.storage
          .from('reports-media')
          .getPublicUrl(fullFileName);

      // Verify the URL is not empty
      if (url.isEmpty) {
        throw Exception('Failed to generate public URL for uploaded file');
      }

      return url;
    } catch (e) {
      // Re-throw with more specific error information
      if (e.toString().contains('Row level security')) {
        throw Exception(
          'Storage access denied. Please check bucket permissions.',
        );
      } else if (e.toString().contains('Bucket not found')) {
        throw Exception(
          'Storage bucket "reports-media" not found. Please create it first.',
        );
      } else if (e.toString().contains('File size')) {
        throw Exception('File size exceeds maximum allowed limit.');
      }
      throw Exception('Failed to upload media: $e');
    }
  }

  @override
  Future<void> attachMediaToReport(
    String reportId,
    String mediaUrl,
    String mediaType,
  ) async {
    try {
      // Validate inputs
      if (reportId.isEmpty) {
        throw Exception('Report ID cannot be empty');
      }

      if (mediaUrl.isEmpty) {
        throw Exception('Media URL cannot be empty');
      }

      // Extract file name from URL
      final fileName = mediaUrl.split('/').last;

      // Insert media record
      await supabaseClient.from('report_media').insert({
        'report_id': reportId,
        'media_type': mediaType,
        'file_url': mediaUrl,
        'file_name': fileName,
        'is_evidence': true,
        'uploaded_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Provide more specific error messages
      if (e.toString().contains('foreign key')) {
        throw Exception(
          'Report with ID $reportId not found. Cannot attach media to non-existent report.',
        );
      } else if (e.toString().contains('duplicate')) {
        throw Exception('Media already attached to this report.');
      }

      throw Exception('Failed to attach media to report: $e');
    }
  }

  @override
  Future<List<String>> uploadMultipleMedia(
    List<File> files,
    String baseFileName,
  ) async {
    List<String> mediaUrls = [];

    try {
      debugPrint('📤 Uploading ${files.length} media files...');

      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        final fileName = '${baseFileName}_${i + 1}';

        debugPrint('📤 Uploading file ${i + 1}/${files.length}: ${file.path}');

        final mediaUrl = await uploadMedia(file, fileName);
        if (mediaUrl != null && mediaUrl.isNotEmpty) {
          mediaUrls.add(mediaUrl);
          debugPrint('✅ File ${i + 1} uploaded successfully: $mediaUrl');
        } else {
          debugPrint('❌ Failed to upload file ${i + 1}');
        }
      }

      debugPrint(
        '✅ Uploaded ${mediaUrls.length}/${files.length} files successfully',
      );
      return mediaUrls;
    } catch (e) {
      debugPrint('❌ Failed to upload multiple media files: $e');
      throw Exception('Failed to upload multiple media files: $e');
    }
  }

  @override
  Future<void> attachMultipleMediaToReport(
    String reportId,
    List<Map<String, String>> mediaList,
  ) async {
    try {
      debugPrint(
        '🔗 Attaching ${mediaList.length} media files to report $reportId...',
      );

      for (int i = 0; i < mediaList.length; i++) {
        final mediaInfo = mediaList[i];
        debugPrint('🔗 Attaching media ${i + 1}/${mediaList.length}...');

        await attachMediaToReport(
          reportId,
          mediaInfo['url']!,
          mediaInfo['type']!,
        );

        debugPrint('✅ Media ${i + 1} attached successfully');
      }

      debugPrint('✅ All ${mediaList.length} media files attached successfully');
    } catch (e) {
      debugPrint('❌ Failed to attach multiple media to report: $e');
      throw Exception('Failed to attach multiple media to report: $e');
    }
  }
}
