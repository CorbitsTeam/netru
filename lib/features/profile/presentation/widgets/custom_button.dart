import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;
  final Color? textColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    this.onTap,
    required this.text,
    this.textColor = Colors.white,
    this.backgroundColor = AppColors.primaryColor,
    this.borderColor = AppColors.primaryColor,
    this.width = 280,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width!.w,
        height: height!.h,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(
            4.r,
          ),
          border: Border.all(
            color: borderColor!,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }
}
