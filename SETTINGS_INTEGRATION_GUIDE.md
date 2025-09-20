# Settings System Integration Guide

This guide shows how to integrate the refactored settings system with your Netru app using SharedPreferences.

## Overview

The settings system has been completely refactored to:
- Use SharedPreferences instead of Isar
- Integrate with your existing ThemeCubit and LocaleCubit
- Support additional settings like notifications, sound, and vibration
- Provide a clean BLoC architecture

## Integration Steps

### 1. Add Settings Bloc to Your App

Update your `main.dart` to include the settings bloc:

```dart
import 'package:netru_app/features/settings/integration/settings_integration.dart';

// In your main() function:
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
        
        // ... your other providers
      ],
      child: SettingsIntegration.wrapWithSync(
        child: MyApp(appRouter: AppRouter()),
      ),
    ),
  ),
);
```

### 2. Use Settings Widgets in Your UI

Replace your existing theme and language sections:

```dart
// In your settings page or wherever you want these controls:
import 'package:netru_app/features/settings/presentation/widgets/theme_section.dart';
import 'package:netru_app/features/settings/presentation/widgets/language_section.dart';
import 'package:netru_app/features/settings/presentation/widgets/notification_settings_widget.dart';

// In your build method:
Column(
  children: [
    // Theme control
    const ThemeSection(),
    
    // Language control  
    const LanguageSection(),
    
    // Notification settings
    const NotificationSettingsWidget(),
  ],
)
```

### 3. Manual Settings Control

You can also control settings programmatically:

```dart
import 'package:netru_app/core/services/settings_service.dart';

// Change language
SettingsService().updateLanguage(context, Language.english);

// Change theme
SettingsService().updateTheme(context, ThemeMode.dark);

// Update notification settings
SettingsService().updateNotifications(context, false);
SettingsService().updateSound(context, true);
SettingsService().updateVibration(context, true);
```

### 4. Listen to Settings Changes

You can listen to settings changes in any widget:

```dart
BlocBuilder<SettingsBloc, SettingsState>(
  builder: (context, state) {
    if (state is SettingsLoaded) {
      final settings = state.settings;
      
      return Column(
        children: [
          Text('Language: ${settings.language}'),
          Text('Theme: ${settings.themeMode}'),
          Text('Notifications: ${settings.notificationsEnabled}'),
          // ... use settings
        ],
      );
    }
    
    return const CircularProgressIndicator();
  },
)
```

## Key Features

### Automatic Synchronization
- Settings changes automatically sync with ThemeCubit and LocaleCubit
- Changes are persisted to SharedPreferences
- EasyLocalization is updated when language changes

### Comprehensive Settings
- Language (Arabic/English)
- Theme (Light/Dark/System)
- Notifications (Enabled/Disabled)
- Sound (Enabled/Disabled)  
- Vibration (Enabled/Disabled)

### Clean Architecture
- Domain layer with Settings entity and repository interface
- Data layer with SharedPreferences implementation
- Presentation layer with BLoC pattern
- Service layer for integration with existing cubits

## File Structure

```
lib/
├── features/settings/
│   ├── data/
│   │   └── repositories/
│   │       └── settings_repository_impl.dart
│   ├── domain/
│   │   └── repositories/
│   │       └── settings_repository.dart
│   ├── integration/
│   │   └── settings_integration.dart
│   └── presentation/
│       ├── bloc/
│       │   ├── settings_bloc.dart
│       │   ├── settings_event.dart
│       │   └── settings_state.dart
│       ├── domain/
│       │   └── settings.dart
│       └── widgets/
│           ├── theme_section.dart
│           ├── language_section.dart
│           └── notification_settings_widget.dart
└── core/
    └── services/
        └── settings_service.dart
```

## Migration Notes

- The old BTL/Isar dependencies have been removed
- Settings are now stored in SharedPreferences using your existing AppPreferences class
- The Language enum is now defined in the settings domain
- All settings changes are automatically synced with your existing cubits

## Testing

To test the integration:

1. Change language in settings - should update app language immediately
2. Change theme in settings - should update app theme immediately  
3. Restart app - settings should persist across app launches
4. Check SharedPreferences to see stored settings data

The settings are stored in SharedPreferences with the key 'app_settings' as a JSON object.