import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/ui_constants.dart';

/// A reusable confirmation dialog widget
class AppConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final IconData? icon;
  final Color? iconColor;
  final Color? confirmButtonColor;

  const AppConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = 'تأكيد',
    this.cancelText = 'إلغاء',
    this.onConfirm,
    this.onCancel,
    this.icon,
    this.iconColor,
    this.confirmButtonColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: UIConstants.borderRadiusExtraLarge,
      ),
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: iconColor ?? Theme.of(context).primaryColor,
              size: UIConstants.iconSizeLarge,
            ),
            UIConstants.horizontalSpaceSmall,
          ],
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: UIConstants.fontSizeExtraLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        content,
        style: TextStyle(fontSize: UIConstants.fontSizeMedium),
      ),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(false),
          child: Text(
            cancelText,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                confirmButtonColor ?? Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: UIConstants.borderRadiusMedium,
            ),
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }

  /// Shows the confirmation dialog and returns the result
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
    IconData? icon,
    Color? iconColor,
    Color? confirmButtonColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AppConfirmationDialog(
            title: title,
            content: content,
            confirmText: confirmText,
            cancelText: cancelText,
            icon: icon,
            iconColor: iconColor,
            confirmButtonColor: confirmButtonColor,
          ),
    );
  }
}

/// A reusable loading dialog widget
class AppLoadingDialog extends StatelessWidget {
  final String message;
  final bool canDismiss;

  const AppLoadingDialog({
    super.key,
    required this.message,
    this.canDismiss = false,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => canDismiss,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: UIConstants.borderRadiusExtraLarge,
        ),
        content: Container(
          padding: UIConstants.paddingMedium,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
                strokeWidth: 3.0,
              ),
              UIConstants.verticalSpaceLarge,
              Text(
                message,
                style: TextStyle(
                  fontSize: UIConstants.fontSizeMedium,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              UIConstants.verticalSpaceSmall,
              Text(
                'يرجى الانتظار',
                style: TextStyle(
                  fontSize: UIConstants.fontSizeSmall,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows the loading dialog
  static void show(
    BuildContext context, {
    required String message,
    bool canDismiss = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: canDismiss,
      builder:
          (context) =>
              AppLoadingDialog(message: message, canDismiss: canDismiss),
    );
  }

  /// Hides the loading dialog if it's currently showing
  static void hide(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}

/// A reusable success dialog widget
class AppSuccessDialog extends StatelessWidget {
  final String title;
  final String content;
  final String buttonText;
  final VoidCallback? onPressed;
  final Widget? customAction;

  const AppSuccessDialog({
    super.key,
    required this.title,
    required this.content,
    this.buttonText = 'حسناً',
    this.onPressed,
    this.customAction,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: UIConstants.borderRadiusExtraLarge,
      ),
      child: Container(
        padding: UIConstants.paddingLarge,
        decoration: BoxDecoration(
          borderRadius: UIConstants.borderRadiusExtraLarge,
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 50.r,
                color: Colors.green,
              ),
            ),
            UIConstants.verticalSpaceLarge,
            Text(
              title,
              style: TextStyle(
                fontSize: UIConstants.fontSizeTitle,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            UIConstants.verticalSpaceMedium,
            Text(
              content,
              style: TextStyle(
                fontSize: UIConstants.fontSizeMedium,
                color: Colors.grey[700],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            UIConstants.verticalSpaceLarge,
            customAction ??
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onPressed ?? () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: UIConstants.paddingSymmetricMedium,
                      shape: RoundedRectangleBorder(
                        borderRadius: UIConstants.borderRadiusMedium,
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        fontSize: UIConstants.fontSizeMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  /// Shows the success dialog
  static void show(
    BuildContext context, {
    required String title,
    required String content,
    String buttonText = 'حسناً',
    VoidCallback? onPressed,
    Widget? customAction,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AppSuccessDialog(
            title: title,
            content: content,
            buttonText: buttonText,
            onPressed: onPressed,
            customAction: customAction,
          ),
    );
  }
}
