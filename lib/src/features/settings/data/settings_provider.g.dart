// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingsHash() => r'b81b6feb8556a8ba43375eb5a16439a8dadd2e1d';

/// See also [Settings].
@ProviderFor(Settings)
final settingsProvider =
    AsyncNotifierProvider<Settings, SettingsRepository>.internal(
  Settings.new,
  name: r'settingsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$settingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Settings = AsyncNotifier<SettingsRepository>;
String _$themeControllerHash() => r'860f79dc647471b02428ea925ee3d3530ef38fe3';

/// See also [ThemeController].
@ProviderFor(ThemeController)
final themeControllerProvider =
    NotifierProvider<ThemeController, ThemeMode>.internal(
  ThemeController.new,
  name: r'themeControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$themeControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ThemeController = Notifier<ThemeMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
