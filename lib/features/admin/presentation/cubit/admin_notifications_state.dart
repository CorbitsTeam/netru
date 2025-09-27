part of 'admin_notifications_cubit.dart';

abstract class AdminNotificationsState {
  const AdminNotificationsState();
}

class AdminNotificationsInitial extends AdminNotificationsState {
  const AdminNotificationsInitial();
}

class AdminNotificationsLoading extends AdminNotificationsState {
  const AdminNotificationsLoading();
}

class AdminNotificationsLoaded extends AdminNotificationsState {
  final List<AdminNotificationEntity> notifications;
  final List<AdminNotificationEntity> scheduledNotifications;
  final List<AdminNotificationEntity> draftNotifications;
  final Map<String, int> statistics;
  final List<String> governorates;
  final int currentPage;
  final bool hasMoreData;
  final NotificationFilters? filters;
  final List<String> selectedNotificationIds;
  final DateTime? lastUpdateTime;

  const AdminNotificationsLoaded({
    required this.notifications,
    required this.scheduledNotifications,
    required this.draftNotifications,
    required this.statistics,
    required this.governorates,
    this.currentPage = 1,
    this.hasMoreData = false,
    this.filters,
    this.selectedNotificationIds = const [],
    this.lastUpdateTime,
  });

  AdminNotificationsLoaded copyWith({
    List<AdminNotificationEntity>? notifications,
    List<AdminNotificationEntity>? scheduledNotifications,
    List<AdminNotificationEntity>? draftNotifications,
    Map<String, int>? statistics,
    List<String>? governorates,
    int? currentPage,
    bool? hasMoreData,
    NotificationFilters? filters,
    List<String>? selectedNotificationIds,
    DateTime? lastUpdateTime,
  }) {
    return AdminNotificationsLoaded(
      notifications: notifications ?? this.notifications,
      scheduledNotifications:
          scheduledNotifications ?? this.scheduledNotifications,
      draftNotifications: draftNotifications ?? this.draftNotifications,
      statistics: statistics ?? this.statistics,
      governorates: governorates ?? this.governorates,
      currentPage: currentPage ?? this.currentPage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      filters: filters ?? this.filters,
      selectedNotificationIds:
          selectedNotificationIds ?? this.selectedNotificationIds,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
    );
  }
}

class AdminNotificationsSending extends AdminNotificationsState {
  final String message;

  const AdminNotificationsSending({required this.message});
}

class AdminNotificationsSent extends AdminNotificationsState {
  final String message;
  final int recipientCount;

  const AdminNotificationsSent({
    required this.message,
    required this.recipientCount,
  });
}

class AdminNotificationsError extends AdminNotificationsState {
  final String message;

  const AdminNotificationsError({required this.message});
}

class AdminNotificationsStatsLoading extends AdminNotificationsState {
  const AdminNotificationsStatsLoading();
}

class AdminNotificationsStatsLoaded extends AdminNotificationsState {
  final NotificationStats stats;

  const AdminNotificationsStatsLoaded({required this.stats});
}

// Enhanced notification statistics model
class NotificationStats {
  final int totalNotifications;
  final int sentNotifications;
  final int scheduledNotifications;
  final int draftNotifications;
  final int failedNotifications;
  final double deliveryRate;
  final double openRate;
  final double clickRate;
  final Map<String, int> notificationsByType;
  final Map<String, int> notificationsByPriority;
  final Map<String, double> deliveryRateByGovernorate;
  final List<DailyNotificationStat> dailyStats;
  final List<HourlyNotificationStat> hourlyStats;
  final DateTime? lastUpdated;

  const NotificationStats({
    required this.totalNotifications,
    required this.sentNotifications,
    required this.scheduledNotifications,
    required this.draftNotifications,
    required this.failedNotifications,
    required this.deliveryRate,
    required this.openRate,
    required this.clickRate,
    required this.notificationsByType,
    required this.notificationsByPriority,
    required this.deliveryRateByGovernorate,
    required this.dailyStats,
    required this.hourlyStats,
    this.lastUpdated,
  });
}

class DailyNotificationStat {
  final DateTime date;
  final int sent;
  final int delivered;
  final int opened;
  final int clicked;
  final int failed;

  const DailyNotificationStat({
    required this.date,
    required this.sent,
    required this.delivered,
    required this.opened,
    required this.clicked,
    required this.failed,
  });
}

class HourlyNotificationStat {
  final int hour;
  final int sent;
  final int delivered;
  final double deliveryRate;

  const HourlyNotificationStat({
    required this.hour,
    required this.sent,
    required this.delivered,
    required this.deliveryRate,
  });
}

// Notification filters
class NotificationFilters {
  final NotificationType? type;
  final NotificationPriority? priority;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;
  final String? governorate;
  final List<String>? userIds;
  final bool? isRead;
  final bool? isSent;

  const NotificationFilters({
    this.type,
    this.priority,
    this.status,
    this.startDate,
    this.endDate,
    this.searchQuery,
    this.governorate,
    this.userIds,
    this.isRead,
    this.isSent,
  });

  NotificationFilters copyWith({
    NotificationType? type,
    NotificationPriority? priority,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    String? governorate,
    List<String>? userIds,
    bool? isRead,
    bool? isSent,
  }) {
    return NotificationFilters(
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      searchQuery: searchQuery ?? this.searchQuery,
      governorate: governorate ?? this.governorate,
      userIds: userIds ?? this.userIds,
      isRead: isRead ?? this.isRead,
      isSent: isSent ?? this.isSent,
    );
  }
}

// Bulk notification request
class BulkNotificationData {
  final String title;
  final String? titleAr;
  final String body;
  final String? bodyAr;
  final NotificationType type;
  final NotificationPriority priority;
  final TargetType targetType;
  final dynamic targetValue;
  final Map<String, dynamic>? data;
  final DateTime? scheduledAt;
  final bool sendImmediately;

  const BulkNotificationData({
    required this.title,
    this.titleAr,
    required this.body,
    this.bodyAr,
    required this.type,
    required this.priority,
    required this.targetType,
    required this.targetValue,
    this.data,
    this.scheduledAt,
    this.sendImmediately = false,
  });
}
