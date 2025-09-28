import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/get_unread_notifications_count.dart';
import '../../domain/usecases/mark_notification_as_read.dart';
import '../../domain/usecases/send_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final GetUnreadNotificationsCountUseCase getUnreadCountUseCase;
  final MarkNotificationAsReadUseCase markAsReadUseCase;
  final SendNotificationUseCase sendNotificationUseCase;
  final NotificationRepository notificationRepository;

  List<NotificationEntity> _notifications = [];
  int _currentPage = 0;
  static const int _pageSize = 20;
  bool _hasReachedMax = false;
  StreamSubscription<List<NotificationEntity>>? _notificationSubscription;

  NotificationCubit({
    required this.getNotificationsUseCase,
    required this.getUnreadCountUseCase,
    required this.markAsReadUseCase,
    required this.sendNotificationUseCase,
    required this.notificationRepository,
  }) : super(NotificationInitial());

  Future<void> loadNotifications(String userId, {bool refresh = false}) async {
    if (refresh) {
      _notifications.clear();
      _currentPage = 0;
      _hasReachedMax = false;
    }

    if (state is NotificationLoading || _hasReachedMax) return;

    emit(NotificationLoading());

    try {
      // Get notifications
      final notificationsResult = await getNotificationsUseCase(
        GetNotificationsParams(
          userId: userId,
          limit: _pageSize,
          offset: _currentPage * _pageSize,
        ),
      );

      // Get unread count
      final unreadCountResult = await getUnreadCountUseCase(
        GetUnreadNotificationsCountParams(userId: userId),
      );

      await notificationsResult.fold(
        (failure) async => emit(NotificationError(_getFailureMessage(failure))),
        (notifications) async {
          await unreadCountResult.fold(
            (failure) async =>
                emit(NotificationError(_getFailureMessage(failure))),
            (unreadCount) async {
              _hasReachedMax = notifications.length < _pageSize;

              if (refresh) {
                _notifications = notifications;
              } else {
                // Merge incoming page with existing list and remove duplicates
                _notifications = _mergeNotifications(
                  _notifications,
                  notifications,
                );
              }

              _currentPage++;

              emit(
                NotificationLoaded(
                  notifications: List.from(_notifications),
                  unreadCount: unreadCount,
                  hasReachedMax: _hasReachedMax,
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      emit(NotificationError('حدث خطأ غير متوقع: $e'));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    if (state is! NotificationLoaded) return;

    final currentState = state as NotificationLoaded;

    // Optimistically update UI
    final updatedNotifications =
        _notifications.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(isRead: true, readAt: DateTime.now());
          }
          return notification;
        }).toList();

    final newUnreadCount = updatedNotifications.where((n) => !n.isRead).length;

    emit(
      currentState.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      ),
    );

    // Update backend
    final result = await markAsReadUseCase(
      MarkNotificationAsReadParams(notificationId: notificationId),
    );

    result.fold(
      (failure) {
        // Revert on failure
        emit(currentState);
        emit(NotificationError(_getFailureMessage(failure)));
      },
      (_) {
        // Update local list
        _notifications = updatedNotifications;
      },
    );
  }

  Future<void> markAllAsRead(String userId) async {
    if (state is! NotificationLoaded) return;

    final currentState = state as NotificationLoaded;

    // Optimistically update UI
    final updatedNotifications =
        _notifications.map((notification) {
          return notification.copyWith(isRead: true, readAt: DateTime.now());
        }).toList();

    emit(
      currentState.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      ),
    );

    // Update backend
    final result = await notificationRepository.markAllAsRead(userId);

    result.fold(
      (failure) {
        // Revert on failure
        emit(currentState);
        emit(NotificationError(_getFailureMessage(failure)));
      },
      (_) {
        // Update local list
        _notifications = updatedNotifications;
      },
    );
  }

  Future<void> deleteNotification(String notificationId) async {
    if (state is! NotificationLoaded) return;

    final currentState = state as NotificationLoaded;

    // Optimistically update UI
    final updatedNotifications =
        _notifications
            .where((notification) => notification.id != notificationId)
            .toList();

    final newUnreadCount = updatedNotifications.where((n) => !n.isRead).length;

    emit(
      currentState.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      ),
    );

    // Update backend
    final result = await notificationRepository.deleteNotification(
      notificationId,
    );

    result.fold(
      (failure) {
        // Revert on failure
        emit(currentState);
        emit(NotificationError(_getFailureMessage(failure)));
      },
      (_) {
        // Update local list
        _notifications = updatedNotifications;
      },
    );
  }

  Future<void> sendNotification(NotificationEntity notification) async {
    final result = await sendNotificationUseCase(
      SendNotificationParams(notification: notification),
    );

    result.fold(
      (failure) => emit(NotificationError(_getFailureMessage(failure))),
      (sentNotification) {
        // Insert sent notification at top if not already present
        if (!_notifications.any((n) => n.id == sentNotification.id)) {
          _notifications.insert(0, sentNotification);
        }

        if (state is NotificationLoaded) {
          final currentState = state as NotificationLoaded;
          final newUnread =
              currentState.unreadCount + (sentNotification.isRead ? 0 : 1);
          emit(
            currentState.copyWith(
              notifications: List.from(_notifications),
              unreadCount: newUnread,
            ),
          );
        }
      },
    );
  }

  void subscribeToNotifications(String userId) {
    _notificationSubscription?.cancel();
    _notificationSubscription = notificationRepository
        .subscribeToNotifications(userId)
        .listen(
          (notifications) {
            // Merge stream notifications with existing list and deduplicate
            _notifications = _mergeNotifications(_notifications, notifications);
            final unreadCount = _notifications.where((n) => !n.isRead).length;

            emit(
              NotificationLoaded(
                notifications: List.from(_notifications),
                unreadCount: unreadCount,
                hasReachedMax: _notifications.length < _pageSize,
              ),
            );
          },
          onError: (error) {
            emit(NotificationError('خطأ في الاتصال المباشر: $error'));
          },
        );
  }

  // Merge two notification lists while removing duplicates (by id)
  List<NotificationEntity> _mergeNotifications(
    List<NotificationEntity> current,
    List<NotificationEntity> incoming,
  ) {
    final map = <String, NotificationEntity>{};

    // Put current first then incoming so incoming replaces duplicates
    for (final n in current) {
      map[n.id] = n;
    }
    for (final n in incoming) {
      map[n.id] = n;
    }

    final merged = map.values.toList();
    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return merged;
  }

  String _getFailureMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'خطأ في الخادم';
    } else if (failure is CacheFailure) {
      return 'خطأ في التخزين المحلي';
    } else if (failure is NetworkFailure) {
      return 'خطأ في الاتصال بالإنترنت';
    } else {
      return 'حدث خطأ غير متوقع';
    }
  }

  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    return super.close();
  }
}
