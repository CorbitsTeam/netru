import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';

class LanguageSection extends StatefulWidget {
  const LanguageSection({super.key});

  @override
  State<LanguageSection> createState() =>
      _LanguageSectionState();
}

class _LanguageSectionState
    extends State<LanguageSection> {
  bool isArabic = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        // Language Text and Icon
        Row(
          children: [
            const Icon(
              Icons.language,
              color: AppColors.primaryColor,
              size: 20,
            ),
            SizedBox(width: 8.w),
            Text(
              'اللغة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        // Language Buttons (Separate)
        Row(
          children: [
            // Arabic Button
            GestureDetector(
              onTap: () {
                setState(() {
                  isArabic = true;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 200,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color:
                      isArabic
                          ? AppColors.primaryColor
                          : Colors.white,
                  borderRadius:
                      BorderRadius.circular(4.r),
                  border: Border.all(
                    color:
                        isArabic
                            ? AppColors
                                .primaryColor
                            : AppColors
                                .primaryColor,
                    width: isArabic ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(
                            alpha: 0.05,
                          ),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  'العربية',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color:
                        isArabic
                            ? Colors.white
                            : AppColors
                                .primaryColor,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            // English Button
            GestureDetector(
              onTap: () {
                setState(() {
                  isArabic = false;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 200,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color:
                      isArabic
                          ? Colors.white
                          : AppColors
                              .primaryColor,
                  borderRadius:
                      BorderRadius.circular(4.r),
                  border: Border.all(
                    color:
                        !isArabic
                            ? AppColors
                                .primaryColor
                            : AppColors
                                .primaryColor,
                    width: !isArabic ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(
                            alpha: 0.05,
                          ),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  'English',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color:
                        !isArabic
                            ? Colors.white
                            : AppColors
                                .primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
