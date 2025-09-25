import 'dart:io';
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
  Future<void> attachMediaToReport(
    String reportId,
    String mediaUrl,
    String mediaType,
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

      print('🔍 Debug - Current User Info:');
      print('   ID: ${currentUser.id}');
      print('   User Type: ${currentUser.userType}');
      print('   National ID: ${currentUser.nationalId}');
      print('   Passport: ${currentUser.passportNumber}');
      print('   Identifier: ${currentUser.identifier}');

      // Strategy 1: Try multiple search approaches comprehensively
      List<ReportModel> foundReports = [];

      // Primary search: Use user_id
      print('🔍 Debug - Strategy 1: Search by user_id: ${currentUser.id}');
      try {
        final userIdResponse = await supabaseClient
            .from('reports')
            .select('''
              *,
              report_types(name, name_ar, priority_level),
              users!reports_user_id_fkey(full_name, email),
              report_media(id, media_type, file_url, file_name)
            ''')
            .eq('user_id', currentUser.id!)
            .order('submitted_at', ascending: false);

        print(
          '🔍 Debug - user_id query result count: ${userIdResponse.length}',
        );
        print('🔍 Debug - Raw query response: $userIdResponse');

        if (userIdResponse.isNotEmpty) {
          try {
            foundReports.addAll(
              userIdResponse.map((json) => ReportModel.fromJson(json)).toList(),
            );
            print('✅ Found ${userIdResponse.length} reports using user_id');
          } catch (jsonError) {
            print('❌ JSON parsing error in user_id strategy: $jsonError');
          }
        }
      } catch (e) {
        print('⚠️ user_id search failed: $e');
      }

      // Strategy 2: Search by reporter_national_id if we have identifier
      final userIdentifier = currentUser.identifier;
      if (userIdentifier != null && userIdentifier.isNotEmpty) {
        print(
          '🔍 Debug - Strategy 2: Search by reporter_national_id: $userIdentifier',
        );
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

          print(
            '🔍 Debug - reporter_national_id query result count: ${nationalIdResponse.length}',
          );
          print('🔍 Debug - Raw nationalId response: $nationalIdResponse');

          if (nationalIdResponse.isNotEmpty) {
            // Avoid duplicates by checking IDs
            try {
              for (final json in nationalIdResponse) {
                final report = ReportModel.fromJson(json);
                if (!foundReports.any((r) => r.id == report.id)) {
                  foundReports.add(report);
                }
              }
              print(
                '✅ Found ${nationalIdResponse.length} additional reports using reporter_national_id',
              );
            } catch (jsonError) {
              print('❌ JSON parsing error in nationalId strategy: $jsonError');
            }
          }
        } catch (e) {
          print('⚠️ reporter_national_id search failed: $e');
        }
      }

      // Strategy 3: Alternative search by national_id if available
      if (currentUser.nationalId != null &&
          currentUser.nationalId!.isNotEmpty) {
        print(
          '🔍 Debug - Strategy 3: Search by national_id from user: ${currentUser.nationalId}',
        );
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

          print(
            '🔍 Debug - alternative national_id query result count: ${altNationalIdResponse.length}',
          );
          if (altNationalIdResponse.isNotEmpty) {
            // Avoid duplicates by checking IDs
            for (final json in altNationalIdResponse) {
              final report = ReportModel.fromJson(json);
              if (!foundReports.any((r) => r.id == report.id)) {
                foundReports.add(report);
              }
            }
            print(
              '✅ Found ${altNationalIdResponse.length} additional reports using alternative national_id',
            );
          }
        } catch (e) {
          print('⚠️ alternative national_id search failed: $e');
        }
      }

      // Strategy 4: Emergency fallback - get all reports and filter locally
      if (foundReports.isEmpty) {
        print('🔍 Debug - Strategy 4: Emergency fallback - search all reports');
        try {
          // First try with simple query (no joins) to avoid foreign key issues
          final simpleResponse = await supabaseClient
              .from('reports')
              .select('*')
              .eq('user_id', currentUser.id!)
              .order('submitted_at', ascending: false);

          print(
            '🔍 Debug - Simple query result count: ${simpleResponse.length}',
          );
          print('🔍 Debug - Simple query response: $simpleResponse');

          if (simpleResponse.isNotEmpty) {
            try {
              for (final json in simpleResponse) {
                final report = ReportModel.fromJson(json);
                foundReports.add(report);
              }
              print('✅ Simple query found ${simpleResponse.length} reports');
            } catch (jsonError) {
              print('❌ JSON parsing error in simple query: $jsonError');
            }
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

            print(
              '🔍 Debug - Total reports in database: ${allReportsResponse.length}',
            );

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
            print(
              '✅ Emergency fallback found ${foundReports.length} matching reports',
            );
          }
        } catch (e) {
          print('⚠️ Emergency fallback failed: $e');
        }
      }

      // Sort by update date (most recent first)
      foundReports.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      print(
        '📊 Final result: Found ${foundReports.length} total reports for user',
      );
      if (foundReports.isNotEmpty) {
        print('📋 Report IDs: ${foundReports.map((r) => r.id).join(", ")}');
      }

      return foundReports;
    } catch (e) {
      print('❌ Critical error in getAllReports: $e');
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
      print('📥 Datasource getReportById Debug for report $id:');
      print('   report_media list: $mediaList');

      if (mediaList != null && mediaList.isNotEmpty) {
        final firstMedia = mediaList.first;
        response['media_url'] = firstMedia['file_url'];
        response['media_type'] = firstMedia['media_type'];
        print('   Setting media_url: ${firstMedia['file_url']}');
        print('   Setting media_type: ${firstMedia['media_type']}');
      } else {
        print('   No media found for this report');
      }

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
      print('Starting media upload for file: ${file.path}');

      // Check if file exists before attempting to read
      if (!await file.exists()) {
        print('File does not exist at path: ${file.path}');
        throw Exception('File does not exist at path: ${file.path}');
      }

      // Check if file is readable and not empty
      final fileStats = await file.stat();
      print('File size: ${fileStats.size} bytes');

      if (fileStats.size == 0) {
        print('File is empty: ${file.path}');
        throw Exception('File is empty: ${file.path}');
      }

      // Read file bytes
      final bytes = await file.readAsBytes();
      print('Successfully read ${bytes.length} bytes from file');

      // Generate proper file name with extension
      final extension = file.path.split('.').last.toLowerCase();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fullFileName = '${fileName}_$timestamp.$extension';

      print('Uploading file with name: $fullFileName to bucket: reports-media');

      // Upload to Supabase Storage
      final uploadResponse = await supabaseClient.storage
          .from('reports-media')
          .uploadBinary(fullFileName, bytes);

      print('Upload response: $uploadResponse');

      // Get public URL
      final url = supabaseClient.storage
          .from('reports-media')
          .getPublicUrl(fullFileName);

      print('Generated public URL: $url');

      // Verify the URL is not empty
      if (url.isEmpty) {
        throw Exception('Failed to generate public URL for uploaded file');
      }

      return url;
    } catch (e) {
      print('Error in uploadMedia: $e');
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
      print('Attaching media to report: $reportId');
      print('Media URL: $mediaUrl');
      print('Media Type: $mediaType');

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
      final response =
          await supabaseClient
              .from('report_media')
              .insert({
                'report_id': reportId,
                'media_type': mediaType,
                'file_url': mediaUrl,
                'file_name': fileName,
                'is_evidence': true,
                'uploaded_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();

      print('Successfully attached media to report. Media record: $response');
    } catch (e) {
      print('Error in attachMediaToReport: $e');

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
}
