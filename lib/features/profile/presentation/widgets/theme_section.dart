import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';

class ThemeSection extends StatefulWidget {
  const ThemeSection({super.key});

  @override
  State<ThemeSection> createState() =>
      _ThemeSectionState();
}

class _ThemeSectionState
    extends State<ThemeSection> {
  bool isDarkMode = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        // Dark Mode Text and Icon
        Row(
          children: [
            Icon(
              isDarkMode
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              color: AppColors.primaryColor,
              size: 20,
            ),
            SizedBox(width: 8.w),
            Text(
              'ثيم التطبيق',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        // Custom Toggle Switch
        GestureDetector(
          onTap: () {
            setState(() {
              isDarkMode = !isDarkMode;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 200,
            ),
            width: 35.w,
            height: 20.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                15.r,
              ),
              color:
                  isDarkMode
                      ? AppColors.primaryColor
                      : Colors.grey[300],
            ),
            child: AnimatedAlign(
              duration: const Duration(
                milliseconds: 200,
              ),
              alignment:
                  isDarkMode
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
              child: Container(
                width: 16.w,
                height: 20.h,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
