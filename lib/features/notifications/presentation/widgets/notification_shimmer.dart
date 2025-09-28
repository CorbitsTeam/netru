import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class NotificationShimmer extends StatefulWidget {
  const NotificationShimmer({super.key});

  @override
  State<NotificationShimmer> createState() => _NotificationShimmerState();
}

class _NotificationShimmerState extends State<NotificationShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutSine,
      ),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          child: Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.r),
            elevation: 1,
            shadowColor: AppColors.shadow,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.borderLight, width: 1.5),
              ),
              padding: EdgeInsets.all(16.r),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon shimmer with improved design
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Container(
                        width: 48.w,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: AppColors.border.withOpacity(
                            _animation.value * 0.6,
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.borderLight.withOpacity(
                              _animation.value,
                            ),
                            width: 1,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 14.w),

                  // Content shimmer with improved design
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Type label shimmer
                        Row(
                          children: [
                            AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                return Container(
                                  height: 16.h,
                                  width: 50.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.border.withOpacity(
                                      _animation.value * 0.6,
                                    ),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                );
                              },
                            ),
                            const Spacer(),
                            AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                return Container(
                                  height: 12.h,
                                  width: 30.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.border.withOpacity(
                                      _animation.value * 0.6,
                                    ),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),

                        // Title shimmer
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Container(
                              height: 18.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.border.withOpacity(
                                  _animation.value * 0.8,
                                ),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 6.h),

                        // Body shimmer lines
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Container(
                              height: 14.h,
                              width: 220.w,
                              decoration: BoxDecoration(
                                color: AppColors.border.withOpacity(
                                  _animation.value * 0.6,
                                ),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 4.h),

                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Container(
                              height: 14.h,
                              width: 180.w,
                              decoration: BoxDecoration(
                                color: AppColors.border.withOpacity(
                                  _animation.value * 0.5,
                                ),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 12.h),

                        // Time and action row shimmer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                return Container(
                                  height: 24.h,
                                  width: 80.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.border.withOpacity(
                                      _animation.value * 0.4,
                                    ),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                );
                              },
                            ),
                            AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                return Container(
                                  height: 24.h,
                                  width: 60.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.border.withOpacity(
                                      _animation.value * 0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
