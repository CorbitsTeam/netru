import '../../domain/entities/admin_notification_entity.dart';

class AdminNotificationModel extends AdminNotificationEntity {
  const AdminNotificationModel({
    required super.id,
    required super.userId,
    super.userName,
    required super.title,
    super.titleAr,
    required super.body,
    super.bodyAr,
    required super.notificationType,
    super.referenceId,
    super.referenceType,
    super.data,
    required super.isRead,
    required super.isSent,
    required super.priority,
    super.fcmMessageId,
    required super.createdAt,
    super.readAt,
    super.sentAt,
  });

  factory AdminNotificationModel.fromJson(Map<String, dynamic> json) {
    return AdminNotificationModel(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'],
      title: json['title'],
      titleAr: json['title_ar'],
      body: json['body'],
      bodyAr: json['body_ar'],
      notificationType: NotificationTypeExtension.fromString(
        json['notification_type'],
      ),
      referenceId: json['reference_id'],
      referenceType: _parseReferenceType(json['reference_type']),
      data: json['data'],
      isRead: json['is_read'] ?? false,
      isSent: json['is_sent'] ?? false,
      priority: NotificationPriorityExtension.fromString(json['priority']),
      fcmMessageId: json['fcm_message_id'],
      createdAt: DateTime.parse(json['created_at']),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'title': title,
      'title_ar': titleAr,
      'body': body,
      'body_ar': bodyAr,
      'notification_type': notificationType.value,
      'reference_id': referenceId,
      'reference_type': referenceType?.toString().split('.').last,
      'data': data,
      'is_read': isRead,
      'is_sent': isSent,
      'priority': priority.value,
      'fcm_message_id': fcmMessageId,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'sent_at': sentAt?.toIso8601String(),
    };
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
}

class BulkNotificationRequestModel extends BulkNotificationRequest {
  const BulkNotificationRequestModel({
    required super.title,
    super.titleAr,
    required super.body,
    super.bodyAr,
    required super.targetType,
    required super.targetValue,
    required super.notificationType,
    required super.priority,
    super.data,
  });

  factory BulkNotificationRequestModel.fromJson(Map<String, dynamic> json) {
    return BulkNotificationRequestModel(
      title: json['title'],
      titleAr: json['title_ar'],
      body: json['body'],
      bodyAr: json['body_ar'],
      targetType: _parseTargetType(json['target_type']),
      targetValue: json['target_value'],
      notificationType: NotificationTypeExtension.fromString(
        json['notification_type'],
      ),
      priority: NotificationPriorityExtension.fromString(json['priority']),
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'title_ar': titleAr,
      'body': body,
      'body_ar': bodyAr,
      'target_type': targetType.value,
      'target_value': targetValue,
      'notification_type': notificationType.value,
      'priority': priority.value,
      'data': data,
    };
  }

  static TargetType _parseTargetType(String type) {
    switch (type) {
      case 'governorate':
        return TargetType.governorate;
      case 'user_type':
        return TargetType.userType;
      case 'specific_users':
        return TargetType.specificUsers;
      default:
        return TargetType.all;
    }
  }
}
