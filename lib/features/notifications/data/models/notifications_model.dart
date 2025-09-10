class NotificationModel {
  final String id;
  final String title;
  final String subtitle;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'type': type.index,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromJson(
      Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      type: NotificationType.values[json['type']],
      createdAt:
          DateTime.parse(json['createdAt']),
      isRead: json['isRead'],
    );
  }
}

enum NotificationType {
  danger, // أحمر - خطر
  success, // أخضر - نجاح
  warning, // أصفر - تحذير
}
