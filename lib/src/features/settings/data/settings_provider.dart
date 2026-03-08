// lib/src/features/settings/data/settings_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';

part 'settings_provider.g.dart';

class SettingsRepository {
  late final Box _box;

  Future<void> init() async {
    _box = await Hive.openBox('settings');
  }

  int getCheckInDay() => _box.get('checkInDay', defaultValue: 1) as int;
  Future<void> setCheckInDay(int day) async => _box.put('checkInDay', day);

  // --- NEW: Tracking First Time Check-In ---
  bool getHasCompletedFirstCheckIn() =>
      _box.get('hasCompletedFirstCheckIn', defaultValue: false) as bool;

  Future<void> setHasCompletedFirstCheckIn(bool value) async =>
      _box.put('hasCompletedFirstCheckIn', value);

  // --- NEW: Tracking Monthly Check-In Date ---
  DateTime? getLastMonthlyCheckInDate() {
    final timestamp = _box.get('lastMonthlyCheckInDate') as int?;
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  Future<void> setLastMonthlyCheckInDate(DateTime date) async =>
      _box.put('lastMonthlyCheckInDate', date.millisecondsSinceEpoch);
}

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

  // Expose the new methods
  bool getHasCompletedFirstCheckIn() =>
      state.value!.getHasCompletedFirstCheckIn();
  Future<void> setHasCompletedFirstCheckIn(bool value) async =>
      state.value!.setHasCompletedFirstCheckIn(value);

  DateTime? getLastMonthlyCheckInDate() =>
      state.value!.getLastMonthlyCheckInDate();
  Future<void> setLastMonthlyCheckInDate(DateTime date) async =>
      state.value!.setLastMonthlyCheckInDate(date);
}

@Riverpod(keepAlive: true)
class ThemeController extends _$ThemeController {
  late final Box _settingsBox;

  @override
  ThemeMode build() {
    _settingsBox = Hive.box('settings');
    final themeName =
        _settingsBox.get('themeMode', defaultValue: 'system') as String;
    return ThemeMode.values.firstWhere(
      (e) => e.name == themeName,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _settingsBox.put('themeMode', mode.name);
    state = mode;
  }
}
