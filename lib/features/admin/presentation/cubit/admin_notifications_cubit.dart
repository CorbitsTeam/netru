import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
// 'dartz' not required directly in this file; remove unused import

import '../../domain/entities/admin_notification_entity.dart';
import '../../domain/usecases/manage_notifications.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';

part 'admin_notifications_state.dart';

class AdminNotificationsCubit extends Cubit<AdminNotificationsState> {
  final SendBulkNotification _sendBulkNotification;
  final GetAllNotifications _getAllNotifications;
  final CreateNotification _createNotification;
  final GetNotificationStats _getNotificationStats;
  final GetGovernoratesList _getGovernoratesList;
  final GetUserNotifications _getUserNotifications;

  // Stream subscriptions for real-time updates
  StreamSubscription? _notificationsSubscription;
  StreamSubscription? _statisticsSubscription;

  AdminNotificationsCubit(
    this._sendBulkNotification,
    this._getAllNotifications,
    this._createNotification,
    this._getNotificationStats,
    this._getGovernoratesList,
    this._getUserNotifications,
  ) : super(const AdminNotificationsInitial());

  // Guarded emit to prevent emitting after the cubit has been closed
  void _safeEmit(AdminNotificationsState state) {
    if (!isClosed) emit(state);
  }

  /// Load all notifications with optional filters
  Future<void> loadNotifications({
    int page = 1,
    int limit = 20,
    NotificationFilters? filters,
    bool refresh = false,
  }) async {
    try {
      if (refresh || state is! AdminNotificationsLoaded) {
        _safeEmit(const AdminNotificationsLoading());
      }

      final result = await _getAllNotifications(
        GetNotificationsParams(
          page: page,
          limit: limit,
          type: filters?.type,
          priority: filters?.priority,
          isRead: filters?.isRead,
          isSent: filters?.isSent,
          startDate: filters?.startDate,
          endDate: filters?.endDate,
        ),
      );

      result.fold(
        (failure) => _safeEmit(
          AdminNotificationsError(message: _mapFailureToMessage(failure)),
        ),
        (notifications) async {
          // Separate notifications by status
          final scheduled =
              notifications
                  .where((n) => !n.isSent && n.sentAt == null)
                  .toList();
          final drafts =
              notifications
                  .where((n) => !n.isSent && n.fcmMessageId == null)
                  .toList();

          // Load governorates list
          final governoratesResult = await _getGovernoratesList(const NoParams());
          final governorates = governoratesResult.fold(
            (l) => <String>[],
            (r) => r,
          );

          // Load statistics
          final statsResult = await _getNotificationStats(const NoParams());
          final stats = statsResult.fold((l) => <String, int>{}, (r) => r);

          _safeEmit(
            AdminNotificationsLoaded(
              notifications: notifications,
              scheduledNotifications: scheduled,
              draftNotifications: drafts,
              statistics: stats,
              governorates: governorates,
              currentPage: page,
              hasMoreData: notifications.length == limit,
              filters: filters,
              lastUpdateTime: DateTime.now(),
            ),
          );
        },
      );
    } catch (e) {
      _safeEmit(AdminNotificationsError(message: 'حدث خطأ غير متوقع: $e'));
    }
  }

  /// Send bulk notification to multiple recipients
  Future<void> sendBulkNotification(BulkNotificationData data) async {
    try {
      _safeEmit(
        const AdminNotificationsSending(message: 'جاري إرسال الإشعارات...'),
      );

      final request = BulkNotificationRequest(
        title: data.title,
        titleAr: data.titleAr,
        body: data.body,
        bodyAr: data.bodyAr,
        targetType: data.targetType,
        targetValue: data.targetValue,
        notificationType: data.type,
        priority: data.priority,
        data: data.data,
      );

      final result = await _sendBulkNotification(
        SendBulkNotificationParams(request: request),
      );

      result.fold(
        (failure) => _safeEmit(
          AdminNotificationsError(message: _mapFailureToMessage(failure)),
        ),
        (success) {
          final recipientCount = _calculateRecipientCount(
            data.targetType,
            data.targetValue,
          );
          _safeEmit(
            AdminNotificationsSent(
              message: 'تم إرسال الإشعار بنجاح',
              recipientCount: recipientCount,
            ),
          );
          // Reload notifications to reflect changes
          loadNotifications(refresh: true);
        },
      );
    } catch (e) {
      _safeEmit(AdminNotificationsError(message: 'فشل في إرسال الإشعار: $e'));
    }
  }

