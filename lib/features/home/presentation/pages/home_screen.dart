import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/di/injection_container.dart';
import 'package:netru_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:netru_app/features/home/presentation/cubit/home_state.dart';
import 'package:netru_app/features/home/presentation/widgets/news_carousel_card.dart';
import 'package:netru_app/features/home/presentation/widgets/news_list_widget.dart';
import 'package:netru_app/features/home/presentation/widgets/real_time_statistics_cards.dart';
import 'package:netru_app/features/home/presentation/widgets/user_header_widget.dart';
import 'package:netru_app/features/news/presentation/cubit/news_cubit.dart';
import '../../../../core/routing/routes.dart';

import '../../../../core/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _buttonX = 0.0;
  double _buttonY = 0.0;

  @override
  void initState() {
    super.initState();
    // Initialize button position on the left side, 50.h from bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() {
        _buttonX = 16.w; // Left side with some padding
        _buttonY =
            size.height -
            200.h; // 50.h from bottom navigation (56.h nav height + 50.h spacing)
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<NewsCubit>()),
        // Create HomeCubit directly here to avoid GetIt lookup at build time
        BlocProvider(create: (_) => HomeCubit()),
      ],
      // Use a Builder so we can access the HomeCubit created by the provider
      child: Builder(
        builder: (ctx) {
          // Initialize FCM token once the provider is available
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final homeCubit = ctx.read<HomeCubit>();
            homeCubit.initializeFcmToken();
            homeCubit.setupTokenRefreshListener();
          });

          return BlocListener<HomeCubit, HomeState>(
            listener: (context, state) {
              if (state is HomeFcmTokenSuccess) {
                // FCM token received successfully
                print('🎉 FCM Token: ${state.fcmToken}');
              } else if (state is HomeFailure) {
                // Handle FCM token error
                print('❌ FCM Error: ${state.error}');
              }
            },
            child: Scaffold(
              appBar: AppBar(toolbarHeight: 0, backgroundColor: Colors.white),
              body: Stack(
                children: [
                  SafeArea(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const UserHeaderWidget(),
                            SizedBox(height: 10.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: 50,
                                      height: 2,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Text(
                                    "جهود الأجهزة الأمنية",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14.sp,
                                      color: AppColors.primaryColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Container(
                                      width: 50,
                                      height: 2,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10.h),
                            const NewsCarouselCard(),
                            SizedBox(height: 15.h),
                            Text(
                              "statistics".tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            const RealTimeStatisticsCards(),
                            SizedBox(height: 15.h),
                            const NewsListWidget(
                              maxItems: 3,
                              headerTitle: "أحدث الأخبار",
                            ),
                            SizedBox(height: 15.h),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Draggable Chat Button
                  Positioned(
                    left: _buttonX,
                    top: _buttonY,
                    child: Draggable(
                      feedback: _buildChatButton(isDragging: true),
                      childWhenDragging:
                          Container(), // Hide original when dragging
                      onDragEnd: (details) {
                        final size = MediaQuery.of(context).size;
                        setState(() {
                          // Constrain button within screen bounds
                          _buttonX = details.offset.dx.clamp(
                            0.0,
                            size.width - 56.w,
                          );
                          _buttonY = details.offset.dy.clamp(
                            MediaQuery.of(context).padding.top,
                            size.height -
                                56.w -
                                MediaQuery.of(context).padding.bottom,
                          );
                        });
                      },
                      child: _buildChatButton(),
                    ),
                  ),
                ],
              ),
            ),
          ); // close BlocListener
        }, // close Builder
      ), // close Builder widget
    ); // close MultiBlocProvider
  }

  Widget _buildChatButton({bool isDragging = false}) {
    return Material(
      color: AppColors.primary,
      elevation: isDragging ? 10 : 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.r)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap:
            isDragging
                ? null
                : () => Navigator.pushNamed(context, Routes.chatPage),
        child: SizedBox(
          width: 56.w,
          height: 56.w,
          child: Icon(
            Icons.support_agent_outlined, // Changed icon to support agent
            color: Colors.white,
            size: 26.sp,
          ),
        ),
      ),
    );
  }
}
