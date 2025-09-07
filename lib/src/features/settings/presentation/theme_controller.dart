import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'theme_controller.g.dart';

@Riverpod(keepAlive: true)
class ThemeController extends _$ThemeController {
  late final Box _settingsBox;

  @override
  ThemeMode build() {
    _settingsBox = Hive.box('settings');
    // Load the saved theme, defaulting to system.
    final themeName = _settingsBox.get('themeMode', defaultValue: 'system') as String;
    return ThemeMode.values.firstWhere((e) => e.name == themeName);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _settingsBox.put('themeMode', mode.name);
    state = mode;
  }
}