import 'package:equatable/equatable.dart';

enum NotificationType { news, reportUpdate, reportComment, system, general }

enum NotificationPriority { low, normal, high, urgent }

enum ReferenceType { newsArticle, report, system }

class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? titleAr;
  final String body;
  final String? bodyAr;
  final NotificationType type;
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

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.titleAr,
    required this.body,
    this.bodyAr,
    required this.type,
    this.referenceId,
    this.referenceType,
    this.data,
    this.isRead = false,
    this.isSent = false,
    this.priority = NotificationPriority.normal,
    this.fcmMessageId,
    required this.createdAt,
    this.readAt,
    this.sentAt,
  });

  NotificationEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? titleAr,
    String? body,
    String? bodyAr,
    NotificationType? type,
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
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      titleAr: titleAr ?? this.titleAr,
      body: body ?? this.body,
      bodyAr: bodyAr ?? this.bodyAr,
      type: type ?? this.type,
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

  /// Get localized title based on current locale
  String getLocalizedTitle([bool isArabic = true]) {
    if (isArabic && titleAr != null && titleAr!.isNotEmpty) {
      return titleAr!;
    }
    return title;
  }

  /// Get localized body based on current locale
  String getLocalizedBody([bool isArabic = true]) {
    if (isArabic && bodyAr != null && bodyAr!.isNotEmpty) {
      return bodyAr!;
    }
    return body;
  }

  /// Check if notification is recent (within last 24 hours)
  bool get isRecent {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    return diff.inHours < 24;
  }

  /// Get relative time string
  String get relativeTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays > 0) {
      return '${diff.inDays} يوم${diff.inDays > 1 ? '' : ''}';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} ساعة${diff.inHours > 1 ? '' : ''}';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} دقيقة${diff.inMinutes > 1 ? '' : ''}';
    } else {
      return 'الآن';
    }
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    titleAr,
    body,
    bodyAr,
    type,
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
