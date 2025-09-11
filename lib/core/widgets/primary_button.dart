import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/utils/extensions/extensions.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isLoading;
  final double? width;
  final double height;
  final Color? color;
  final double borderRadius;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.borderRadius = 32,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      margin: EdgeInsets.only(bottom: context.viewInsetsBottom),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      width: isLoading ? 80.w : (width ?? context.width),
      height: height.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius.r),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child:
              isLoading
                  ? SizedBox(
                    key: const ValueKey("loading"),
                    height: 25.h,
                    width: 25.h,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                      strokeCap: StrokeCap.round,
                    ),
                  )
                  : Text(
                    text,
                    key: const ValueKey("text"),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
        ),
      ),
    );
  }
}
