// lib/src/utils/clock_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/features/check_in/presentation/app_bar_info_provider.dart';
import 'package:budgit/src/features/check_in/presentation/is_check_in_available_provider.dart';
import 'package:budgit/src/features/wallet/presentation/providers/wallet_category_data_provider.dart';
import 'package:budgit/src/utils/clock.dart';

part 'clock_provider.g.dart';

@Riverpod(keepAlive: true)
// --- MODIFICATION: Added the required "extends" clause ---
class ClockNotifier extends _$ClockNotifier {
  @override
  Clock build() {
    return Clock();
  }
  void setTime(DateTime newTime) {
    state = Clock(newTime);
    _invalidateProviders();
  }

  /// Moves the current time forward by the given [Duration].
  void advanceTime(Duration duration) {
    state = Clock(state.now().add(duration));
    _invalidateProviders();
  }

  /// Resets the clock to use the real current time.
  void reset() {
    state = Clock();
    _invalidateProviders();
  }

  void _invalidateProviders() {
    ref.invalidate(isCheckInAvailableProvider);
    ref.invalidate(appBarInfoProvider);
    ref.invalidate(walletCategoryDataProvider);
    // Any other provider that relies on "today" or "this week" should be added here.
  }
}