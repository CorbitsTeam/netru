import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netru_app/core/utils/app_shared_preferences.dart';
import 'package:netru_app/core/services/settings_service.dart';
import 'package:netru_app/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:netru_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:netru_app/features/settings/presentation/bloc/settings_bloc.dart';

/// Settings integration for dependency injection
class SettingsIntegration {
  /// Create repository instance
  static SettingsRepository createRepository() {
    return SettingsRepositoryImpl(AppPreferences());
  }

  /// Create settings bloc
  static SettingsBloc createBloc() {
    return SettingsBloc(createRepository());
  }

  /// Add settings provider to your MultiBlocProvider
  static BlocProvider<SettingsBloc> createProvider() {
    return BlocProvider<SettingsBloc>(create: (context) => createBloc());
  }

  /// Wrap your main app widget with settings sync listener
  static Widget wrapWithSync({required Widget child}) {
    return SettingsService().createSyncListener(child: child);
  }
}

/// Example usage in main.dart:
/*
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
        
        // Settings Bloc - ADD THIS
        SettingsIntegration.createProvider(),
        
        // ... other providers
      ],
      child: SettingsIntegration.wrapWithSync(
        child: MyApp(appRouter: AppRouter()),
      ),
    ),
  ),
);
*/
