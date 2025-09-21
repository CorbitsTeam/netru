import '../../../../core/network/api_client.dart';
import '../../../../core/services/supabase_edge_functions_service.dart';
import '../models/admin_dashboard_model.dart';

abstract class AdminDashboardRemoteDataSource {
  Future<DashboardStatsModel> getDashboardStats();
  Future<Map<String, int>> getReportsByGovernorate();
  Future<Map<String, int>> getReportsByType();
  Future<Map<String, int>> getReportsByStatus();
  Future<List<ReportTrendDataModel>> getReportTrends({
    required DateTime startDate,
    required DateTime endDate,
  });

  // Edge Functions integration
  Future<Map<String, dynamic>> assignReport({
    required String reportId,
    required String investigatorId,
    String? notes,
  });

  Future<Map<String, dynamic>> sendBulkNotifications({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? type,
  });
}

class AdminDashboardRemoteDataSourceImpl
    implements AdminDashboardRemoteDataSource {
  final ApiClient apiClient;
  final SupabaseEdgeFunctionsService edgeFunctionsService;

  AdminDashboardRemoteDataSourceImpl({
    required this.apiClient,
    required this.edgeFunctionsService,
  });

  @override
  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      // Get reports with status
      final reportsResponse = await apiClient.dio.get(
        '${ApiEndpoints.rest}/reports',
        queryParameters: {'select': 'report_status'},
      );

      // Get users with type
      final usersResponse = await apiClient.dio.get(
        '${ApiEndpoints.rest}/users',
        queryParameters: {'select': 'user_type'},
      );

      // Get pending verifications
      final verificationsResponse = await apiClient.dio.get(
        '${ApiEndpoints.rest}/users',
        queryParameters: {
          'select': 'verification_status',
          'verification_status': 'eq.pending',
        },
      );

      // Get news articles
      final newsResponse = await apiClient.dio.get(
        '${ApiEndpoints.rest}/news_articles',
        queryParameters: {'select': 'is_published'},
      );

      // Process data and create stats model
      final totalReports = reportsResponse.data?.length ?? 0;
      final reportsByStatus = _processReportsByStatus(
        reportsResponse.data ?? [],
      );
      final usersByType = _processUsersByType(usersResponse.data ?? []);
      final pendingVerifications = verificationsResponse.data?.length ?? 0;
      final newsByStatus = _processNewsByStatus(newsResponse.data ?? []);

      // Get geographical and type distributions
      final reportsByGovernorate = await getReportsByGovernorate();
      final reportsByType = await getReportsByType();

      // Get recent trends (last 30 days)
      final reportTrends = await getReportTrends(
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      );

      return DashboardStatsModel(
        totalReports: totalReports,
        pendingReports: reportsByStatus['pending'] ?? 0,
        underInvestigationReports: reportsByStatus['under_investigation'] ?? 0,
        resolvedReports: reportsByStatus['resolved'] ?? 0,
        rejectedReports: reportsByStatus['rejected'] ?? 0,
        totalUsers: usersResponse.data?.length ?? 0,
        citizenUsers: usersByType['citizen'] ?? 0,
        foreignerUsers: usersByType['foreigner'] ?? 0,
        adminUsers: usersByType['admin'] ?? 0,
        pendingVerifications: pendingVerifications,
        totalNewsArticles: newsResponse.data?.length ?? 0,
        publishedNewsArticles: newsByStatus['published'] ?? 0,
        reportsByGovernorate: reportsByGovernorate,
        reportsByType: reportsByType,
        reportsByStatus: reportsByStatus.map((k, v) => MapEntry(k, v)),
        reportTrends: reportTrends,
      );
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }

  @override
  Future<Map<String, int>> getReportsByGovernorate() async {
    try {
      final response = await apiClient.dio.post(
        '${ApiEndpoints.rest}/rpc/get_reports_by_governorate',
      );

      // Handle List response from Supabase RPC function
      if (response.data is List) {
        final Map<String, int> result = {};
        for (final item in response.data as List) {
          if (item is Map<String, dynamic>) {
            final governorate = item['governorate'] as String? ?? 'غير محدد';
            final count = item['count'] as int? ?? 0;
            result[governorate] = count;
          }
        }
        return result;
      }

      return Map<String, int>.from(response.data ?? {});
    } catch (e) {
      throw Exception('Failed to fetch reports by governorate: $e');
    }
  }

  @override
  Future<Map<String, int>> getReportsByType() async {
    try {
      final response = await apiClient.dio.post(
        '${ApiEndpoints.rest}/rpc/get_reports_by_type',
      );

      // Handle List response from Supabase RPC function
      if (response.data is List) {
        final Map<String, int> result = {};
        for (final item in response.data as List) {
          if (item is Map<String, dynamic>) {
            final type = item['report_type'] as String? ?? 'other';
            final count = item['count'] as int? ?? 0;
            result[type] = count;
          }
        }
        return result;
      }

      return Map<String, int>.from(response.data ?? {});
    } catch (e) {
      throw Exception('Failed to fetch reports by type: $e');
    }
  }

  @override
  Future<Map<String, int>> getReportsByStatus() async {
    try {
      final response = await apiClient.dio.post(
        '${ApiEndpoints.rest}/rpc/get_reports_by_status',
      );

      // Handle List response from Supabase RPC function
      if (response.data is List) {
        final Map<String, int> result = {};
        for (final item in response.data as List) {
          if (item is Map<String, dynamic>) {
            final status = item['report_status'] as String? ?? 'pending';
            final count = item['count'] as int? ?? 0;
            result[status] = count;
          }
        }
        return result;
      }

      return Map<String, int>.from(response.data ?? {});
    } catch (e) {
      throw Exception('Failed to fetch reports by status: $e');
    }
  }

  @override
  Future<List<ReportTrendDataModel>> getReportTrends({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '${ApiEndpoints.rest}/rpc/get_report_trends',
        data: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );

      return (response.data as List)
          .map((item) => ReportTrendDataModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch report trends: $e');
    }
  }

  Map<String, int> _processReportsByStatus(List<dynamic> reports) {
    final statusCounts = <String, int>{};
    for (final report in reports) {
      final status = report['report_status'] as String? ?? 'pending';
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }
    return statusCounts;
  }

  Map<String, int> _processUsersByType(List<dynamic> users) {
    final typeCounts = <String, int>{};
    for (final user in users) {
      final type = user['user_type'] as String? ?? 'citizen';
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
    }
    return typeCounts;
  }

  Map<String, int> _processNewsByStatus(List<dynamic> articles) {
    final statusCounts = <String, int>{'published': 0, 'draft': 0};
    for (final article in articles) {
      final isPublished = article['is_published'] as bool? ?? false;
      statusCounts[isPublished ? 'published' : 'draft'] =
          (statusCounts[isPublished ? 'published' : 'draft'] ?? 0) + 1;
    }
    return statusCounts;
  }

  @override
  Future<Map<String, dynamic>> assignReport({
    required String reportId,
    required String investigatorId,
    String? notes,
  }) async {
    return await edgeFunctionsService.assignReport(
      reportId: reportId,
      investigatorId: investigatorId,
      notes: notes,
    );
  }

  @override
  Future<Map<String, dynamic>> sendBulkNotifications({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? type,
  }) async {
    return await edgeFunctionsService.sendBulkNotifications(
      userIds: userIds,
      title: title,
      body: body,
      data: data,
      type: type,
    );
  }
}

class AdminApiEndpoints {
  static const String adminBase = '${ApiEndpoints.rest}/admin';
  static const String dashboardStats = '$adminBase/dashboard/stats';
  static const String reportsByGovernorate =
      '$adminBase/reports/by-governorate';
  static const String reportsByType = '$adminBase/reports/by-type';
  static const String reportsByStatus = '$adminBase/reports/by-status';
  static const String reportTrends = '$adminBase/reports/trends';
}
