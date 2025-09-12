import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:netru_app/features/notifications/presentation/cubit/notifications_state.dart';
import '../widgets/notification_item.dart';
import '../widgets/notification_app_bar.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationCubit()
        ..loadNotifications(),
      child: const NotificationsView(),
    );
  }
}

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(kToolbarHeight),
        child: BlocBuilder<NotificationCubit,
            NotificationState>(
          builder: (context, state) {
            final unreadCount =
                state is NotificationLoaded
                    ? state.unreadCount
                    : 0;
            return NotificationAppBar(
              unreadCount: unreadCount,
              onMarkAllAsRead: () {
                context
                    .read<NotificationCubit>()
                    .markAllAsRead();
              },
            );
          },
        ),
      ),
      body: BlocBuilder<NotificationCubit,
          NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<
                              NotificationCubit>()
                          .loadNotifications();
                    },
                    child: const Text(
                        'إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64.sp,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'لا توجد إشعارات',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(
                  vertical: 8.h),
              itemCount:
                  state.notifications.length,
              itemBuilder: (context, index) {
                final notification =
                    state.notifications[index];
                return NotificationItem(
                  key: ValueKey(notification.id),
                  notification: notification,
                  index: index,
                  onDelete: () {
                    context
                        .read<NotificationCubit>()
                        .deleteNotification(
                            notification.id);
                  },
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
