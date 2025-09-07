import 'package:hive_flutter/hive_flutter.dart';

class SettingsRepository {
  late final Box _settingsBox;

  Future<void> init() async {
    _settingsBox = await Hive.openBox('settings');
  }
  
  int getCheckInDay() {
    // Default to Sunday (7) if not set
    return _settingsBox.get('checkInDay', defaultValue: 7);
  }

  Future<void> setCheckInDay(int day) async {
    await _settingsBox.put('checkInDay', day);
  }
}