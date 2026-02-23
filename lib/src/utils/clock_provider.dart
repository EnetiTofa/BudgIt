// lib/src/utils/clock_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/utils/clock.dart';

// Remove these imports to break the coupling
// import 'package:budgit/src/features/check_in/presentation/app_bar_info_provider.dart';
// import 'package:budgit/src/features/check_in/presentation/is_check_in_available_provider.dart';
// import 'package:budgit/src/features/budget_hub/wallet/presentation/providers/wallet_category_data_provider.dart';

part 'clock_provider.g.dart';

@Riverpod(keepAlive: true)
class ClockNotifier extends _$ClockNotifier {
  @override
  Clock build() {
    return Clock();
  }

  void setTime(DateTime newTime) {
    state = Clock(newTime);
    // Automatic propagation handles the rest!
  }

  /// Moves the current time forward by the given [Duration].
  void advanceTime(Duration duration) {
    state = Clock(state.now().add(duration));
  }

  /// Resets the clock to use the real current time.
  void reset() {
    state = Clock();
  }
}