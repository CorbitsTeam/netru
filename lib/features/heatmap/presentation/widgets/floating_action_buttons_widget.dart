import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class FloatingActionButtonsWidget
    extends StatefulWidget {
  final VoidCallback? onFilterPressed;
  final VoidCallback? onRefreshPressed;
  final VoidCallback? onLocationPressed;

  const FloatingActionButtonsWidget({
    super.key,
    this.onFilterPressed,
    this.onRefreshPressed,
    this.onLocationPressed,
  });

  @override
  State<FloatingActionButtonsWidget>
  createState() =>
      _FloatingActionButtonsWidgetState();
}

class _FloatingActionButtonsWidgetState
    extends State<FloatingActionButtonsWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    // بدء الرسوم المتحركة تلقائياً
    WidgetsBinding.instance.addPostFrameCallback((
      _,
    ) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildFloatingButton(
              icon: Icons.my_location,
              heroTag: "location_btn",
              backgroundColor: AppColors.primary,
              onPressed: widget.onLocationPressed,
              tooltip: 'موقعي الحالي',
              delay: 200,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required String heroTag,
    required Color backgroundColor,
    required VoidCallback? onPressed,
    required String tooltip,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(
        milliseconds: 300 + delay,
      ),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: backgroundColor
                      .withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.1,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: backgroundColor,
              shape: const CircleBorder(),
              elevation: 0,
              child: InkWell(
                customBorder:
                    const CircleBorder(),
                onTap: onPressed,
                child: Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        backgroundColor
                            .withOpacity(0.8),
                        backgroundColor,
                      ],
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 22.sp,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
