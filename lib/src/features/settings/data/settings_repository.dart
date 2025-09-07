import 'package:hive_flutter/hive_flutter.dart';
import 'package:budgit/src/features/settings/domain/screen_layout.dart';

class SettingsRepository {
  late final Box _settingsBox;
  late final Box<ScreenLayout> _layoutBox; // New box for layouts

  Future<void> init() async {
    _settingsBox = await Hive.openBox('settings');
    _layoutBox = await Hive.openBox<ScreenLayout>('layouts');
  }
  
  int getCheckInDay() {
    // Default to Sunday (7) if not set
    return _settingsBox.get('checkInDay', defaultValue: 7);
  }

  Future<void> setCheckInDay(int day) async {
    await _settingsBox.put('checkInDay', day);
  }

    Future<ScreenLayout> getScreenLayout(String screenId, {required List<String> defaultOrder}) async {
    // Return the saved layout, or create a default one if it doesn't exist.
    return _layoutBox.get(
      screenId,
      defaultValue: ScreenLayout(
        screenId: screenId,
        widgetOrder: defaultOrder,
        defaultWidget: defaultOrder.first,
      ),
    ) as ScreenLayout;
  }

  Future<void> saveScreenLayout(ScreenLayout layout) async {
    await _layoutBox.put(layout.screenId, layout);
  }
}