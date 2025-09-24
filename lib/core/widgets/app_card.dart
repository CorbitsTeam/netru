import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/ui_constants.dart';

/// A reusable card widget with consistent styling and shadows
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final double? elevation;
  final Border? border;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.boxShadow,
    this.elevation,
    this.border,
    this.onTap,
  });

  factory AppCard.section({
    required Widget child,
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) {
    return AppCard(
      margin: margin ?? UIConstants.paddingHorizontalMedium,
      padding: padding ?? UIConstants.paddingLarge,
      borderRadius: UIConstants.borderRadiusMedium,
      boxShadow: UIConstants.defaultShadow,
      child: child,
    );
  }

  factory AppCard.profile({
    required Widget child,
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) {
    return AppCard(
      margin: margin ?? UIConstants.paddingMedium,
      padding: padding ?? UIConstants.paddingLarge,
      borderRadius: UIConstants.borderRadiusLarge,
      boxShadow: UIConstants.defaultShadow,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget cardWidget = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: borderRadius ?? UIConstants.borderRadiusMedium,
        boxShadow: boxShadow ?? UIConstants.defaultShadow,
        border: border,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? UIConstants.borderRadiusMedium,
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}

/// A reusable section widget with title and content
class AppSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  const AppSection({
    super.key,
    required this.title,
    required this.children,
    this.margin,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: margin ?? UIConstants.paddingHorizontalMedium,
      backgroundColor: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Text(
              title,
              style: TextStyle(
                fontSize: UIConstants.fontSizeLarge,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

/// A reusable divider widget
class AppDivider extends StatelessWidget {
  final double? indent;
  final double? endIndent;
  final double? height;
  final Color? color;

  const AppDivider({
    super.key,
    this.indent,
    this.endIndent,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height ?? 0.5,
      color: color ?? Theme.of(context).dividerColor.withValues(alpha: 0.3),
      indent: indent ?? 16.w,
      endIndent: endIndent ?? 16.w,
    );
  }
}