  /// Create a single notification
  Future<void> createNotification({
    required String userId,
    required String title,
    String? titleAr,
    required String body,
    String? bodyAr,
    required NotificationType type,
    NotificationPriority priority = NotificationPriority.normal,
    String? referenceId,
    ReferenceType? referenceType,
    Map<String, dynamic>? data,
  }) async {
    try {
      _safeEmit(
        const AdminNotificationsSending(message: 'جاري إنشاء الإشعار...'),
      );

      final result = await _createNotification(
        CreateNotificationParams(
          userId: userId,
          title: title,
          titleAr: titleAr,
          body: body,
          bodyAr: bodyAr,
          type: type,
          priority: priority,
          referenceId: referenceId,
          referenceType: referenceType,
          data: data,
        ),
      );

      result.fold(
        (failure) => _safeEmit(
          AdminNotificationsError(message: _mapFailureToMessage(failure)),
        ),
        (notification) {
          _safeEmit(
            const AdminNotificationsSent(
              message: 'تم إنشاء الإشعار بنجاح',
              recipientCount: 1,
            ),
          );
          loadNotifications(refresh: true);
        },
      );
    } catch (e) {
      _safeEmit(AdminNotificationsError(message: 'فشل في إنشاء الإشعار: $e'));
    }
  }

  /// Load detailed statistics
  Future<void> loadStatistics() async {
    try {
      _safeEmit(const AdminNotificationsStatsLoading());

      final result = await _getNotificationStats(const NoParams());

      result.fold(
        (failure) => _safeEmit(
          AdminNotificationsError(message: _mapFailureToMessage(failure)),
        ),
        (stats) {
          // Convert raw stats to NotificationStats model with safe casts
          final byType = (stats['by_type'] as Map<dynamic, dynamic>?) ?? {};
          final byPriority =
              (stats['by_priority'] as Map<dynamic, dynamic>?) ?? {};
          final byGovernorate =
              (stats['by_governorate'] as Map<dynamic, dynamic>?) ?? {};
          final dailyRaw = (stats['daily_stats'] as List<dynamic>?) ?? [];
          final hourlyRaw = (stats['hourly_stats'] as List<dynamic>?) ?? [];

          final notificationStats = NotificationStats(
            totalNotifications: stats['total'] ?? 0,
            sentNotifications: stats['sent'] ?? 0,
            scheduledNotifications: stats['scheduled'] ?? 0,
            draftNotifications: stats['draft'] ?? 0,
            failedNotifications: stats['failed'] ?? 0,
            deliveryRate: (stats['delivery_rate'] ?? 0.0).toDouble(),
            openRate: (stats['open_rate'] ?? 0.0).toDouble(),
            clickRate: (stats['click_rate'] ?? 0.0).toDouble(),
            notificationsByType: Map<String, int>.from(
              Map<String, int>.fromEntries(
                byType.entries.map(
                  (e) => MapEntry(e.key.toString(), (e.value as num).toInt()),
                ),
              ),
            ),
            notificationsByPriority: Map<String, int>.from(
              Map<String, int>.fromEntries(
                byPriority.entries.map(
                  (e) => MapEntry(e.key.toString(), (e.value as num).toInt()),
                ),
              ),
            ),
            deliveryRateByGovernorate: Map<String, double>.from(
              Map<String, double>.fromEntries(
                byGovernorate.entries.map(
                  (e) =>
                      MapEntry(e.key.toString(), (e.value as num).toDouble()),
                ),
              ),
            ),
            dailyStats: _parseDailyStats(dailyRaw),
            hourlyStats: _parseHourlyStats(hourlyRaw),
            lastUpdated: DateTime.now(),
          );

          _safeEmit(AdminNotificationsStatsLoaded(stats: notificationStats));
        },
      );
    } catch (e) {
      _safeEmit(
        AdminNotificationsError(message: 'فشل في تحميل الإحصائيات: $e'),
      );
    }
  }

  /// Apply filters to notifications
  void applyFilters(NotificationFilters filters) {
    if (state is AdminNotificationsLoaded) {
      final currentState = state as AdminNotificationsLoaded;
      _safeEmit(currentState.copyWith(filters: filters));
      loadNotifications(filters: filters, refresh: true);
    }
  }

  /// Clear all filters
  void clearFilters() {
    if (state is AdminNotificationsLoaded) {
      final currentState = state as AdminNotificationsLoaded;
      _safeEmit(currentState.copyWith(filters: null));
      loadNotifications(refresh: true);
    }
  }

  /// Search notifications
  void searchNotifications(String query) {
    if (state is AdminNotificationsLoaded) {
      final currentState = state as AdminNotificationsLoaded;
      final newFilters =
          currentState.filters?.copyWith(searchQuery: query) ??
          NotificationFilters(searchQuery: query);

      applyFilters(newFilters);
    }
  }

