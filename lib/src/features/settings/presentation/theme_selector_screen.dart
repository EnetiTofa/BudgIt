import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/settings/presentation/theme_controller.dart';

class ThemeSelectorScreen extends ConsumerWidget {
  const ThemeSelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
      ),
      body: ListView(
        children: [
          RadioListTile<ThemeMode>(
            title: const Text('Device Theme'),
            subtitle: const Text('Follow the system light/dark mode setting.'),
            value: ThemeMode.system,
            groupValue: currentTheme,
            onChanged: (mode) => controller.setThemeMode(mode!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light Mode'),
            value: ThemeMode.light,
            groupValue: currentTheme,
            onChanged: (mode) => controller.setThemeMode(mode!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark Mode'),
            value: ThemeMode.dark,
            groupValue: currentTheme,
            onChanged: (mode) => controller.setThemeMode(mode!),
          ),
        ],
      ),
    );
  }
}