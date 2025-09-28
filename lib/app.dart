import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/features/settings/presentation/domain/settings.dart';
import 'core/routing/app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/cubit/theme/theme_cubit.dart';
import 'core/theme/app_theme.dart';
import 'core/services/deep_link_service.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';

class MyApp extends StatelessWidget {
  final AppRouter appRouter;
  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            // Get theme and locale from settings if available, fallback to existing cubits
            ThemeMode themeMode = ThemeMode.light;
            Locale? appLocale;

            if (settingsState is SettingsLoaded) {
              themeMode = settingsState.settings.themeMode;
              appLocale =
                  settingsState.settings.language == Language.arabic
                      ? const Locale('ar')
                      : const Locale('en');
            } else {
              // Fallback to ThemeCubit if settings not loaded yet
              final themeState = context.read<ThemeCubit>().state;
              themeMode = themeState.themeMode;
            }

            // Global navigator key for deep link handling
            final GlobalKey<NavigatorState> navigatorKey =
                GlobalKey<NavigatorState>();

            return MaterialApp(
              key: const ValueKey('main_material_app'),
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              title: AppConstants.appName,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              locale: appLocale ?? context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              onGenerateRoute: appRouter.generateRoute,
              initialRoute: '/',
              builder: (context, child) {
                // Initialize deep link service when app starts
                if (navigatorKey.currentState != null) {
                  DeepLinkService().init(navigatorKey.currentState!);
                }
                return child!;
              },
            );
          },
        );
      },
    );
  }
}
