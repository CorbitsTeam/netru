import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.title,
    super.titleAr,
    required super.body,
    super.bodyAr,
    required super.type,
    super.referenceId,
    super.referenceType,
    super.data,
    super.isRead,
    super.isSent,
    super.priority,
    super.fcmMessageId,
    required super.createdAt,
    super.readAt,
    super.sentAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      title: json['title'] ?? '',
      titleAr: json['title_ar'],
      body: json['body'] ?? '',
      bodyAr: json['body_ar'],
      type: _parseNotificationType(json['notification_type']),
      referenceId: json['reference_id'],
      referenceType: _parseReferenceType(json['reference_type']),
      data:
          json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
      isRead: json['is_read'] ?? false,
      isSent: json['is_sent'] ?? false,
      priority: _parseNotificationPriority(json['priority']),
      fcmMessageId: json['fcm_message_id'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'title_ar': titleAr,
      'body': body,
      'body_ar': bodyAr,
      'notification_type': _notificationTypeToString(type),
      'reference_id': referenceId,
      'reference_type':
          referenceType != null ? _referenceTypeToString(referenceType!) : null,
      'data': data,
      'is_read': isRead,
      'is_sent': isSent,
      'priority': _notificationPriorityToString(priority),
      'fcm_message_id': fcmMessageId,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'sent_at': sentAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'title': title,
      'title_ar': titleAr,
      'body': body,
      'body_ar': bodyAr,
      'notification_type': _notificationTypeToString(type),
      'reference_id': referenceId,
      'reference_type':
          referenceType != null ? _referenceTypeToString(referenceType!) : null,
      'data': data,
      'priority': _notificationPriorityToString(priority),
    };
  }

  static NotificationType _parseNotificationType(String? type) {
    switch (type) {
      case 'news':
        return NotificationType.news;
      case 'report_update':
        return NotificationType.reportUpdate;
      case 'report_comment':
        return NotificationType.reportComment;
      case 'system':
        return NotificationType.system;
      case 'general':
        return NotificationType.general;
      default:
        return NotificationType.general;
    }
  }

  static String _notificationTypeToString(NotificationType type) {
    switch (type) {
      case NotificationType.news:
        return 'news';
      case NotificationType.reportUpdate:
        return 'report_update';
      case NotificationType.reportComment:
        return 'report_comment';
      case NotificationType.system:
        return 'system';
      case NotificationType.general:
        return 'general';
    }
  }

  static ReferenceType? _parseReferenceType(String? type) {
    switch (type) {
      case 'news_article':
        return ReferenceType.newsArticle;
      case 'report':
        return ReferenceType.report;
      case 'system':
        return ReferenceType.system;
      default:
        return null;
    }
  }

  static String _referenceTypeToString(ReferenceType type) {
    switch (type) {
      case ReferenceType.newsArticle:
        return 'news_article';
      case ReferenceType.report:
        return 'report';
      case ReferenceType.system:
        return 'system';
    }
  }

  static NotificationPriority _parseNotificationPriority(String? priority) {
    switch (priority) {
      case 'low':
        return NotificationPriority.low;
      case 'normal':
        return NotificationPriority.normal;
      case 'high':
        return NotificationPriority.high;
      case 'urgent':
        return NotificationPriority.urgent;
      default:
        return NotificationPriority.normal;
    }
  }

  static String _notificationPriorityToString(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return 'low';
      case NotificationPriority.normal:
        return 'normal';
      case NotificationPriority.high:
        return 'high';
      case NotificationPriority.urgent:
        return 'urgent';
    }
  }

  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      titleAr: entity.titleAr,
      body: entity.body,
      bodyAr: entity.bodyAr,
      type: entity.type,
      referenceId: entity.referenceId,
      referenceType: entity.referenceType,
      data: entity.data,
      isRead: entity.isRead,
      isSent: entity.isSent,
      priority: entity.priority,
      fcmMessageId: entity.fcmMessageId,
      createdAt: entity.createdAt,
      readAt: entity.readAt,
      sentAt: entity.sentAt,
    );
  }

  // Factory constructors for different notification types
  factory NotificationModel.newsNotification({
    required String userId,
    required String newsId,
    required String title,
    String? titleAr,
    required String body,
    String? bodyAr,
    Map<String, dynamic>? additionalData,
  }) {
    return NotificationModel(
      id: '', // Will be generated by database
      userId: userId,
      title: title,
      titleAr: titleAr,
      body: body,
      bodyAr: bodyAr,
      type: NotificationType.news,
      referenceId: newsId,
      referenceType: ReferenceType.newsArticle,
      data: {'action': 'open_news', 'news_id': newsId, ...?additionalData},
      priority: NotificationPriority.normal,
      createdAt: DateTime.now(),
    );
  }

  factory NotificationModel.reportUpdateNotification({
    required String userId,
    required String reportId,
    required String title,
    String? titleAr,
    required String body,
    String? bodyAr,
    String? newStatus,
    Map<String, dynamic>? additionalData,
  }) {
    return NotificationModel(
      id: '', // Will be generated by database
      userId: userId,
      title: title,
      titleAr: titleAr,
      body: body,
      bodyAr: bodyAr,
      type: NotificationType.reportUpdate,
      referenceId: reportId,
      referenceType: ReferenceType.report,
      data: {
        'action': 'open_report',
        'report_id': reportId,
        'new_status': newStatus,
        ...?additionalData,
      },
      priority: NotificationPriority.high,
      createdAt: DateTime.now(),
    );
  }

  factory NotificationModel.reportCommentNotification({
    required String userId,
    required String reportId,
    required String title,
    String? titleAr,
    required String body,
    String? bodyAr,
    String? commentId,
    Map<String, dynamic>? additionalData,
  }) {
    return NotificationModel(
      id: '', // Will be generated by database
      userId: userId,
      title: title,
      titleAr: titleAr,
      body: body,
      bodyAr: bodyAr,
      type: NotificationType.reportComment,
      referenceId: reportId,
      referenceType: ReferenceType.report,
      data: {
        'action': 'open_report',
        'report_id': reportId,
        'comment_id': commentId,
        ...?additionalData,
      },
      priority: NotificationPriority.high,
      createdAt: DateTime.now(),
    );
  }
}
