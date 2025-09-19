import 'dart:io';
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
      final response = await supabaseClient
          .from('reports')
          .select('''
            *,
            report_media(*)
          ''')
          .order('submitted_at', ascending: false);

      return (response as List).map((json) {
        // Extract first media file if available
        final mediaList = json['report_media'] as List?;
        print('📥 Datasource Debug for report ${json['id']}:');
        print('   report_media list: $mediaList');

        if (mediaList != null && mediaList.isNotEmpty) {
          final firstMedia = mediaList.first;
          json['media_url'] = firstMedia['file_url'];
          json['media_type'] = firstMedia['media_type'];
          print('   Setting media_url: ${firstMedia['file_url']}');
          print('   Setting media_type: ${firstMedia['media_type']}');
        } else {
          print('   No media found for this report');
        }

        return ReportModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch reports: $e');
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
