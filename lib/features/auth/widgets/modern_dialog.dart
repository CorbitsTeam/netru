import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';

class ModernDialog extends StatelessWidget {
  final String title;
  final String message;
  final Widget? icon;
  final List<ModernDialogAction> actions;
  final Color? titleColor;
  final Color? backgroundColor;
  final bool showCloseButton;

  const ModernDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    required this.actions,
    this.titleColor,
    this.backgroundColor,
    this.showCloseButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: BoxConstraints(maxWidth: 340.w, minWidth: 300.w),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            if (showCloseButton)
              Padding(
                padding: EdgeInsets.only(top: 12.h, right: 12.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32.w,
                        height: 32.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 18.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Content
            Padding(
              padding: EdgeInsets.fromLTRB(
                24.w,
                showCloseButton ? 8.h : 32.h,
                24.w,
                24.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  if (icon != null) ...[
                    Container(
                      width: 64.w,
                      height: 64.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: icon,
                    ),
                    SizedBox(height: 20.h),
                  ],

                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: titleColor ?? AppColors.textPrimary,
                      fontFamily: 'Almarai',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),

                  // Message
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textSecondary,
                      fontFamily: 'Almarai',
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32.h),

                  // Actions
                  if (actions.isNotEmpty) ...[
                    if (actions.length == 1)
                      SizedBox(width: double.infinity, child: actions.first)
                    else if (actions.length == 2)
                      Row(
                        children: [
                          Expanded(child: actions[1]), // Secondary action
                          SizedBox(width: 12.w),
                          Expanded(child: actions[0]), // Primary action
                        ],
                      )
                    else
                      Column(
                        children:
                            actions
                                .map(
                                  (action) => Padding(
                                    padding: EdgeInsets.only(bottom: 8.h),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: action,
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    Widget? icon,
    required List<ModernDialogAction> actions,
    Color? titleColor,
    Color? backgroundColor,
    bool showCloseButton = false,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withOpacity(0.5),
      builder:
          (context) => ModernDialog(
            title: title,
            message: message,
            icon: icon,
            actions: actions,
            titleColor: titleColor,
            backgroundColor: backgroundColor,
            showCloseButton: showCloseButton,
          ),
    );
  }
}

class ModernDialogAction extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isPrimary;
  final bool isDestructive;
  final Widget? icon;

  const ModernDialogAction({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.isPrimary = false,
    this.isDestructive = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color txtColor;

    if (isDestructive) {
      bgColor = backgroundColor ?? Colors.red[50]!;
      txtColor = textColor ?? Colors.red[700]!;
    } else if (isPrimary) {
      bgColor = backgroundColor ?? AppColors.primary;
      txtColor = textColor ?? Colors.white;
    } else {
      bgColor = backgroundColor ?? Colors.grey[100]!;
      txtColor = textColor ?? AppColors.textSecondary;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 20.w),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12.r),
            border:
                isPrimary
                    ? null
                    : Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, SizedBox(width: 8.w)],
              Text(
                text,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
                  color: txtColor,
                  fontFamily: 'Almarai',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Predefined dialog types for common use cases
class ModernAlertDialogs {
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
    bool isDestructive = false,
  }) async {
    return await ModernDialog.show<bool>(
      context: context,
      title: title,
      message: message,
      icon: Icon(
        isDestructive ? Icons.warning_rounded : Icons.help_outline_rounded,
        color: isDestructive ? Colors.orange : AppColors.primary,
        size: 32.sp,
      ),
      actions: [
        ModernDialogAction(
          text: confirmText,
          onPressed: () => Navigator.of(context).pop(true),
          isPrimary: true,
          isDestructive: isDestructive,
        ),
        ModernDialogAction(
          text: cancelText,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }

  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'موافق',
  }) async {
    return await ModernDialog.show(
      context: context,
      title: title,
      message: message,
      titleColor: Colors.red[700],
      icon: Icon(
        Icons.error_outline_rounded,
        color: Colors.red[500],
        size: 32.sp,
      ),
      actions: [
        ModernDialogAction(
          text: buttonText,
          onPressed: () => Navigator.of(context).pop(),
          isPrimary: true,
        ),
      ],
    );
  }

  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'رائع',
  }) async {
    return await ModernDialog.show(
      context: context,
      title: title,
      message: message,
      titleColor: Colors.green[700],
      icon: Icon(
        Icons.check_circle_outline_rounded,
        color: Colors.green[500],
        size: 32.sp,
      ),
      actions: [
        ModernDialogAction(
          text: buttonText,
          onPressed: () => Navigator.of(context).pop(),
          isPrimary: true,
        ),
      ],
    );
  }

  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'فهمت',
  }) async {
    return await ModernDialog.show(
      context: context,
      title: title,
      message: message,
      icon: Icon(
        Icons.info_outline_rounded,
        color: AppColors.primary,
        size: 32.sp,
      ),
      actions: [
        ModernDialogAction(
          text: buttonText,
          onPressed: () => Navigator.of(context).pop(),
          isPrimary: true,
        ),
      ],
    );
  }
}
