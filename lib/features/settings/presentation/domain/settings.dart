import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum Language { arabic, english }

class Settings extends Equatable {
  final Language language;
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;

  const Settings({
    this.language = Language.arabic,
    this.themeMode = ThemeMode.light,
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  @override
  List<Object> get props => [
    language,
    themeMode,
    notificationsEnabled,
    soundEnabled,
    vibrationEnabled,
  ];

  // Convert to JSON for SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'language': language.name,
      'themeMode': themeMode.name,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  // Create from JSON for SharedPreferences
  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      language: Language.values.firstWhere(
        (e) => e.name == json['language'],
        orElse: () => Language.arabic,
      ),
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => ThemeMode.light,
      ),
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
    );
  }
}

extension SettingsX on Settings {
  Settings copyWith({
    Language? language,
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return Settings(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  // Getters
  bool get isThemeDark => themeMode == ThemeMode.dark;
  bool get isThemeLight => themeMode == ThemeMode.light;

  bool get isArabic => language == Language.arabic;
  bool get isEnglish => language == Language.english;

  // Convert to Locale
  Locale get locale =>
      language == Language.arabic ? const Locale('ar') : const Locale('en');
}
