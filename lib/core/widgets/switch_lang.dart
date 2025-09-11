import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/theme/theme_cubit.dart';
import '../services/locale_service.dart';
import '../services/theme_service.dart';

class SettingsSwitchWidget extends StatefulWidget {
  const SettingsSwitchWidget({super.key});

  @override
  State<SettingsSwitchWidget> createState() => _SettingsSwitchWidgetState();
}

class _SettingsSwitchWidgetState extends State<SettingsSwitchWidget> {
  late LocaleService _localeService;
  late ThemeService _themeService;
  bool isDark = false;
  bool isArabic = false;

  @override
  void initState() {
    super.initState();
    _initSettings();
  }

  Future<void> _initSettings() async {
    _localeService = LocaleService();
    _themeService = ThemeService();

    final currentLocale = _localeService.getCurrentLocale();
    final themeMode = _themeService.getThemeMode();

    setState(() {
      isArabic = currentLocale.languageCode == 'ar';
      isDark = themeMode == ThemeMode.dark;
    });
  }

  void _toggleLanguage(Locale newLocale) async {
    // Check if the selected language is the same as the current one
    if ((newLocale.languageCode == 'ar' && isArabic) ||
        (newLocale.languageCode == 'en' && !isArabic)) {
      // Show a message saying the language is already selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          content: Text(
            'language_already_selected'.tr(),
            style: TextStyle(color: Theme.of(context).colorScheme.onError),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      await _localeService.setLocale(context, newLocale.languageCode);
      setState(() {
        isArabic = newLocale.languageCode == 'ar';
      });
    }
  }

  void _toggleTheme() async {
    final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
    await _themeService.saveThemeMode(newMode);
    setState(() => isDark = !isDark);

    // Trigger app rebuild via Bloc if needed
    context.read<ThemeCubit>().changeTheme(newMode);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 🌙 Theme Switch
        IconButton(
          onPressed: _toggleTheme,
          icon: Icon(
            isDark ? Icons.dark_mode : Icons.light_mode,
            color: Theme.of(context).iconTheme.color,
          ),
          tooltip: tr('toggle_theme'),
        ),

        // 🌐 Language Switch
        DropdownButton<Locale>(
          value: EasyLocalization.of(context)?.locale,
          items: const [
            DropdownMenuItem(value: Locale('en'), child: Text('🇺🇸 English')),
            DropdownMenuItem(value: Locale('ar'), child: Text('🇪🇬 العربية')),
          ],
          onChanged: (newLocale) {
            if (newLocale != null) {
              _toggleLanguage(newLocale);
            }
          },
        ),
      ],
    );
  }
}
