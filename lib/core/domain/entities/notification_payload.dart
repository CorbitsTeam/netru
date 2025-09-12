import 'package:equatable/equatable.dart';

enum NotificationType {
  info,
  warning,
  error,
  success,
  reminder,
  update,
  message,
}

enum NotificationPriority { low, medium, high, urgent }

class NotificationPayload extends Equatable {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final Map<String, dynamic>? data;
  final String? imageUrl;
  final String? actionUrl;
  final DateTime receivedAt;
  final bool isRead;

  const NotificationPayload({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.priority,
    this.data,
    this.imageUrl,
    this.actionUrl,
    required this.receivedAt,
    this.isRead = false,
  });

  NotificationPayload copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? actionUrl,
    DateTime? receivedAt,
    bool? isRead,
  }) {
    return NotificationPayload(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      data: data ?? this.data,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      receivedAt: receivedAt ?? this.receivedAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    type,
    priority,
    data,
    imageUrl,
    actionUrl,
    receivedAt,
    isRead,
  ];
}
