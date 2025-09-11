import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrimaryOutlinedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isLoading;
  final double? width;
  final double height;
  final Color? color;
  final double borderRadius;

  const PrimaryOutlinedButton({
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
    final buttonColor = color ?? Theme.of(context).colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      width: isLoading ? 80.w : (width ?? MediaQuery.of(context).size.width),
      height: height.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: buttonColor,
          backgroundColor: Colors.white,
          side: BorderSide(color: buttonColor, width: 2),
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
                    child: CircularProgressIndicator(
                      color: buttonColor,
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
                      color: buttonColor,
                    ),
                  ),
        ),
      ),
    );
  }
}
