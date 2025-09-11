import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/routing/app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/cubit/theme/theme_cubit.dart';

class MyApp extends StatelessWidget {
  final AppRouter appRouter;
  const MyApp(
      {super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return BlocBuilder<ThemeCubit,
            ThemeState>(
          builder: (context, themeState) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: AppConstants.appName,
              theme: ThemeData(
                  scaffoldBackgroundColor:
                      Colors.white,
                  fontFamily: "Almarai"),
              // darkTheme: AppTheme.darkTheme,
              themeMode: themeState.themeMode,
              locale: context.locale,
              supportedLocales:
                  context.supportedLocales,
              localizationsDelegates:
                  context.localizationDelegates,
              onGenerateRoute:
                  appRouter.generateRoute,
              initialRoute: '/',
            );
          },
        );
      },
    );
  }
}
