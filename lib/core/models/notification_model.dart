import 'package:equatable/equatable.dart';

/// نموذج الإشعارات الموحد للتطبيق
class NotificationModel extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? titleAr;
  final String body;
  final String? bodyAr;
  final String notificationType;
  final String? referenceId;
  final String? referenceType;
  final Map<String, dynamic>? data;
  final bool isRead;
  final bool isSent;
  final String priority;
  final String? fcmMessageId;
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? sentAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    this.titleAr,
    required this.body,
    this.bodyAr,
    required this.notificationType,
    this.referenceId,
    this.referenceType,
    this.data,
    required this.isRead,
    required this.isSent,
    required this.priority,
    this.fcmMessageId,
    required this.createdAt,
    this.readAt,
    this.sentAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      titleAr: json['title_ar'] as String?,
      body: json['body'] as String,
      bodyAr: json['body_ar'] as String?,
      notificationType: json['notification_type'] as String,
      referenceId: json['reference_id'] as String?,
      referenceType: json['reference_type'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['is_read'] as bool? ?? false,
      isSent: json['is_sent'] as bool? ?? false,
      priority: json['priority'] as String? ?? 'normal',
      fcmMessageId: json['fcm_message_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt:
          json['read_at'] != null
              ? DateTime.parse(json['read_at'] as String)
              : null,
      sentAt:
          json['sent_at'] != null
              ? DateTime.parse(json['sent_at'] as String)
              : null,
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
      'notification_type': notificationType,
      'reference_id': referenceId,
      'reference_type': referenceType,
      'data': data,
      'is_read': isRead,
      'is_sent': isSent,
      'priority': priority,
      'fcm_message_id': fcmMessageId,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'sent_at': sentAt?.toIso8601String(),
    };
  }

  /// نسخة محدثة من النموذج
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? titleAr,
    String? body,
    String? bodyAr,
    String? notificationType,
    String? referenceId,
    String? referenceType,
    Map<String, dynamic>? data,
    bool? isRead,
    bool? isSent,
    String? priority,
    String? fcmMessageId,
    DateTime? createdAt,
    DateTime? readAt,
    DateTime? sentAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      titleAr: titleAr ?? this.titleAr,
      body: body ?? this.body,
      bodyAr: bodyAr ?? this.bodyAr,
      notificationType: notificationType ?? this.notificationType,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      isSent: isSent ?? this.isSent,
      priority: priority ?? this.priority,
      fcmMessageId: fcmMessageId ?? this.fcmMessageId,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      sentAt: sentAt ?? this.sentAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    titleAr,
    body,
    bodyAr,
    notificationType,
    referenceId,
    referenceType,
    data,
    isRead,
    isSent,
    priority,
    fcmMessageId,
    createdAt,
    readAt,
    sentAt,
  ];
}

/// نموذج رموز FCM المميزة
class UserFcmTokenModel extends Equatable {
  final String id;
  final String userId;
  final String fcmToken;
  final String? deviceType;
  final String? deviceId;
  final String? appVersion;
  final bool isActive;
  final DateTime? lastUsed;
  final DateTime createdAt;

  const UserFcmTokenModel({
    required this.id,
    required this.userId,
    required this.fcmToken,
    this.deviceType,
    this.deviceId,
    this.appVersion,
    required this.isActive,
    this.lastUsed,
    required this.createdAt,
  });

  factory UserFcmTokenModel.fromJson(Map<String, dynamic> json) {
    return UserFcmTokenModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fcmToken: json['fcm_token'] as String,
      deviceType: json['device_type'] as String?,
      deviceId: json['device_id'] as String?,
      appVersion: json['app_version'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      lastUsed:
          json['last_used'] != null
              ? DateTime.parse(json['last_used'] as String)
              : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'fcm_token': fcmToken,
      'device_type': deviceType,
      'device_id': deviceId,
      'app_version': appVersion,
      'is_active': isActive,
      'last_used': lastUsed?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    fcmToken,
    deviceType,
    deviceId,
    appVersion,
    isActive,
    lastUsed,
    createdAt,
  ];
}

/// أنواع الإشعارات المدعومة
enum NotificationTypeEnum {
  news,
  reportUpdate,
  reportComment,
  system,
  general;

  static NotificationTypeEnum fromString(String value) {
    switch (value) {
      case 'news':
        return NotificationTypeEnum.news;
      case 'report_update':
        return NotificationTypeEnum.reportUpdate;
      case 'report_comment':
        return NotificationTypeEnum.reportComment;
      case 'system':
        return NotificationTypeEnum.system;
      case 'general':
        return NotificationTypeEnum.general;
      default:
        return NotificationTypeEnum.general;
    }
  }

  String get value {
    switch (this) {
      case NotificationTypeEnum.news:
        return 'news';
      case NotificationTypeEnum.reportUpdate:
        return 'report_update';
      case NotificationTypeEnum.reportComment:
        return 'report_comment';
      case NotificationTypeEnum.system:
        return 'system';
      case NotificationTypeEnum.general:
        return 'general';
    }
  }
}

/// أولويات الإشعارات
enum NotificationPriorityEnum {
  low,
  normal,
  high,
  urgent;

  static NotificationPriorityEnum fromString(String value) {
    switch (value) {
      case 'low':
        return NotificationPriorityEnum.low;
      case 'normal':
        return NotificationPriorityEnum.normal;
      case 'high':
        return NotificationPriorityEnum.high;
      case 'urgent':
        return NotificationPriorityEnum.urgent;
      default:
        return NotificationPriorityEnum.normal;
    }
  }

  String get value {
    switch (this) {
      case NotificationPriorityEnum.low:
        return 'low';
      case NotificationPriorityEnum.normal:
        return 'normal';
      case NotificationPriorityEnum.high:
        return 'high';
      case NotificationPriorityEnum.urgent:
        return 'urgent';
    }
  }
}
