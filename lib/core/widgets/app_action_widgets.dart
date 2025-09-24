import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/ui_constants.dart';

/// A reusable action tile widget used in settings and other pages
class AppActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? titleColor;
  final Color? iconColor;
  final bool showArrow;
  final Widget? trailing;
  final EdgeInsets? padding;

  const AppActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.titleColor,
    this.iconColor,
    this.showArrow = true,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: padding ?? UIConstants.paddingSymmetricMedium,
        child: Row(
          children: [
            Container(
              padding: UIConstants.paddingSmall,
              decoration: BoxDecoration(
                color: (iconColor ?? Theme.of(context).primaryColor).withValues(
                  alpha: 0.1,
                ),
                borderRadius: UIConstants.borderRadiusSmall,
              ),
              child: Icon(
                icon,
                size: UIConstants.iconSizeMedium,
                color: iconColor ?? Theme.of(context).primaryColor,
              ),
            ),
            UIConstants.horizontalSpaceMedium,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: UIConstants.fontSizeMedium,
                      fontWeight: FontWeight.w500,
                      color:
                          titleColor ??
                          Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: UIConstants.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null && showArrow)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: UIConstants.iconSizeSmall,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
          ],
        ),
      ),
    );
  }
}

/// A reusable info row widget for displaying key-value pairs
class AppInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final EdgeInsets? padding;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const AppInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.padding,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: UIConstants.iconSizeSmall,
              color: iconColor ?? Theme.of(context).primaryColor,
            ),
            UIConstants.horizontalSpaceSmall,
          ],
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style:
                  labelStyle ??
                  TextStyle(
                    fontSize: UIConstants.fontSizeSmall,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
          ),
          UIConstants.horizontalSpaceSmall,
          Expanded(
            child: Text(
              value,
              style:
                  valueStyle ??
                  TextStyle(
                    fontSize: UIConstants.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A reusable gradient button widget
class AppGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final List<Color>? gradientColors;
  final EdgeInsets? padding;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;
  final Widget? icon;
  final bool isLoading;

  const AppGradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradientColors,
    this.padding,
    this.height,
    this.width,
    this.borderRadius,
    this.textStyle,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 48.h,
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              gradientColors ??
              [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withValues(alpha: 0.8),
              ],
        ),
        borderRadius: borderRadius ?? UIConstants.borderRadiusMedium,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: borderRadius ?? UIConstants.borderRadiusMedium,
          child: Container(
            padding: padding ?? UIConstants.paddingSymmetricMedium,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else ...[
                  if (icon != null) ...[
                    icon!,
                    UIConstants.horizontalSpaceSmall,
                  ],
                  Text(
                    text,
                    style:
                        textStyle ??
                        TextStyle(
                          color: Colors.white,
                          fontSize: UIConstants.fontSizeMedium,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
