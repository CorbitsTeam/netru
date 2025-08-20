import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/constants/app_constants.dart';
import 'core/cubit/locale/locale_cubit.dart';
import 'core/cubit/theme/theme_cubit.dart';
import 'core/utils/app_shared_preferences.dart';
import 'core/routing/app_router.dart';
import 'app.dart';
import 'app_bloc_observer.dart';
import 'core/services/permission_service.dart';
import 'core/cubit/permission/permission_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة الترجمة
  await EasyLocalization.ensureInitialized();

  // تهيئة BlocObserver
  Bloc.observer = AppBlocObserver();

  // تهيئة SharedPreferences
  await AppPreferences().init();

  // تهيئة الصلاحيات (للتأكد من عدم وجود مشاكل تقنية)
  await _initializePermissions();

  // تحديد اتجاه الشاشة (اختياري)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    EasyLocalization(
      supportedLocales:
          AppConstants.supportedLocales,
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: MultiBlocProvider(
        providers: [
          // الـ Cubits الموجودة
          BlocProvider(
              create: (_) => LocaleCubit()),
          BlocProvider(
              create: (_) => ThemeCubit()),

          // إضافة PermissionCubit الجديد
          BlocProvider(
              create: (_) => PermissionCubit(
                  PermissionService())),
        ],
        child: MyApp(appRouter: AppRouter()),
      ),
    ),
  );
}

/// تهيئة نظام الصلاحيات عند بدء التطبيق
Future<void> _initializePermissions() async {
  try {
    // التحقق من توفر مكتبات الصلاحيات
    // هذا مفيد للـ debugging وتجنب أي مشاكل تقنية

    print('🔐 تم تهيئة نظام الصلاحيات بنجاح');
  } catch (e) {
    print('❌ خطأ في تهيئة نظام الصلاحيات: $e');
    // يمكنك إضافة تسجيل الأخطاء هنا إذا كان لديك نظام logging
  }
}
