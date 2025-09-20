import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:netru_app/features/settings/presentation/bloc/settings_bloc.dart';

class ThemeSection extends StatelessWidget {
  const ThemeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (previous, current) {
        // Only rebuild when theme mode actually changes
        if (previous is SettingsLoaded && current is SettingsLoaded) {
          return previous.settings.themeMode != current.settings.themeMode;
        }
        return true;
      },
      builder: (context, state) {
        final isDarkMode =
            state is SettingsLoaded
                ? state.settings.themeMode == ThemeMode.dark
                : false;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
            // Custom Toggle Switch
            GestureDetector(
              onTap: () {
                final settingsBloc = context.read<SettingsBloc>();
                final newTheme = isDarkMode ? ThemeMode.light : ThemeMode.dark;
                settingsBloc.add(SettingsThemeChanged(newTheme));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 35.w,
                height: 20.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  color: isDarkMode ? AppColors.primaryColor : Colors.grey[300],
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment:
                      isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 16.w,
                    height: 20.h,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
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
      },
    );
  }
}
