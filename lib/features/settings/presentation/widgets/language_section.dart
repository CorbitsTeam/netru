import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:netru_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:netru_app/features/settings/presentation/domain/settings.dart';

class LanguageSection extends StatelessWidget {
  const LanguageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (previous, current) {
        // Only rebuild when language actually changes
        if (previous is SettingsLoaded && current is SettingsLoaded) {
          return previous.settings.language != current.settings.language;
        }
        return true;
      },
      builder: (context, state) {
        final isArabic =
            state is SettingsLoaded
                ? state.settings.language == Language.arabic
                : true;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
            // Language Buttons (Separate)
            Row(
              children: [
                // Arabic Button
                GestureDetector(
                  key: const ValueKey('arabic_language_button'),
                  onTap: () async {
                    if (!isArabic) {
                      final settingsBloc = context.read<SettingsBloc>();
                      settingsBloc.add(
                        const SettingsLanguageChanged(Language.arabic),
                      );
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isArabic
                              ? AppColors.primaryColor
                              : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(
                        color: AppColors.primaryColor,
                        width: isArabic ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
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
                        color: isArabic ? Colors.white : AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                // English Button
                GestureDetector(
                  key: const ValueKey('english_language_button'),
                  onTap: () async {
                    if (isArabic) {
                      final settingsBloc = context.read<SettingsBloc>();
                      settingsBloc.add(
                        const SettingsLanguageChanged(Language.english),
                      );
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color:
                          !isArabic
                              ? AppColors.primaryColor
                              : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(
                        color: AppColors.primaryColor,
                        width: !isArabic ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
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
                            !isArabic ? Colors.white : AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