  /// Toggle notification selection for bulk operations
  void toggleNotificationSelection(String notificationId) {
    if (state is AdminNotificationsLoaded) {
      final currentState = state as AdminNotificationsLoaded;
      final selectedIds = List<String>.from(
        currentState.selectedNotificationIds,
      );

      if (selectedIds.contains(notificationId)) {
        selectedIds.remove(notificationId);
      } else {
        selectedIds.add(notificationId);
      }

      _safeEmit(currentState.copyWith(selectedNotificationIds: selectedIds));
    }
  }

  /// Select all notifications
  void selectAllNotifications() {
    if (state is AdminNotificationsLoaded) {
      final currentState = state as AdminNotificationsLoaded;
      final allIds = currentState.notifications.map((n) => n.id).toList();
      _safeEmit(currentState.copyWith(selectedNotificationIds: allIds));
    }
  }

  /// Clear all selections
  void clearAllSelections() {
    if (state is AdminNotificationsLoaded) {
      final currentState = state as AdminNotificationsLoaded;
      _safeEmit(currentState.copyWith(selectedNotificationIds: []));
    }
  }

  /// Load user-specific notifications
  Future<void> loadUserNotifications({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _safeEmit(const AdminNotificationsLoading());

      final result = await _getUserNotifications(
        GetUserNotificationsParams(userId: userId, page: page, limit: limit),
      );

      result.fold(
        (failure) => _safeEmit(
          AdminNotificationsError(message: _mapFailureToMessage(failure)),
        ),
        (notifications) {
          _safeEmit(
            AdminNotificationsLoaded(
              notifications: notifications,
              scheduledNotifications: const [],
              draftNotifications: const [],
              statistics: const {},
              governorates: const [],
              currentPage: page,
              hasMoreData: notifications.length == limit,
              lastUpdateTime: DateTime.now(),
            ),
          );
        },
      );
    } catch (e) {
      _safeEmit(
        AdminNotificationsError(message: 'فشل في تحميل إشعارات المستخدم: $e'),
      );
    }
  }

  /// Load next page of notifications
  Future<void> loadNextPage() async {
    if (state is AdminNotificationsLoaded) {
      final currentState = state as AdminNotificationsLoaded;
      if (currentState.hasMoreData) {
        await loadNotifications(
          page: currentState.currentPage + 1,
          filters: currentState.filters,
        );
      }
    }
  }

  /// Refresh current data
  Future<void> refresh() async {
    if (state is AdminNotificationsLoaded) {
      final currentState = state as AdminNotificationsLoaded;
      await loadNotifications(filters: currentState.filters, refresh: true);
    } else {
      await loadNotifications(refresh: true);
    }
  }

  /// Helper methods
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'خطأ في الخادم. يرجى المحاولة مرة أخرى.';
    } else if (failure is NetworkFailure) {
      return 'لا يوجد اتصال بالإنترنت.';
    } else if (failure is InvalidInputFailure) {
      return 'بيانات غير صحيحة.';
    }

    return 'حدث خطأ غير متوقع.';
  }

  int _calculateRecipientCount(TargetType targetType, dynamic targetValue) {
    if (targetType == TargetType.all) return 10000;
    if (targetType == TargetType.governorate) return 1500;
    if (targetType == TargetType.userType) return 500;
    if (targetType == TargetType.specificUsers) {
      if (targetValue is List) return targetValue.length;
      return 1;
    }

    return 0;
  }

  List<DailyNotificationStat> _parseDailyStats(List<dynamic> rawStats) {
    return rawStats
        .map(
          (stat) => DailyNotificationStat(
            date: DateTime.parse(stat['date']),
            sent: stat['sent'] ?? 0,
            delivered: stat['delivered'] ?? 0,
            opened: stat['opened'] ?? 0,
            clicked: stat['clicked'] ?? 0,
            failed: stat['failed'] ?? 0,
          ),
        )
        .toList();
  }

  List<HourlyNotificationStat> _parseHourlyStats(List<dynamic> rawStats) {
    return rawStats
        .map(
          (stat) => HourlyNotificationStat(
            hour: stat['hour'] ?? 0,
            sent: stat['sent'] ?? 0,
            delivered: stat['delivered'] ?? 0,
            deliveryRate: (stat['delivery_rate'] ?? 0.0).toDouble(),
          ),
        )
        .toList();
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    _statisticsSubscription?.cancel();
    return super.close();
  }
}
