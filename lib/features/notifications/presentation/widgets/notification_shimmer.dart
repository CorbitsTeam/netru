import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
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
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon shimmer
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[300]!.withOpacity(
                            _animation.value,
                          ),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 12.w),

                  // Content shimmer
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title shimmer
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Container(
                              height: 16.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[300]!.withOpacity(
                                  _animation.value,
                                ),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 8.h),

                        // Body shimmer
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Container(
                              height: 12.h,
                              width: 200.w,
                              decoration: BoxDecoration(
                                color: Colors.grey[300]!.withOpacity(
                                  _animation.value,
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
                              height: 12.h,
                              width: 150.w,
                              decoration: BoxDecoration(
                                color: Colors.grey[300]!.withOpacity(
                                  _animation.value,
                                ),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 8.h),

                        // Time shimmer
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Container(
                              height: 10.h,
                              width: 80.w,
                              decoration: BoxDecoration(
                                color: Colors.grey[300]!.withOpacity(
                                  _animation.value,
                                ),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            );
                          },
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
