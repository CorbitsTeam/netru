import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';

class LoadingDialog extends StatelessWidget {
  final String message;
  final bool showProgress;
  final double? progress;

  const LoadingDialog({
    super.key,
    this.message = 'جاري التحميل...',
    this.showProgress = false,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Loading Animation
            Container(
              width: 80.w,
              height: 80.h,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 3,
                value: showProgress ? progress : null,
              ),
            ),
            SizedBox(height: 24.h),

            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                fontFamily: 'Almarai',
              ),
              textAlign: TextAlign.center,
            ),

            // Progress indicator
            if (showProgress && progress != null) ...[
              SizedBox(height: 16.h),
              Text(
                '${(progress! * 100).round()}%',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  fontFamily: 'Almarai',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    String message = 'جاري التحميل...',
    bool showProgress = false,
    double? progress,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
      builder:
          (_) => LoadingDialog(
            message: message,
            showProgress: showProgress,
            progress: progress,
          ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}

class SuccessDialog extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback? onComplete;
  final Duration duration;

  const SuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.onComplete,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5),
      ),
    );

    _animationController.forward();

    // Auto dismiss after duration
    Future.delayed(widget.duration + const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pop();
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AnimatedBuilder(
        animation: _animationController,
        builder:
            (context, child) => Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Container(
                  padding: EdgeInsets.all(32.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.green.withOpacity(0.1),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Success Icon
                      Container(
                        width: 80.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green[600],
                          size: 50.sp,
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Title
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontFamily: 'Almarai',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12.h),

                      // Message
                      Text(
                        widget.message,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.textSecondary,
                          fontFamily: 'Almarai',
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onComplete,
    Duration duration = const Duration(seconds: 2),
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
      builder:
          (_) => SuccessDialog(
            title: title,
            message: message,
            onComplete: onComplete,
            duration: duration,
          ),
    );
  }
}

// Animated snackbar replacement
class ModernSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onActionPressed,
    String? actionLabel,
  }) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = Colors.green[600]!;
        textColor = Colors.white;
        icon = Icons.check_circle;
        break;
      case SnackBarType.error:
        backgroundColor = Colors.red[600]!;
        textColor = Colors.white;
        icon = Icons.error;
        break;
      case SnackBarType.warning:
        backgroundColor = Colors.orange[600]!;
        textColor = Colors.white;
        icon = Icons.warning;
        break;
      case SnackBarType.info:
        backgroundColor = AppColors.primary;
        textColor = Colors.white;
        icon = Icons.info;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Almarai',
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        action:
            onActionPressed != null && actionLabel != null
                ? SnackBarAction(
                  label: actionLabel,
                  textColor: textColor,
                  onPressed: onActionPressed,
                )
                : null,
      ),
    );
  }
}

enum SnackBarType { success, error, warning, info }
