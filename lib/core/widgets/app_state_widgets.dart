import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/ui_constants.dart';
import '../theme/app_colors.dart';

/// A reusable loading widget with consistent styling
class AppLoadingWidget extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;
  final double? size;
  final EdgeInsets? padding;

  const AppLoadingWidget({
    super.key,
    this.message,
    this.backgroundColor,
    this.size,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? UIConstants.paddingLarge,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: UIConstants.borderRadiusLarge,
        boxShadow: UIConstants.defaultShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size ?? 40.w,
            height: size ?? 40.h,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          ),
          if (message != null) ...[
            UIConstants.verticalSpaceLarge,
            Text(
              message!,
              style: TextStyle(
                fontSize: UIConstants.fontSizeMedium,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// A reusable error widget with retry functionality
class AppErrorWidget extends StatelessWidget {
  final String message;
  final String? subtitle;
  final VoidCallback? onRetry;
  final IconData? icon;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.subtitle,
    this.onRetry,
    this.icon,
    this.backgroundColor,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? UIConstants.paddingMedium,
      padding: padding ?? UIConstants.paddingLarge,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        borderRadius: UIConstants.borderRadiusExtraLarge,
        boxShadow: UIConstants.cardShadow,
        border: Border.all(color: Colors.red.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: UIConstants.paddingMedium,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon ?? Icons.error_outline,
              size: UIConstants.iconSizeExtraLarge,
              color: Colors.red,
            ),
          ),
          UIConstants.verticalSpaceLarge,
          Text(
            message,
            style: TextStyle(
              fontSize: UIConstants.fontSizeLarge,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            UIConstants.verticalSpaceSmall,
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: UIConstants.fontSizeMedium,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (onRetry != null) ...[
            UIConstants.verticalSpaceLarge,
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: UIConstants.paddingSymmetricMedium,
                shape: RoundedRectangleBorder(
                  borderRadius: UIConstants.borderRadiusMedium,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A reusable empty state widget
class AppEmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final Widget? action;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const AppEmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.action,
    this.backgroundColor,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? UIConstants.paddingMedium,
      padding: padding ?? UIConstants.paddingLarge,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: UIConstants.borderRadiusExtraLarge,
        boxShadow: UIConstants.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon ?? Icons.inbox_outlined,
              size: UIConstants.iconSizeExtraLarge,
              color: Theme.of(context).primaryColor,
            ),
          ),
          UIConstants.verticalSpaceLarge,
          Text(
            title,
            style: TextStyle(
              fontSize: UIConstants.fontSizeExtraLarge,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
          UIConstants.verticalSpaceSmall,
          Text(
            subtitle,
            style: TextStyle(
              fontSize: UIConstants.fontSizeMedium,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[UIConstants.verticalSpaceLarge, action!],
        ],
      ),
    );
  }
}
