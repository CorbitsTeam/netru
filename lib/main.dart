import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/cubit/locale/locale_cubit.dart';
import 'core/cubit/theme/theme_cubit.dart';
import 'core/utils/app_shared_preferences.dart';
import 'core/utils/user_data_helper.dart';
import 'core/routing/app_router.dart';
import 'core/di/injection_container.dart';
import 'core/services/notification_service.dart';
import 'app.dart';
import 'app_bloc_observer.dart';
import 'core/services/logger_service.dart';
import 'firebase_options.dart';
import 'features/settings/integration/settings_integration.dart';
// Don't forget Fcm Token For User Notifications


// Admin Account Email: admin@netru.com
// Admin Account Password: Netru@12345
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Logger
  final logger = LoggerService();
  logger.init();
  logger.logInfo('🚀 Application Starting...');

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://yesjtlgciywmwrdpjqsr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inllc2p0bGdjaXl3bXdyZHBqcXNyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1OTA0MDMsImV4cCI6MjA3MzE2NjQwM30.0CNthKQ6Ok2L-9JjReCAUoqEeRHSidxTMLmCl2eEPhw',
  );
  logger.logInfo('✅ Supabase Initialized');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  logger.logInfo('✅ Firebase Initialized');

  // Initialize dependency injection
  await initializeDependencies();
  logger.logInfo('✅ All Dependencies Initialized');

  // Initialize Notification Service
  try {
    final notificationService = NotificationService();
    await notificationService.init();
    logger.logInfo('✅ NotificationService Initialized');
  } catch (e) {
    logger.logError('⚠️ NotificationService Initialization Failed: $e');
  }

  // Initialize localization
  await EasyLocalization.ensureInitialized();
  logger.logInfo('✅ Localization Initialized');

  // Initialize BlocObserver
  Bloc.observer = AppBlocObserver();
  logger.logInfo('✅ BlocObserver Initialized');

  // Initialize SharedPreferences
  await AppPreferences().init();
  logger.logInfo('✅ SharedPreferences Initialized');

  // Initialize user data (refresh from database if user is logged in)
  try {
    final userHelper = UserDataHelper();
    await userHelper.initializeUserData();
    logger.logInfo('✅ User Data Initialized');
  } catch (e) {
    logger.logError('⚠️ User Data Initialization Failed: $e');
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  logger.logInfo('✅ Orientation Settings Applied');

  logger.logInfo('🎯 Launching Application...');

  runApp(
    EasyLocalization(
      supportedLocales: AppConstants.supportedLocales,
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: MultiBlocProvider(
        providers: [
          // Core Cubits
          BlocProvider(create: (_) => LocaleCubit()),
          BlocProvider(create: (_) => ThemeCubit()),

          // Settings Bloc - Main controller for theme and language
          SettingsIntegration.createProvider(),
        ],
        child: SettingsIntegration.wrapWithSync(
          child: MyApp(appRouter: AppRouter()),
        ),
      ),
    ),
  );
}
