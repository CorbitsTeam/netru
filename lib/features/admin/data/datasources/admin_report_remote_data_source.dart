import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_edge_functions_service.dart';
import '../models/admin_report_model.dart';

abstract class AdminReportRemoteDataSource {
  Future<List<AdminReportModel>> getAllReports({
    int? page,
    int? limit,
    String? search,
    String? status,
    String? governorate,
    String? reportType,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<AdminReportModel> getReportById(String reportId);

  Future<AdminReportModel> updateReportStatus({
    required String reportId,
    required String status,
    String? notes,
  });

  Future<AdminReportModel> assignReport({
    required String reportId,
    required String investigatorId,
    String? notes,
  });

  Future<void> deleteReport(String reportId);

  Future<List<AdminReportModel>> getReportsByInvestigator(
    String investigatorId,
  );

  Future<List<AdminReportModel>> getPendingReports();

  Future<Map<String, dynamic>> getReportStatistics();

  Future<void> sendReportNotification({
    required String reportId,
    required String userId,
    required String title,
    required String body,
  });
}

class AdminReportRemoteDataSourceImpl implements AdminReportRemoteDataSource {
  final SupabaseClient supabaseClient;
  final SupabaseEdgeFunctionsService edgeFunctionsService;

  AdminReportRemoteDataSourceImpl({
    required this.supabaseClient,
    required this.edgeFunctionsService,
  });

  @override
  Future<List<AdminReportModel>> getAllReports({
    int? page,
    int? limit,
    String? search,
    String? status,
    String? governorate,
    String? reportType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      PostgrestFilterBuilder<PostgrestList> query = supabaseClient
          .from('reports')
          .select('''
            *,
            report_types(name)
          ''');

      // Apply filters
      if (status != null) {
        query = query.eq('report_status', status);
      }

      if (governorate != null) {
        query = query.eq('incident_location_address', governorate);
      }

      if (reportType != null) {
        query = query.eq('report_type_id', reportType);
      }

      if (search != null && search.isNotEmpty) {
        query = query.or(
          'report_details.ilike.%$search%,reporter_first_name.ilike.%$search%,reporter_last_name.ilike.%$search%',
        );
      }

      if (startDate != null) {
        query = query.gte('submitted_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('submitted_at', endDate.toIso8601String());
      }

      // Apply order and pagination
      PostgrestTransformBuilder<PostgrestList> finalQuery = query.order(
        'submitted_at',
        ascending: false,
      );

      if (page != null && limit != null) {
        final start = page * limit;
        final end = start + limit - 1;
        finalQuery = finalQuery.range(start, end);
      }

      final response = await finalQuery;

      return (response as List)
          .map((json) => AdminReportModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get reports: $e');
    }
  }

  @override
  Future<AdminReportModel> getReportById(String reportId) async {
    try {
      final response =
          await supabaseClient
              .from('reports')
              .select('''
            *,
            report_types(name),
            report_media(*),
            report_comments(*),
            report_status_history(*)
          ''')
              .eq('id', reportId)
              .single();

      return AdminReportModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch report: $e');
    }
  }

  @override
  Future<AdminReportModel> updateReportStatus({
    required String reportId,
    required String status,
    String? notes,
  }) async {
    try {
      final updateData = {
        'report_status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (notes != null && notes.isNotEmpty) {
        updateData['admin_notes'] = notes;
      }

      await supabaseClient
          .from('reports')
          .update(updateData)
          .eq('id', reportId);

      // Log the status change
      await supabaseClient.from('report_status_history').insert({
        'report_id': reportId,
        'new_status': status,
        'changed_at': DateTime.now().toIso8601String(),
        'notes': notes,
      });

      // Return updated report
      return await getReportById(reportId);
    } catch (e) {
      throw Exception('Failed to update report status: $e');
    }
  }

  @override
  Future<AdminReportModel> assignReport({
    required String reportId,
    required String investigatorId,
    String? notes,
  }) async {
    try {
      await supabaseClient
          .from('reports')
          .update({
            'assigned_to': investigatorId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reportId);

      // Log the assignment
      await supabaseClient.from('report_assignments').insert({
        'report_id': reportId,
        'assigned_to': investigatorId,
        'assigned_at': DateTime.now().toIso8601String(),
        'assignment_notes': notes,
      });

      // Return updated report
      return await getReportById(reportId);
    } catch (e) {
      throw Exception('Failed to assign report: $e');
    }
  }

  @override
  Future<void> deleteReport(String reportId) async {
    try {
      await supabaseClient.from('reports').delete().eq('id', reportId);
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }

  @override
  Future<List<AdminReportModel>> getReportsByInvestigator(
    String investigatorId,
  ) async {
    try {
      final response = await supabaseClient
          .from('reports')
          .select('''
            *,
            report_types(name)
          ''')
          .eq('assigned_to', investigatorId)
          .order('submitted_at', ascending: false);

      return (response as List)
          .map((json) => AdminReportModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get reports by investigator: $e');
    }
  }

  @override
  Future<List<AdminReportModel>> getPendingReports() async {
    try {
      final response = await supabaseClient
          .from('reports')
          .select('''
            *,
            report_types(name)
          ''')
          .eq('report_status', 'pending')
          .order('submitted_at', ascending: false);

      return (response as List)
          .map((json) => AdminReportModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get pending reports: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getReportStatistics() async {
    try {
      // Get total reports count using simple query and count length
      final totalResponse = await supabaseClient.from('reports').select('id');

      final pendingResponse = await supabaseClient
          .from('reports')
          .select('id')
          .eq('report_status', 'pending');

      final underInvestigationResponse = await supabaseClient
          .from('reports')
          .select('id')
          .eq('report_status', 'under_investigation');

      final resolvedResponse = await supabaseClient
          .from('reports')
          .select('id')
          .eq('report_status', 'resolved');

      return {
        'total': (totalResponse as List).length,
        'pending': (pendingResponse as List).length,
        'under_investigation': (underInvestigationResponse as List).length,
        'resolved': (resolvedResponse as List).length,
      };
    } catch (e) {
      throw Exception('Failed to get report statistics: $e');
    }
  }

  @override
  Future<void> sendReportNotification({
    required String reportId,
    required String userId,
    required String title,
    required String body,
  }) async {
    try {
      await edgeFunctionsService.sendBulkNotifications(
        userIds: [userId],
        title: title,
        body: body,
        data: {'report_id': reportId},
        type: 'report_notification',
      );
    } catch (e) {
      throw Exception('Failed to send report notification: $e');
    }
  }
}
