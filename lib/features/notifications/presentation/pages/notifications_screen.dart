import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/helpers/database_setup_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';
import '../widgets/notification_tile.dart';
import '../widgets/notification_shimmer.dart';
import '../widgets/empty_notifications.dart';
import '../widgets/notification_app_bar.dart';

class NotificationsScreen extends StatelessWidget {
  final String userId;

  const NotificationsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              sl<NotificationCubit>()
                ..loadNotifications(userId)
                ..subscribeToNotifications(userId),
      child: NotificationsView(userId: userId),
    );
  }
}

class NotificationsView extends StatefulWidget {
  final String userId;

  const NotificationsView({super.key, required this.userId});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _setupDatabaseIfNeeded();
  }

  Future<void> _setupDatabaseIfNeeded() async {
    // Setup database functions and test data if needed
    try {
      await DatabaseSetupHelper.completeSetup(widget.userId);
    } catch (e) {
      debugPrint('Database setup error: $e');
      // Continue normally even if setup fails
    }
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<NotificationCubit>().loadNotifications(widget.userId);
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            final unreadCount =
                state is NotificationLoaded ? state.unreadCount : 0;
            return NotificationAppBar(
              unreadCount: unreadCount,
              onMarkAllAsRead: () {
                context.read<NotificationCubit>().markAllAsRead(widget.userId);
              },
            );
          },
        ),
      ),
      body: BlocConsumer<NotificationCubit, NotificationState>(
        listener: (context, state) {
          if (state is NotificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NotificationLoading && state is! NotificationLoaded) {
            return const NotificationShimmer();
          }

          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return const EmptyNotifications();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationCubit>().loadNotifications(
                  widget.userId,
                  refresh: true,
                );
              },
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount:
                    state.notifications.length + (state.hasReachedMax ? 0 : 1),
                itemBuilder: (context, index) {
                  if (index >= state.notifications.length) {
                    return Container(
                      padding: EdgeInsets.all(16.r),
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    );
                  }

                  final notification = state.notifications[index];
                  return NotificationTile(
                    notification: notification,
                    onTap: () => _handleNotificationTap(context, notification),
                    onMarkAsRead:
                        !notification.isRead
                            ? () => context
                                .read<NotificationCubit>()
                                .markAsRead(notification.id)
                            : null,
                    onDelete: () => _showDeleteDialog(context, notification.id),
                  );
                },
              ),
            );
          }

          if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    state.message,
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NotificationCubit>().loadNotifications(
                        widget.userId,
                        refresh: true,
                      );
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, notification) {
    // Mark as read if not already read
    if (!notification.isRead) {
      context.read<NotificationCubit>().markAsRead(notification.id);
    }

    // Handle navigation based on notification type and data
    if (notification.data != null) {
      final action = notification.data!['action'] as String?;

      switch (action) {
        case 'open_news':
          final newsId = notification.data!['news_id'] as String?;
          if (newsId != null) {
            // Navigate to news details
            // Navigator.pushNamed(context, AppRoutes.newsDetails, arguments: newsId);
          }
          break;
        case 'open_report':
          final reportId = notification.data!['report_id'] as String?;
          if (reportId != null) {
            // Navigate to report details
            // Navigator.pushNamed(context, AppRoutes.reportDetails, arguments: reportId);
          }
          break;
      }
    }
  }

  void _showDeleteDialog(BuildContext context, String notificationId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('حذف الإشعار'),
            content: const Text('هل تريد حذف هذا الإشعار؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<NotificationCubit>().deleteNotification(
                    notificationId,
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('حذف'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
