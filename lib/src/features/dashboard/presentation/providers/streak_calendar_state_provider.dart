// lib/src/features/check_in/presentation/streak_calendar_state_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/utils/clock_provider.dart';
import 'package:budgit/src/features/check_in/presentation/providers/streak_provider.dart';

part 'streak_calendar_state_provider.g.dart';

class StreakCalendarState {
  final Set<DateTime> highlightedDates;
  final Map<DateTime, int> streakTips; 
  final Set<DateTime> successfulDatesStripped;

  StreakCalendarState({
    required this.highlightedDates,
    required this.streakTips,
    required this.successfulDatesStripped,
  });
}

@riverpod
Future<StreakCalendarState> streakCalendarState(StreakCalendarStateRef ref) async {
  final history = await ref.watch(checkInHistoryProvider.future);
  final streakCount = await ref.watch(checkInStreakProvider.future);
  final clock = ref.watch(clockNotifierProvider);

  final now = clock.now();
  final today = DateTime(now.year, now.month, now.day);

  final successfulDatesStripped = history.map((d) => DateTime(d.year, d.month, d.day)).toSet();
  final sortedDates = successfulDatesStripped.toList()..sort();
  
  final highlightedDates = <DateTime>{};
  final streakTips = <DateTime, int>{};

  if (sortedDates.isNotEmpty) {
    // 1. Slice the history based on the ACTUAL streak count
    final activeCount = streakCount.clamp(0, sortedDates.length);
    final pastDates = sortedDates.sublist(0, sortedDates.length - activeCount);
    final activeDates = sortedDates.sublist(sortedDates.length - activeCount);

    // --- 2. Process Past Dates (Previous broken streak) ---
    if (pastDates.isNotEmpty) {
      for (final checkIn in pastDates) {
        // Highlight the 7 days leading up to each successful historical check-in
        for (int j = 0; j < 7; j++) {
          highlightedDates.add(checkIn.subtract(Duration(days: j)));
        }
      }
      
      // Connect the dots between the past dates
      if (pastDates.length > 1) {
        DateTime curr = pastDates.first;
        while (!curr.isAfter(pastDates.last)) {
          highlightedDates.add(curr);
          curr = curr.add(const Duration(days: 1));
        }
      }
      
      // Anchor the historical tip to the final check-in of that broken streak.
      streakTips[pastDates.last] = pastDates.length; 
    }

    // --- 3. Process Active Dates (Current Streak) ---
    if (activeDates.isNotEmpty) {
      for (final checkIn in activeDates) {
        // Highlight the 7 days leading up to each successful active check-in
        // This ensures a new streak forms its own start point 7 days prior!
        for (int j = 0; j < 7; j++) {
          highlightedDates.add(checkIn.subtract(Duration(days: j)));
        }
      }

      // Connect the dots for the active streak AND stretch it to today
      DateTime curr = activeDates.first;
      while (!curr.isAfter(today)) {
        highlightedDates.add(curr);
        curr = curr.add(const Duration(days: 1));
      }

      // Anchor the active tip to today
      streakTips[today] = streakCount;
    }
  }

  return StreakCalendarState(
    highlightedDates: highlightedDates,
    streakTips: streakTips,
    successfulDatesStripped: successfulDatesStripped,
  );
}