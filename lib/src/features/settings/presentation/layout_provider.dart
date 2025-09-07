import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/features/settings/domain/screen_layout.dart';
import 'package:budgit/src/features/settings/presentation/settings_provider.dart';

part 'layout_provider.g.dart';

// V-- Rename the class from "ScreenLayout" to "ScreenLayoutNotifier"
@riverpod
class ScreenLayoutNotifier extends _$ScreenLayoutNotifier {
  @override
  Future<ScreenLayout> build(String screenId, {required List<String> defaultOrder}) async {
    print('--- 3. LayoutProvider ($screenId): Trying to get settings notifier... ---');
    final settingsNotifier = ref.read(settingsProvider.notifier);
    print('--- 4. LayoutProvider ($screenId): Got notifier. Getting layout... ---');
    final layout = await settingsNotifier.getScreenLayout(screenId, defaultOrder: defaultOrder);
    print('--- 5. LayoutProvider ($screenId): Got layout. Build complete. ---');
    return layout;
  }

  Future<void> saveScreenLayout(ScreenLayout layout) async {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    await settingsNotifier.saveScreenLayout(layout);
    state = AsyncValue.data(layout);
  }
}