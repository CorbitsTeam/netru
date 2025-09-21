import '../../../../core/network/api_client.dart';
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
  final ApiClient apiClient;
  final SupabaseEdgeFunctionsService edgeFunctionsService;

  AdminReportRemoteDataSourceImpl({
    required this.apiClient,
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
      final queryParams = <String, dynamic>{
        'select': '''
          id, user_id, report_type, title, description, 
          governorate, city, district, address, latitude, longitude,
          report_status, priority, assigned_to, media_attachments,
          created_at, updated_at, investigation_notes
        ''',
        'order': 'created_at.desc',
      };

      if (page != null && limit != null) {
        queryParams['offset'] = page * limit;
        queryParams['limit'] = limit;
      }

      if (status != null) {
        queryParams['report_status'] = 'eq.$status';
      }

      if (governorate != null) {
        queryParams['governorate'] = 'eq.$governorate';
      }

      if (reportType != null) {
        queryParams['report_type'] = 'eq.$reportType';
      }

      if (search != null && search.isNotEmpty) {
        queryParams['or'] =
            'title.ilike.*$search*,description.ilike.*$search*,address.ilike.*$search*';
      }

      if (startDate != null) {
        queryParams['created_at'] = 'gte.${startDate.toIso8601String()}';
      }

      if (endDate != null) {
        if (queryParams.containsKey('created_at')) {
          queryParams['created_at'] =
              '${queryParams['created_at']}&lte.${endDate.toIso8601String()}';
        } else {
          queryParams['created_at'] = 'lte.${endDate.toIso8601String()}';
        }
      }

      final response = await apiClient.dio.get(
        '${ApiEndpoints.rest}/reports',
        queryParameters: queryParams,
      );

      return (response.data as List)
          .map((json) => AdminReportModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get reports: $e');
    }
  }

  @override
  Future<AdminReportModel> getReportById(String reportId) async {
    try {
      final response = await apiClient.dio.get(
        '${ApiEndpoints.rest}/reports',
        queryParameters: {
          'id': 'eq.$reportId',
          'select': '''
            id, user_id, report_type, title, description, 
            governorate, city, district, address, latitude, longitude,
            report_status, priority, assigned_to, media_attachments,
            created_at, updated_at, investigation_notes
          ''',
        },
      );

      final reports = response.data as List;
      if (reports.isEmpty) {
        throw Exception('Report not found');
      }

      return AdminReportModel.fromJson(reports.first);
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
        updateData['investigation_notes'] = notes;
      }

      await apiClient.dio.patch(
        '${ApiEndpoints.rest}/reports',
        queryParameters: {'id': 'eq.$reportId'},
        data: updateData,
      );

      // Log the status change
      await apiClient.dio.post(
        '${ApiEndpoints.rest}/report_logs',
        data: {
          'report_id': reportId,
          'action':
              'Status changed to $status${notes != null ? " - $notes" : ""}',
          'created_at': DateTime.now().toIso8601String(),
        },
      );

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
      // Use Edge Function for assignment
      final result = await edgeFunctionsService.assignReport(
        reportId: reportId,
        investigatorId: investigatorId,
        notes: notes,
      );

      if (result['success'] != true) {
        throw Exception(result['error'] ?? 'Assignment failed');
      }

      // Return updated report
      return await getReportById(reportId);
    } catch (e) {
      throw Exception('Failed to assign report: $e');
    }
  }

  @override
  Future<void> deleteReport(String reportId) async {
    try {
      await apiClient.dio.delete(
        '${ApiEndpoints.rest}/reports',
        queryParameters: {'id': 'eq.$reportId'},
      );
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }

  @override
  Future<List<AdminReportModel>> getReportsByInvestigator(
    String investigatorId,
  ) async {
    try {
      final response = await apiClient.dio.get(
        '${ApiEndpoints.rest}/reports',
        queryParameters: {
          'assigned_to': 'eq.$investigatorId',
          'select': '''
            id, user_id, report_type, title, description, 
            governorate, city, district, address, latitude, longitude,
            report_status, priority, assigned_to, media_attachments,
            created_at, updated_at, investigation_notes
          ''',
          'order': 'created_at.desc',
        },
      );

      return (response.data as List)
          .map((json) => AdminReportModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get reports by investigator: $e');
    }
  }

  @override
  Future<List<AdminReportModel>> getPendingReports() async {
    try {
      final response = await apiClient.dio.get(
        '${ApiEndpoints.rest}/reports',
        queryParameters: {
          'report_status': 'eq.pending',
          'select': '''
            id, user_id, report_type, title, description, 
            governorate, city, district, address, latitude, longitude,
            report_status, priority, assigned_to, media_attachments,
            created_at, updated_at, investigation_notes
          ''',
          'order': 'created_at.desc',
        },
      );

      return (response.data as List)
          .map((json) => AdminReportModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get pending reports: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getReportStatistics() async {
    try {
      // Get total reports
      final totalResponse = await apiClient.dio.get(
        '${ApiEndpoints.rest}/reports',
        queryParameters: {'select': 'count()'},
      );

      // Get reports by status
      final statusResponse = await apiClient.dio.post(
        '${ApiEndpoints.rest}/rpc/get_reports_by_status',
      );

      // Get reports by type
      final typeResponse = await apiClient.dio.post(
        '${ApiEndpoints.rest}/rpc/get_reports_by_type',
      );

      // Get reports by governorate
      final governorateResponse = await apiClient.dio.post(
        '${ApiEndpoints.rest}/rpc/get_reports_by_governorate',
      );

      return {
        'total_reports': totalResponse.data?.length ?? 0,
        'by_status': statusResponse.data ?? {},
        'by_type': typeResponse.data ?? {},
        'by_governorate': governorateResponse.data ?? {},
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
        data: {'report_id': reportId, 'type': 'report_update'},
        type: 'report_notification',
      );
    } catch (e) {
      throw Exception('Failed to send report notification: $e');
    }
  }
}
