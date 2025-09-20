import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:netru_app/features/settings/presentation/domain/settings.dart';
import 'package:netru_app/features/settings/domain/repositories/settings_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _repository;

  SettingsBloc(this._repository) : super(SettingsInitial()) {
    on<SettingsLanguageChanged>(_onLanguageChanged);
    on<SettingsThemeChanged>(_onThemeChanged);
    on<SettingsNotificationChanged>(_onNotificationChanged);
    on<SettingsSoundChanged>(_onSoundChanged);
    on<SettingsVibrationChanged>(_onVibrationChanged);
    on<SettingsFetched>(_onFetched);

    add(const SettingsFetched());
  }

  Future<void> _onFetched(
    SettingsFetched event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      final savedSettings = await _repository.getSettings();
      emit(SettingsLoaded(savedSettings));
    } catch (e) {
      emit(SettingsError('Failed to load settings: $e'));
    }
  }

  Future<void> _onLanguageChanged(
    SettingsLanguageChanged event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      final newSettings = currentSettings.copyWith(language: event.language);

      emit(SettingsLoaded(newSettings));
      unawaited(_repository.updateSettings(newSettings));
    }
  }

  Future<void> _onThemeChanged(
    SettingsThemeChanged event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      final newSettings = currentSettings.copyWith(themeMode: event.themeMode);

      emit(SettingsLoaded(newSettings));
      unawaited(_repository.updateSettings(newSettings));
    }
  }

  Future<void> _onNotificationChanged(
    SettingsNotificationChanged event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      final newSettings = currentSettings.copyWith(
        notificationsEnabled: event.enabled,
      );

      emit(SettingsLoaded(newSettings));
      unawaited(_repository.updateSettings(newSettings));
    }
  }

  Future<void> _onSoundChanged(
    SettingsSoundChanged event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      final newSettings = currentSettings.copyWith(soundEnabled: event.enabled);

      emit(SettingsLoaded(newSettings));
      unawaited(_repository.updateSettings(newSettings));
    }
  }

  Future<void> _onVibrationChanged(
    SettingsVibrationChanged event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      final newSettings = currentSettings.copyWith(
        vibrationEnabled: event.enabled,
      );

      emit(SettingsLoaded(newSettings));
      unawaited(_repository.updateSettings(newSettings));
    }
  }
}
