import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/simple_notification_service.dart';
import '../../../../core/services/report_notification_service.dart';
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
  final SimpleNotificationService notificationService;
  final ReportNotificationService reportNotificationService;

  AdminReportRemoteDataSourceImpl({
    required this.supabaseClient,
    required this.notificationService,
    required this.reportNotificationService,
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
      var query = supabaseClient.from('reports').select('''
            *,
            report_media(*),
            report_comments(*),
            report_status_history(*)
          ''');

      if (status != null && status.isNotEmpty) {
        query = query.eq('report_status', status);
      }

      if (search != null && search.isNotEmpty) {
        query = query.ilike('report_details', '%$search%');
      }

      if (governorate != null && governorate.isNotEmpty) {
        query = query.ilike('incident_location_address', '%$governorate%');
      }

      if (reportType != null && reportType.isNotEmpty) {
        query = query.eq('report_type_id', reportType);
      }

      if (startDate != null) {
        query = query.gte('submitted_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('submitted_at', endDate.toIso8601String());
      }

      var orderedQuery = query.order('submitted_at', ascending: false);

      if (page != null && limit != null) {
        final offset = (page - 1) * limit;
        orderedQuery = orderedQuery.range(offset, offset + limit - 1);
      }

      final response = await orderedQuery;
      return response
          .map<AdminReportModel>((json) => AdminReportModel.fromJson(json))
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
            report_media(*),
            report_comments(*),
            report_status_history(*)
          ''')
              .eq('id', reportId)
              .single();

      return AdminReportModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get report: $e');
    }
  }

  @override
  Future<AdminReportModel> updateReportStatus({
    required String reportId,
    required String status,
    String? notes,
  }) async {
    try {
      // Get current report data first
      final currentReport = await getReportById(reportId);

      // Update the report status
      await supabaseClient
          .from('reports')
          .update({
            'report_status': status,
            'admin_notes': notes,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reportId);

      // Add to status history
      await supabaseClient.from('report_status_history').insert({
        'report_id': reportId,
        'previous_status':
            currentReport.reportStatus.toString().split('.').last,
        'new_status': status,
        'changed_by': supabaseClient.auth.currentUser?.id,
        'change_reason': 'Status updated by admin',
        'notes': notes,
      });

      // Send notification to user if report has a user ID (non-anonymous)
      if (currentReport.userId != null) {
        await _sendStatusUpdateNotification(
          reportId: reportId,
          status: status,
          caseNumber: currentReport.caseNumber ?? reportId.substring(0, 8),
          adminNotes: notes,
        );
      }

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
      // Get current report data first
      final currentReport = await getReportById(reportId);

      await supabaseClient
          .from('reports')
          .update({
            'assigned_to': investigatorId,
            'admin_notes': notes,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reportId);

      // Add assignment record
      await supabaseClient.from('report_assignments').insert({
        'report_id': reportId,
        'assigned_to': investigatorId,
        'assigned_by': supabaseClient.auth.currentUser?.id,
        'assignment_notes': notes,
      });

      // Send notification to report owner about assignment
      if (currentReport.userId != null) {
        await _sendStatusUpdateNotification(
          reportId: reportId,
          status: 'under_investigation',
          caseNumber: currentReport.caseNumber ?? reportId.substring(0, 8),
          adminNotes: 'تم تعيين محقق للبلاغ',
        );
      }

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
          .select('*')
          .eq('assigned_to', investigatorId)
          .order('submitted_at', ascending: false);

      return response
          .map<AdminReportModel>((json) => AdminReportModel.fromJson(json))
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
          .select('*')
          .eq('report_status', 'pending')
          .order('submitted_at', ascending: false);

      return response
          .map<AdminReportModel>((json) => AdminReportModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get pending reports: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getReportStatistics() async {
    try {
      final response = await supabaseClient
          .from('reports')
          .select('report_status, priority_level')
          .order('submitted_at', ascending: false);

      final Map<String, int> statusCounts = {};
      final Map<String, int> priorityCounts = {};

      for (final report in response) {
        final status = report['report_status'] as String?;
        final priority = report['priority_level'] as String?;

        if (status != null) {
          statusCounts[status] = (statusCounts[status] ?? 0) + 1;
        }

        if (priority != null) {
          priorityCounts[priority] = (priorityCounts[priority] ?? 0) + 1;
        }
      }

      return {
        'total': response.length,
        'by_status': statusCounts,
        'by_priority': priorityCounts,
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
      await notificationService.showLocalNotification(
        title: title,
        body: body,
        data: {
          'report_id': reportId,
          'type': 'report_notification',
          'action': 'view_report',
        },
      );
    } catch (e) {
      debugPrint('❌ Failed to send report notification: $e');
    }
  }

  /// Send automatic notification when report status changes using new ReportNotificationService
  Future<void> _sendStatusUpdateNotification({
    required String reportId,
    required String status,
    required String caseNumber,
    String? adminNotes,
  }) async {
    try {
      debugPrint('📱 إرسال إشعار تحديث الحالة للبلاغ: $reportId');

      // استخدام ReportNotificationService الجديد لإرسال الإشعار
      await reportNotificationService.sendReportStatusNotification(
        reportId: reportId,
        newStatus: status,
        caseNumber: caseNumber,
        adminNotes: adminNotes,
      );

      debugPrint('✅ تم إرسال إشعار تحديث الحالة بنجاح');
    } catch (e) {
      debugPrint('❌ خطأ في إرسال إشعار تحديث الحالة: $e');

      // fallback إلى الخدمة البسيطة إذا فشل الإرسال
      try {
        await notificationService.showLocalNotification(
          title: '🔔 تحديث البلاغ',
          body: 'تم تحديث حالة بلاغكم رقم #$caseNumber إلى $status',
        );
      } catch (fallbackError) {
        debugPrint('❌ فشل حتى في الإشعار المحلي: $fallbackError');
      }
    }
  }
}
