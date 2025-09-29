import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:netru_app/core/services/logger_service.dart';

/// خدمة إدارة الإشعارات للإدارة
/// Admin Notifications Management Service
class AdminNotificationsService {
  static final AdminNotificationsService _instance =
      AdminNotificationsService._internal();
  factory AdminNotificationsService() => _instance;
  AdminNotificationsService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final LoggerService _logger = LoggerService();

  /// عرض جميع الإشعارات مع الفلترة والترقيم
  /// Get all notifications with filtering and pagination
  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
    String? search,
    String? userId,
    String? status,
  }) async {
    try {
      _logger.logInfo('📋 جاري جلب الإشعارات - صفحة $page');

      final queryParams = <String, String>{
        'action': 'get_notifications',
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (type != null) queryParams['type'] = type;
      if (search != null) queryParams['search'] = search;
      if (userId != null) queryParams['user_id'] = userId;
      if (status != null) queryParams['status'] = status;

      final response = await _supabase.functions.invoke(
        'admin-notifications',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        _logger.logInfo('✅ تم جلب الإشعارات بنجاح');
        return response.data;
      } else {
        throw Exception(response.data['error'] ?? 'فشل في جلب الإشعارات');
      }
    } catch (e) {
      _logger.logError('❌ خطأ في جلب الإشعارات: $e');
      rethrow;
    }
  }

  /// إنشاء إشعار فردي
  /// Create single notification
  Future<Map<String, dynamic>> createNotification({
    required String userId,
    required String title,
    required String body,
    String notificationType = 'general',
    String? referenceId,
    String? referenceType,
    Map<String, dynamic>? data,
  }) async {
    try {
      _logger.logInfo('📝 جاري إنشاء إشعار فردي للمستخدم: $userId');

      final response = await _supabase.functions.invoke(
        'admin-notifications',
        queryParameters: {'action': 'create_notification'},
        body: {
          'user_id': userId,
          'title': title,
          'body': body,
          'notification_type': notificationType,
          if (referenceId != null) 'reference_id': referenceId,
          if (referenceType != null) 'reference_type': referenceType,
          if (data != null) 'data': data,
        },
      );

      if (response.data['success'] == true) {
        _logger.logInfo('✅ تم إنشاء الإشعار بنجاح');
        return response.data;
      } else {
        throw Exception(response.data['error'] ?? 'فشل في إنشاء الإشعار');
      }
    } catch (e) {
      _logger.logError('❌ خطأ في إنشاء الإشعار: $e');
      rethrow;
    }
  }

  /// إرسال إشعار جماعي
  /// Send bulk notification
  Future<Map<String, dynamic>> sendBulkNotification({
    required String title,
    required String body,
    String notificationType = 'general',
    required String targetType, // 'all', 'user_type', 'specific_users'
    dynamic targetValue,
    Map<String, dynamic>? data,
  }) async {
    try {
      _logger.logInfo('📤 جاري إرسال إشعار جماعي: $targetType');

      final response = await _supabase.functions.invoke(
        'admin-notifications',
        queryParameters: {'action': 'send_bulk'},
        body: {
          'title': title,
          'body': body,
          'notification_type': notificationType,
          'target_type': targetType,
          'target_value': targetValue,
          if (data != null) 'data': data,
        },
      );

      if (response.data['success'] == true) {
        _logger.logInfo('✅ تم إرسال الإشعار الجماعي بنجاح');
        return response.data;
      } else {
        throw Exception(
          response.data['error'] ?? 'فشل في إرسال الإشعار الجماعي',
        );
      }
    } catch (e) {
      _logger.logError('❌ خطأ في إرسال الإشعار الجماعي: $e');
      rethrow;
    }
  }

  /// إرسال إشعار لجميع المستخدمين
  /// Send notification to all users
  Future<Map<String, dynamic>> sendToAllUsers({
    required String title,
    required String body,
    String notificationType = 'general',
    Map<String, dynamic>? data,
  }) async {
    return sendBulkNotification(
      title: title,
      body: body,
      notificationType: notificationType,
      targetType: 'all',
      targetValue: null,
      data: data,
    );
  }

  /// إرسال إشعار لنوع مستخدم محدد
  /// Send notification to specific user type
  Future<Map<String, dynamic>> sendToUserType({
    required String title,
    required String body,
    required String userType, // 'admin', 'user', 'moderator', etc.
    String notificationType = 'general',
    Map<String, dynamic>? data,
  }) async {
    return sendBulkNotification(
      title: title,
      body: body,
      notificationType: notificationType,
      targetType: 'user_type',
      targetValue: userType,
      data: data,
    );
  }

  /// إرسال إشعار لمستخدمين محددين
  /// Send notification to specific users
  Future<Map<String, dynamic>> sendToSpecificUsers({
    required String title,
    required String body,
    required List<String> userIds,
    String notificationType = 'general',
    Map<String, dynamic>? data,
  }) async {
    return sendBulkNotification(
      title: title,
      body: body,
      notificationType: notificationType,
      targetType: 'specific_users',
      targetValue: userIds,
      data: data,
    );
  }

  /// الحصول على الإحصائيات
  /// Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      _logger.logInfo('📊 جاري جلب الإحصائيات');

      final response = await _supabase.functions.invoke(
        'admin-notifications',
        queryParameters: {'action': 'get_stats'},
      );

      if (response.data['success'] == true) {
        _logger.logInfo('✅ تم جلب الإحصائيات بنجاح');
        return response.data;
      } else {
        throw Exception(response.data['error'] ?? 'فشل في جلب الإحصائيات');
      }
    } catch (e) {
      _logger.logError('❌ خطأ في جلب الإحصائيات: $e');
      rethrow;
    }
  }

  /// حذف إشعار
  /// Delete notification
  Future<Map<String, dynamic>> deleteNotification(String notificationId) async {
    try {
      _logger.logInfo('🗑️ جاري حذف الإشعار: $notificationId');

      final response = await _supabase.functions.invoke(
        'admin-notifications',
        method: HttpMethod.delete,
        queryParameters: {
          'action': 'delete_notification',
          'notification_id': notificationId,
        },
      );

      if (response.data['success'] == true) {
        _logger.logInfo('✅ تم حذف الإشعار بنجاح');
        return response.data;
      } else {
        throw Exception(response.data['error'] ?? 'فشل في حذف الإشعار');
      }
    } catch (e) {
      _logger.logError('❌ خطأ في حذف الإشعار: $e');
      rethrow;
    }
  }

  /// تحديد إشعار كمقروء
  /// Mark notification as read
  Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    try {
      _logger.logInfo('👁️ جاري تحديد الإشعار كمقروء: $notificationId');

      final response = await _supabase.functions.invoke(
        'admin-notifications',
        queryParameters: {'action': 'mark_read'},
        body: {'notification_id': notificationId},
      );

      if (response.data['success'] == true) {
        _logger.logInfo('✅ تم تحديد الإشعار كمقروء بنجاح');
        return response.data;
      } else {
        throw Exception(response.data['error'] ?? 'فشل في تحديث حالة الإشعار');
      }
    } catch (e) {
      _logger.logError('❌ خطأ في تحديث حالة الإشعار: $e');
      rethrow;
    }
  }

  /// إرسال إشعار نجاح تقديم البلاغ
  /// Send report submission success notification
  Future<Map<String, dynamic>> sendReportSubmissionNotification({
    required String userId,
    required String caseNumber,
    String? reportType,
    String? location,
  }) async {
    return createNotification(
      userId: userId,
      title: 'تم استلام بلاغكم بنجاح',
      body: 'تم تسجيل بلاغكم رقم #$caseNumber بنجاح وسيتم مراجعته قريباً.',
      notificationType: 'report_update',
      referenceId: caseNumber,
      referenceType: 'report',
      data: {
        'case_number': caseNumber,
        'report_type': reportType,
        'location': location,
        'action': 'report_submitted',
      },
    );
  }

  /// إرسال إشعار تحديث حالة البلاغ
  /// Send report status update notification
  Future<Map<String, dynamic>> sendReportStatusNotification({
    required String userId,
    required String caseNumber,
    required String status,
    String? investigatorName,
    String? notes,
  }) async {
    String title;
    String body;

    switch (status.toLowerCase()) {
      case 'under_investigation':
        title = 'تحديث حالة البلاغ #$caseNumber';
        body = 'بلاغكم قيد التحقيق النشط حالياً.';
        break;
      case 'resolved':
        title = 'تم حل البلاغ #$caseNumber';
        body = 'يسعدنا إعلامكم بأن بلاغكم تم حله بنجاح!';
        break;
      case 'rejected':
        title = 'البلاغ #$caseNumber غير مقبول';
        body = 'نأسف لإعلامكم بأن بلاغكم لم يتم قبوله.';
        break;
      case 'closed':
        title = 'تم إغلاق البلاغ #$caseNumber';
        body = 'تم إغلاق بلاغكم نهائياً.';
        break;
      default:
        title = 'تحديث حالة البلاغ #$caseNumber';
        body = 'تم تحديث حالة بلاغكم.';
    }

    return createNotification(
      userId: userId,
      title: title,
      body: body,
      notificationType: 'report_update',
      referenceId: caseNumber,
      referenceType: 'report',
      data: {
        'case_number': caseNumber,
        'status': status,
        'investigator_name': investigatorName,
        'notes': notes,
        'action': 'status_update',
      },
    );
  }

  /// إرسال إشعار إخباري
  /// Send news notification
  Future<Map<String, dynamic>> sendNewsNotification({
    required String title,
    required String body,
    String? newsId,
    String? category,
    String? imageUrl,
    String targetType = 'all',
    dynamic targetValue,
  }) async {
    return sendBulkNotification(
      title: title,
      body: body,
      notificationType: 'news',
      targetType: targetType,
      targetValue: targetValue,
      data: {
        'news_id': newsId,
        'category': category,
        'image_url': imageUrl,
        'action': 'view_news',
      },
    );
  }

  /// إرسال إشعار نظام
  /// Send system notification
  Future<Map<String, dynamic>> sendSystemNotification({
    required String title,
    required String body,
    String? updateVersion,
    String? maintenanceTime,
    String targetType = 'all',
    dynamic targetValue,
  }) async {
    return sendBulkNotification(
      title: title,
      body: body,
      notificationType: 'system',
      targetType: targetType,
      targetValue: targetValue,
      data: {
        'update_version': updateVersion,
        'maintenance_time': maintenanceTime,
        'action': 'system_update',
      },
    );
  }
}
