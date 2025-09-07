import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/features/settings/data/settings_repository.dart';
import 'package:hive_flutter/hive_flutter.dart'; // V-- Add this line
import 'package:flutter/material.dart';

part 'settings_provider.g.dart';

@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  @override
  Future<SettingsRepository> build() async {
    final repository = SettingsRepository();
    await repository.init();
    return repository;
  }

  // --- Methods to interact with the repository ---
  Future<int> getCheckInDay() async => state.value!.getCheckInDay();
  Future<void> setCheckInDay(int day) async => state.value!.setCheckInDay(day);
}

// We will also need the ThemeController in the same file for now to keep it simple
@Riverpod(keepAlive: true)
class ThemeController extends _$ThemeController {
  late final Box _settingsBox;

  @override
  ThemeMode build() {
    // Note: We assume the repository has been initialized
    _settingsBox = Hive.box('settings');
    final themeName = _settingsBox.get('themeMode', defaultValue: 'system') as String;
    return ThemeMode.values.firstWhere((e) => e.name == themeName, orElse: () => ThemeMode.system);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _settingsBox.put('themeMode', mode.name);
    state = mode;
  }
}