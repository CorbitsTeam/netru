import 'package:equatable/equatable.dart';

class AdminNotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String? userName;
  final String title;
  final String? titleAr;
  final String body;
  final String? bodyAr;
  final NotificationType notificationType;
  final String? referenceId;
  final ReferenceType? referenceType;
  final Map<String, dynamic>? data;
  final bool isRead;
  final bool isSent;
  final NotificationPriority priority;
  final String? fcmMessageId;
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? sentAt;

  const AdminNotificationEntity({
    required this.id,
    required this.userId,
    this.userName,
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

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
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

  AdminNotificationEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    String? title,
    String? titleAr,
    String? body,
    String? bodyAr,
    NotificationType? notificationType,
    String? referenceId,
    ReferenceType? referenceType,
    Map<String, dynamic>? data,
    bool? isRead,
    bool? isSent,
    NotificationPriority? priority,
    String? fcmMessageId,
    DateTime? createdAt,
    DateTime? readAt,
    DateTime? sentAt,
  }) {
    return AdminNotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
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
}

class BulkNotificationRequest extends Equatable {
  final String title;
  final String? titleAr;
  final String body;
  final String? bodyAr;
  final TargetType targetType;
  final dynamic targetValue;
  final NotificationType notificationType;
  final NotificationPriority priority;
  final Map<String, dynamic>? data;

  const BulkNotificationRequest({
    required this.title,
    this.titleAr,
    required this.body,
    this.bodyAr,
    required this.targetType,
    required this.targetValue,
    required this.notificationType,
    required this.priority,
    this.data,
  });

  @override
  List<Object?> get props => [
    title,
    titleAr,
    body,
    bodyAr,
    targetType,
    targetValue,
    notificationType,
    priority,
    data,
  ];
}

enum NotificationType { news, reportUpdate, reportComment, system, general }

enum ReferenceType { newsArticle, report, system }

enum NotificationPriority { low, normal, high, urgent }

enum TargetType { all, governorate, userType, specificUsers }

extension NotificationTypeExtension on NotificationType {
  String get value {
    switch (this) {
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

  String get arabicName {
    switch (this) {
      case NotificationType.news:
        return 'أخبار';
      case NotificationType.reportUpdate:
        return 'تحديث تقرير';
      case NotificationType.reportComment:
        return 'تعليق تقرير';
      case NotificationType.system:
        return 'نظام';
      case NotificationType.general:
        return 'عام';
    }
  }

  static NotificationType fromString(String value) {
    switch (value) {
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
}

extension NotificationPriorityExtension on NotificationPriority {
  String get value {
    switch (this) {
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

  String get arabicName {
    switch (this) {
      case NotificationPriority.low:
        return 'منخفض';
      case NotificationPriority.normal:
        return 'عادي';
      case NotificationPriority.high:
        return 'عالي';
      case NotificationPriority.urgent:
        return 'عاجل';
    }
  }

  static NotificationPriority fromString(String value) {
    switch (value) {
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
}

extension TargetTypeExtension on TargetType {
  String get value {
    switch (this) {
      case TargetType.all:
        return 'all';
      case TargetType.governorate:
        return 'governorate';
      case TargetType.userType:
        return 'user_type';
      case TargetType.specificUsers:
        return 'specific_users';
    }
  }

  String get arabicName {
    switch (this) {
      case TargetType.all:
        return 'الكل';
      case TargetType.governorate:
        return 'محافظة';
      case TargetType.userType:
        return 'نوع المستخدم';
      case TargetType.specificUsers:
        return 'مستخدمين محددين';
    }
  }
}
