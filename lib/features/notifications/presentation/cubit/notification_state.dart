import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final bool hasReachedMax;

  const NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
    this.hasReachedMax = false,
  });

  NotificationLoaded copyWith({
    List<NotificationEntity>? notifications,
    int? unreadCount,
    bool? hasReachedMax,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [notifications, unreadCount, hasReachedMax];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object> get props => [message];
}

class NotificationMarkingAsRead extends NotificationState {
  final String notificationId;

  const NotificationMarkingAsRead(this.notificationId);

  @override
  List<Object> get props => [notificationId];
}

class NotificationDeleting extends NotificationState {
  final String notificationId;

  const NotificationDeleting(this.notificationId);

  @override
  List<Object> get props => [notificationId];
}
