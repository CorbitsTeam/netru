import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/constants/app_constants.dart';
import 'package:netru_app/core/routing/routes.dart';
import 'package:netru_app/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:netru_app/features/notifications/presentation/cubit/notifications_state.dart';

class HomeUpBar extends StatelessWidget {
  const HomeUpBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 10.h,
      ),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                width: 30.w,
                height: 30.h,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
                child: ClipOval(
                  child: Image.asset(
                      AppAssets.imageProfile,
                      fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 1.w,
                height: 28.h,
                color: AppColors.primaryColor,
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    "أحمد اسعد",
                    style: TextStyle(
                      fontSize: 11.sp,
                    ),
                  ),
                  Text(
                    "القاهره",
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(
            flex: 1,
          ),
          Text(
            "home".tr(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(
            flex: 2,
          ),
          BlocProvider(
            create: (context) =>
                NotificationCubit()
                  ..loadNotifications(),
            child: BlocBuilder<NotificationCubit,
                NotificationState>(
              builder: (context, state) {
                final unreadCount =
                    state is NotificationLoaded
                        ? state.unreadCount
                        : 0;

                return Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          Routes
                              .notificationsPage,
                        ).then((_) {
                          context
                              .read<
                                  NotificationCubit>()
                              .loadNotifications();
                        });
                      },
                      icon: Icon(
                        Icons.notifications,
                        color: AppColors
                            .primaryColor,
                        size: 24.sp,
                      ),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 8.w,
                        top: 8.h,
                        child: Container(
                          padding:
                              EdgeInsets.all(2.r),
                          decoration:
                              BoxDecoration(
                            color: Colors.red,
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        8.r),
                          ),
                          constraints:
                              BoxConstraints(
                            minWidth: 14.w,
                            minHeight: 12.h,
                          ),
                          child: Text(
                            unreadCount > 99
                                ? '99+'
                                : unreadCount
                                    .toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.sp,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                            textAlign:
                                TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
