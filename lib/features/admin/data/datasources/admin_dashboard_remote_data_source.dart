import '../../../../core/network/api_client.dart';
import '../../../../core/services/supabase_edge_functions_service.dart';
import '../../presentation/widgets/recent_activity_widget.dart';
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
  Future<List<ActivityItem>> getRecentActivities();

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

      // Extract values from processed data
      final totalUsers = usersByType.values.fold(
        0,
        (sum, count) => sum + count,
      );
      final citizenUsers = usersByType['citizen'] ?? 0;
      final foreignerUsers = usersByType['foreigner'] ?? 0;
      final adminUsers = usersByType['admin'] ?? 0;
      final totalNewsArticles = newsByStatus.values.fold(
        0,
        (sum, count) => sum + count,
      );
      final publishedNewsArticles = newsByStatus['published'] ?? 0;

      // Get geographical and type distributions
      final governorateStats = await getReportsByGovernorate();
      final typeStats = await getReportsByType();

      // Get recent trends (last 30 days)
      final trends = await getReportTrends(
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      );

      return DashboardStatsModel(
        totalReports: totalReports,
        receivedReports: reportsByStatus['received'] ?? 0,
        underReviewReports: reportsByStatus['under_review'] ?? 0,
        dataVerificationReports: reportsByStatus['data_verification'] ?? 0,
        actionTakenReports: reportsByStatus['action_taken'] ?? 0,
        completedReports: reportsByStatus['completed'] ?? 0,
        rejectedReports: reportsByStatus['rejected'] ?? 0,
        totalUsers: totalUsers,
        citizenUsers: citizenUsers,
        foreignerUsers: foreignerUsers,
        adminUsers: adminUsers,
        pendingVerifications: pendingVerifications,
        totalNewsArticles: totalNewsArticles,
        publishedNewsArticles: publishedNewsArticles,
        reportsByGovernorate: governorateStats,
        reportsByType: typeStats,
        reportsByStatus: reportsByStatus,
        reportTrends: trends,
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

  @override
  Future<List<ActivityItem>> getRecentActivities() async {
    try {
      print('🔍 Starting to fetch recent activities from database...');
      List<ActivityItem> activities = [];

      // جلب آخر البلاغات المنشأة
      final recentReports = await apiClient.dio.get(
        '${ApiEndpoints.rest}/reports',
        queryParameters: {
          'select':
              'id,report_details,submitted_at,reporter_first_name,reporter_last_name,report_status',
          'order': 'submitted_at.desc',
          'limit': '5',
        },
      );

      if (recentReports.data != null && recentReports.data is List) {
        print('✓ Found ${recentReports.data.length} recent reports');
        for (final report in recentReports.data) {
          final reportDetails =
              report['report_details']?.toString() ?? 'بلاغ جديد';
          final description =
              reportDetails.length > 50
                  ? '${reportDetails.substring(0, 50)}...'
                  : reportDetails;

          activities.add(
            ActivityItem(
              id: report['id'] ?? 'unknown',
              title: 'تم إنشاء بلاغ جديد',
              description:
                  '${report['reporter_first_name'] ?? ''} ${report['reporter_last_name'] ?? ''} - $description',
              type: ActivityType.reportCreated,
              timestamp: DateTime.parse(
                report['submitted_at'] ?? DateTime.now().toIso8601String(),
              ),
              hasAction: true,
            ),
          );
        }
      } else {
        print('⚠️ No recent reports found or invalid data format');
      }

      // جلب آخر المستخدمين المسجلين
      final recentUsers = await apiClient.dio.get(
        '${ApiEndpoints.rest}/users',
        queryParameters: {
          'select': 'id,full_name,created_at,user_type',
          'order': 'created_at.desc',
          'limit': '3',
        },
      );

      if (recentUsers.data != null && recentUsers.data is List) {
        for (final user in recentUsers.data) {
          final userTypeArabic =
              user['user_type'] == 'citizen'
                  ? 'مواطن'
                  : user['user_type'] == 'foreigner'
                  ? 'مقيم أجنبي'
                  : user['user_type'] == 'admin'
                  ? 'إداري'
                  : 'مستخدم';

          activities.add(
            ActivityItem(
              id: 'user_${user['id'] ?? 'unknown'}',
              title: 'مستخدم جديد',
              description:
                  '${user['full_name'] ?? 'مستخدم جديد'} - $userTypeArabic',
              type: ActivityType.userRegistered,
              timestamp: DateTime.parse(
                user['created_at'] ?? DateTime.now().toIso8601String(),
              ),
              hasAction: true,
            ),
          );
        }
      }

      // جلب آخر تعيينات البلاغات
      final recentAssignments = await apiClient.dio.get(
        '${ApiEndpoints.rest}/report_assignments',
        queryParameters: {
          'select': 'id,report_id,assigned_at,assigned_to',
          'order': 'assigned_at.desc',
          'limit': '3',
        },
      );

      if (recentAssignments.data != null && recentAssignments.data is List) {
        for (final assignment in recentAssignments.data) {
          // جلب اسم المحقق
          String assignedToName = 'محقق غير معروف';
          try {
            final userResponse = await apiClient.dio.get(
              '${ApiEndpoints.rest}/users',
              queryParameters: {
                'select': 'full_name',
                'id': 'eq.${assignment['assigned_to']}',
              },
            );
            if (userResponse.data != null &&
                userResponse.data is List &&
                userResponse.data.isNotEmpty) {
              assignedToName =
                  userResponse.data[0]['full_name'] ?? 'محقق غير معروف';
            }
          } catch (e) {
            print('Error fetching assigned user name: $e');
          }

          activities.add(
            ActivityItem(
              id: 'assignment_${assignment['id'] ?? 'unknown'}',
              title: 'تم تعيين بلاغ للمحقق',
              description:
                  'البلاغ ${assignment['report_id'] ?? ''} تم تعيينه للمحقق $assignedToName',
              type: ActivityType.reportAssigned,
              timestamp: DateTime.parse(
                assignment['assigned_at'] ?? DateTime.now().toIso8601String(),
              ),
              hasAction: true,
            ),
          );
        }
      }

      // جلب آخر الإشعارات المرسلة
      final recentNotifications = await apiClient.dio.get(
        '${ApiEndpoints.rest}/notifications',
        queryParameters: {
          'select': 'id,title,notification_type,created_at',
          'order': 'created_at.desc',
          'limit': '3',
        },
      );

      if (recentNotifications.data != null &&
          recentNotifications.data is List) {
        for (final notification in recentNotifications.data) {
          activities.add(
            ActivityItem(
              id: 'notification_${notification['id'] ?? 'unknown'}',
              title: 'تم إرسال إشعار',
              description: notification['title'] ?? 'إشعار جديد',
              type: ActivityType.notificationSent,
              timestamp: DateTime.parse(
                notification['created_at'] ?? DateTime.now().toIso8601String(),
              ),
              hasAction: false,
            ),
          );
        }
      }

      // جلب آخر تحديثات حالة البلاغات
      final recentStatusUpdates = await apiClient.dio.get(
        '${ApiEndpoints.rest}/report_status_history',
        queryParameters: {
          'select': 'id,report_id,new_status,changed_at,change_reason',
          'order': 'changed_at.desc',
          'limit': '2',
        },
      );

      if (recentStatusUpdates.data != null &&
          recentStatusUpdates.data is List) {
        for (final statusUpdate in recentStatusUpdates.data) {
          String statusArabic = statusUpdate['new_status'] ?? 'غير معروف';
          switch (statusUpdate['new_status']) {
            case 'pending':
              statusArabic = 'في الانتظار';
              break;
            case 'under_investigation':
              statusArabic = 'قيد التحقيق';
              break;
            case 'resolved':
              statusArabic = 'تم الحل';
              break;
            case 'closed':
              statusArabic = 'مغلق';
              break;
            case 'rejected':
              statusArabic = 'مرفوض';
              break;
          }

          activities.add(
            ActivityItem(
              id: 'status_${statusUpdate['id'] ?? 'unknown'}',
              title: 'تم تحديث حالة بلاغ',
              description:
                  'البلاغ ${statusUpdate['report_id'] ?? ''} - $statusArabic',
              type: ActivityType.reportUpdated,
              timestamp: DateTime.parse(
                statusUpdate['changed_at'] ?? DateTime.now().toIso8601String(),
              ),
              hasAction: true,
            ),
          );
        }
      }

      // ترتيب الأنشطة حسب التاريخ (الأحدث أولاً)
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      print(
        '✅ Successfully fetched ${activities.length} activities from database',
      );

      // إرجاع أول 10 أنشطة
      return activities.take(10).toList();
    } catch (e) {
      print('❌ Error fetching recent activities: $e');

      // في حالة حدوث خطأ، إرجاع بيانات وهمية كـ fallback
      print('🔄 Falling back to mock data');
      return _getMockActivities();
    }
  }

  List<ActivityItem> _getMockActivities() {
    return [
      ActivityItem(
        id: '1',
        title: 'تم إنشاء بلاغ جديد',
        description: 'بلاغ عن حادث في شارع التحرير، القاهرة',
        type: ActivityType.reportCreated,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        hasAction: true,
      ),
      ActivityItem(
        id: '2',
        title: 'تم توثيق مستخدم جديد',
        description: 'أحمد محمد - مواطن مصري',
        type: ActivityType.userVerified,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        hasAction: true,
      ),
      ActivityItem(
        id: '3',
        title: 'تم تعيين بلاغ للمحقق',
        description: 'بلاغ تم تعيينه للمحقق محمد أحمد',
        type: ActivityType.reportAssigned,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        hasAction: true,
      ),
      ActivityItem(
        id: '4',
        title: 'تم إرسال إشعار جماعي',
        description: 'إشعار أمني لجميع مستخدمي منطقة الجيزة',
        type: ActivityType.notificationSent,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        hasAction: false,
      ),
      ActivityItem(
        id: '5',
        title: 'تم حل بلاغ',
        description: 'تم الانتهاء من التحقيق في بلاغ السرقة',
        type: ActivityType.reportResolved,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        hasAction: true,
      ),
    ];
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
