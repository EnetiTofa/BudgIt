// lib/src/features/check_in/presentation/app_bar_info_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/features/check_in/presentation/is_check_in_available_provider.dart';
import 'package:budgit/src/features/check_in/presentation/streak_provider.dart';

part 'app_bar_info_provider.g.dart';

class AppBarInfo {
  final int streakCount;
  final bool isCheckInCompleted;

  AppBarInfo({required this.streakCount, required this.isCheckInCompleted});
}

@Riverpod(keepAlive: true)
Future<AppBarInfo> appBarInfo(AppBarInfoRef ref) async {
  final (streakCount, isCheckInAvailable) = await (
    ref.watch(checkInStreakProvider.future),
    ref.watch(isCheckInAvailableProvider.future),
  ).wait;

  return AppBarInfo(
    streakCount: streakCount,
    isCheckInCompleted: !isCheckInAvailable,
  );
}