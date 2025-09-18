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
        if (mediaList != null && mediaList.isNotEmpty) {
          final firstMedia = mediaList.first;
          json['media_url'] = firstMedia['file_url'];
          json['media_type'] = firstMedia['media_type'];
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
      if (mediaList != null && mediaList.isNotEmpty) {
        final firstMedia = mediaList.first;
        response['media_url'] = firstMedia['file_url'];
        response['media_type'] = firstMedia['media_type'];
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
      // Check if file exists before attempting to read
      if (!await file.exists()) {
        throw Exception('File does not exist at path: ${file.path}');
      }

      // Check if file is readable
      try {
        final fileStats = await file.stat();
        if (fileStats.size == 0) {
          throw Exception('File is empty: ${file.path}');
        }
      } catch (e) {
        throw Exception('Cannot access file: ${file.path} - $e');
      }

      final bytes = await file.readAsBytes();

      // Add file extension to fileName if not present
      final extension = file.path.split('.').last.toLowerCase();
      final fullFileName =
          fileName.contains('.') ? fileName : '$fileName.$extension';

      await supabaseClient.storage
          .from('reports-media')
          .uploadBinary(fullFileName, bytes);

      final url = supabaseClient.storage
          .from('reports-media')
          .getPublicUrl(fullFileName);

      return url;
    } catch (e) {
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
      await supabaseClient.from('report_media').insert({
        'report_id': reportId,
        'media_type': mediaType,
        'file_url': mediaUrl,
        'file_name': mediaUrl.split('/').last,
        'is_evidence': true,
      });
    } catch (e) {
      throw Exception('Failed to attach media to report: $e');
    }
  }
}
